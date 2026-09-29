from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import MessageCreate, MessageResponse, ConversationCreate, ConversationResponse
from app.models import Message, Conversation, User
from app.services.chat_service import ChatService
from app.services.auth_service import get_current_user
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

chat_service = ChatService()

@router.post("/conversations", response_model=ConversationResponse, status_code=status.HTTP_201_CREATED)
async def create_conversation(
    conv_data: ConversationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Criar nova conversa"""
    try:
        conversation = await chat_service.create_conversation(conv_data, current_user, db)
        logger.info(f"✅ Conversa criada: {conversation.id}")
        return conversation
    except Exception as e:
        logger.error(f"❌ Erro ao criar conversa: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao criar conversa"
        )

@router.get("/conversations", response_model=list[ConversationResponse])
async def list_conversations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100)
):
    """Listar conversas do usuário"""
    try:
        conversations = db.query(Conversation).filter(
            Conversation.users.any(User.id == current_user.id)
        ).offset(skip).limit(limit).all()
        return conversations
    except Exception as e:
        logger.error(f"❌ Erro ao listar conversas: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao listar conversas"
        )

@router.get("/conversations/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Obter detalhes de uma conversa"""
    try:
        conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conversation or current_user not in conversation.users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversa não encontrada"
            )
        return conversation
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao obter conversa: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao obter conversa"
        )

@router.post("/conversations/{conversation_id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    conversation_id: str,
    message_data: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Enviar mensagem para a conversa"""
    try:
        # Verificar se conversa existe
        conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conversation or current_user not in conversation.users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversa não encontrada"
            )
        
        # Criar mensagem do usuário
        user_message = await chat_service.create_message(
            conversation_id, current_user.id, message_data.content, "user", message_data.message_type, db
        )
        
        # Obter resposta da IA
        ai_response = await chat_service.get_ai_response(message_data.content, conversation_id, current_user.id, db)
        
        # Salvar resposta da IA
        ai_message = await chat_service.create_message(
            conversation_id, "gd-ia", ai_response, "assistant", "text", db
        )
        
        logger.info(f"✅ Mensagem enviada na conversa {conversation_id}")
        return user_message
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao enviar mensagem: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao enviar mensagem"
        )

@router.get("/conversations/{conversation_id}/messages", response_model=list[MessageResponse])
async def get_messages(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100)
):
    """Obter mensagens de uma conversa"""
    try:
        conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conversation or current_user not in conversation.users:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Conversa não encontrada"
            )
        
        messages = db.query(Message).filter(
            Message.conversation_id == conversation_id
        ).order_by(Message.created_at).offset(skip).limit(limit).all()
        
        return messages
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao obter mensagens: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao obter mensagens"
        )
