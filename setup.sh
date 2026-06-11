#!/bin/bash
set -e

echo "=== J.A.R.V.I.S. Setup ==="

# Detectar OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "[ERROR] Por ahora solo Linux. Usá WSL2 si estás en Windows."
    exit 1
fi

# Verificar Python
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
if [[ $(echo "$PYTHON_VERSION >= 3.10" | bc -l) -ne 1 ]]; then
    echo "[ERROR] Se necesita Python 3.10+ (tenés $PYTHON_VERSION)"
    exit 1
fi

echo "[1/5] Instalando dependencias del sistema..."
sudo apt update
sudo apt install -y python3-pip python3-venv portaudio19-dev ffmpeg arp-scan bc

echo "[2/5] Creando entorno virtual..."
python3 -m venv venv
source venv/bin/activate

echo "[3/5] Instalando dependencias Python..."
pip install --upgrade pip
pip install -r requirements.txt

echo "[4/5] Verificando Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "[!] Ollama no encontrado. Instalando..."
    curl -fsSL https://ollama.com/install.sh | sh
fi
echo "[*] Descargando modelo Llama 3.1 8B (puede tardar)..."
ollama pull llama3.1:8b

echo "[5/5] Creando carpetas de datos..."
mkdir -p server/models/wake_word server/models/whisper server/memory/chroma

echo ""
echo "=== Instalación completa ==="
echo ""
echo "Para ejecutar:"
echo "  source venv/bin/activate"
echo "  python server/main.py"
echo ""
