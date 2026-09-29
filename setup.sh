#!/bin/bash

# Setup script for GD IA Backend

echo "🚀 Iniciando setup do GD IA Backend..."

# Create virtual environment
echo "📦 Criando ambiente virtual..."
python -m venv venv

# Activate virtual environment
echo "✅ Ativando ambiente virtual..."
source venv/bin/activate || . venv/Scripts/activate

# Install dependencies
echo "📚 Instalando dependências..."
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file
echo "🔧 Criando arquivo .env..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Não esqueça de configurar as variáveis em .env"
fi

# Create database
echo "🗄️  Criando banco de dados..."
python -c "from app.database import engine, Base; Base.metadata.create_all(bind=engine)"

echo ""
echo "✨ Setup concluído com sucesso!"
echo ""
echo "📝 Próximos passos:"
echo "1. Configure as variáveis de ambiente em .env"
echo "2. Execute: python -m uvicorn app.main:app --reload"
echo "3. Acesse: http://localhost:8000/docs"
echo ""
