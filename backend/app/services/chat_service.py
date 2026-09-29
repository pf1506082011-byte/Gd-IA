from sqlalchemy.orm import Session
from app.models import Message, Conversation, User
from app.schemas import MessageCreate, ConversationCreate
import logging

logger = logging.getLogger(__name__)

class ChatService:
    """Serviço para gerenciar conversas e mensagens"""
    
    @staticmethod
    async def create_conversation(conv_data: ConversationCreate, user: User, db: Session):
        """Criar nova conversa"""
        try:
            conversation = Conversation(
                title=conv_data.title,
                description=conv_data.description
            )
            conversation.users.append(user)
            db.add(conversation)
            db.commit()
            db.refresh(conversation)
            return conversation
        except Exception as e:
            logger.error(f"Erro ao criar conversa: {str(e)}")
            db.rollback()
            raise
    
    @staticmethod
    async def create_message(
        conversation_id: str,
        user_id: str,
        content: str,
        role: str,
        message_type: str,
        db: Session
    ):
        """Criar nova mensagem"""
        try:
            message = Message(
                conversation_id=conversation_id,
                user_id=user_id,
                role=role,
                content=content,
                message_type=message_type
            )
            db.add(message)
            db.commit()
            db.refresh(message)
            return message
        except Exception as e:
            logger.error(f"Erro ao criar mensagem: {str(e)}")
            db.rollback()
            raise
    
    @staticmethod
    async def get_ai_response(user_message: str, conversation_id: str, user_id: str, db: Session) -> str:
        """Obter resposta da IA baseada na mensagem do usuário"""
        try:
            # Aqui você pode integrar com OpenAI, Gemini, ou sua própria IA
            # Por enquanto, uma resposta simples como placeholder
            
            # Buscar contexto de conversas anteriores
            messages = db.query(Message).filter(
                Message.conversation_id == conversation_id
            ).order_by(Message.created_at.desc()).limit(10).all()
            
            context = "\n".join([f"{m.role}: {m.content}" for m in reversed(messages)])
            
            # Simular resposta da IA
            # No production, integrar com API de IA real
            response = f"Entendi sua mensagem: '{user_message}'. Como posso ajudar?"
            
            return response
        except Exception as e:
            logger.error(f"Erro ao obter resposta da IA: {str(e)}")
            raise
