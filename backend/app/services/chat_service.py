import os
import logging
from typing import List

from sqlalchemy.orm import Session

from app.models import Message, Conversation, User
from app.schemas import MessageCreate, ConversationCreate

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
    def _fallback_response(user_message: str, context: List[str]) -> str:
        message = user_message.strip()
        lower = message.lower()

        if not message:
            return "Posso te ajudar. Me diga o que você precisa."

        if any(keyword in lower for keyword in ["oi", "olá", "hello", "hey"]):
            return "Olá! Como posso te ajudar hoje?"

        if any(keyword in lower for keyword in ["nome", "quem é você", "quem és tu"]):
            return "Eu sou a GD IA, sua assistente pessoal inteligente. Posso responder perguntas, agendar ideias, escrever código e ajudar com tarefas do dia a dia."

        if any(keyword in lower for keyword in ["programa", "código", "python", "swift", "javascript", "bash"]):
            return "Posso ajudar com programação. Me diga a linguagem e o objetivo do código, e eu te passo uma solução ou exemplo funcional."

        if any(keyword in lower for keyword in ["voz", "microfone", "áudio", "fala"]):
            return "A funcionalidade de voz está pronta no backend e no app. Se quiser, posso te orientar para testar gravação, transcrição e síntese de fala."

        if any(keyword in lower for keyword in ["memória", "lembrar", "recordar"]):
            return "Posso guardar preferências e lembrar informações importantes para você. Basta me dizer o que você quer que eu lembre."

        if any(keyword in lower for keyword in ["obrigado", "thanks", "thank you"]):
            return "De nada! Estou aqui para ajudar."

        if context:
            last = context[-3:]
            prev = "\n".join(last)
            return f"Entendi sua mensagem: '{message}'. Conte mais sobre isso e eu te ajudo. Contexto recente:\n{prev}"

        return f"Entendi sua mensagem: '{message}'. Pode me dar mais detalhes para eu te ajudar melhor?"

    @staticmethod
    async def _call_openai(user_message: str, context: List[str]) -> str | None:
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            return None

        try:
            from openai import OpenAI

            client = OpenAI(api_key=api_key)
            messages = [
                {
                    "role": "system",
                    "content": "Você é a GD IA, uma assistente pessoal inteligente. Responda em português brasileiro, seja útil, direta e amigável."
                }
            ]

            if context:
                messages.append({
                    "role": "user",
                    "content": "Contexto recente do usuário:\n" + "\n".join(context[-6:])
                })

            messages.append({
                "role": "user",
                "content": user_message
            })

            model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
            completion = client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=0.7,
                max_tokens=400,
            )

            content = completion.choices[0].message.content
            if content:
                return content.strip()
        except Exception as e:
            logger.warning(f"Falha ao usar OpenAI: {str(e)}")
            return None

        return None

    @staticmethod
    async def get_ai_response(user_message: str, conversation_id: str, user_id: str, db: Session) -> str:
        """Obter resposta da IA baseada na mensagem do usuário"""
        try:
            messages = db.query(Message).filter(
                Message.conversation_id == conversation_id
            ).order_by(Message.created_at.desc()).limit(10).all()

            context = [f"{m.role}: {m.content}" for m in reversed(messages)]

            ai_response = await ChatService._call_openai(user_message, context)
            if ai_response:
                return ai_response

            return ChatService._fallback_response(user_message, context)
        except Exception as e:
            logger.error(f"Erro ao obter resposta da IA: {str(e)}")
            return "Desculpe, ocorreu um erro ao processar sua mensagem. Tente novamente."
