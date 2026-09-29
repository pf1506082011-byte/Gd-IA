from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import VoiceInput, VoiceOutput
from app.models import User
from app.services.voice_service import VoiceService
from app.services.auth_service import get_current_user
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

voice_service = VoiceService()

@router.post("/speech-to-text")
async def speech_to_text(
    file: UploadFile = File(...),
    language: str = "pt-BR",
    current_user: User = Depends(get_current_user)
):
    """Converter áudio em texto (Speech-to-Text)"""
    try:
        # Ler arquivo de áudio
        audio_data = await file.read()
        
        # Converter para texto
        text = await voice_service.speech_to_text(audio_data, language)
        
        logger.info(f"✅ Áudio convertido para texto")
        return {
            "text": text,
            "language": language,
            "status": "success"
        }
    except Exception as e:
        logger.error(f"❌ Erro ao converter áudio: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao converter áudio para texto"
        )

@router.post("/text-to-speech")
async def text_to_speech(
    text: str,
    language: str = "pt-BR",
    speed: float = 1.0,
    current_user: User = Depends(get_current_user)
):
    """Converter texto em áudio (Text-to-Speech)"""
    try:
        if not text or len(text) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Texto não pode estar vazio"
            )
        
        # Converter texto para áudio
        audio_url = await voice_service.text_to_speech(text, language, speed)
        
        logger.info(f"✅ Texto convertido para áudio")
        return {
            "audio_url": audio_url,
            "text": text,
            "language": language,
            "speed": speed,
            "status": "success"
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao converter texto: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao converter texto para áudio"
        )

@router.post("/process-voice-command")
async def process_voice_command(
    file: UploadFile = File(...),
    language: str = "pt-BR",
    current_user: User = Depends(get_current_user)
):
    """Processar comando de voz (áudio -> texto -> processamento -> resposta)"""
    try:
        # Ler arquivo de áudio
        audio_data = await file.read()
        
        # 1. Converter áudio em texto
        text = await voice_service.speech_to_text(audio_data, language)
        logger.info(f"✅ Texto reconhecido: {text}")
        
        # 2. Processar comando (será integrado com a lógica de IA)
        # Por enquanto, apenas devolvemos o texto reconhecido
        
        # 3. Converter resposta em áudio
        response_audio = await voice_service.text_to_speech(text, language, 1.0)
        
        logger.info(f"✅ Comando de voz processado com sucesso")
        return {
            "recognized_text": text,
            "response_audio": response_audio,
            "language": language,
            "status": "success"
        }
    except Exception as e:
        logger.error(f"❌ Erro ao processar comando de voz: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao processar comando de voz"
        )

@router.post("/stream-voice")
async def stream_voice_recognition(
    current_user: User = Depends(get_current_user)
):
    """Streaming de reconhecimento de voz em tempo real (WebSocket ready)"""
    try:
        return {
            "status": "ready",
            "message": "Conecte via WebSocket para streaming de voz em tempo real"
        }
    except Exception as e:
        logger.error(f"❌ Erro no streaming: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro no streaming de voz"
        )
