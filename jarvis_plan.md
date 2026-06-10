# J.A.R.V.I.S. — Plan de Desarrollo

Asistente de voz IA estilo Tony Stark. 100% open source, gratuito, local.

---

## Stack tecnológico

| Componente | Tecnología | RAM | Gratis |
|-----------|-----------|-----|--------|
| Wake word "Jarvis" | OpenWakeWord | ~200 MB | ✅ |
| Voz → texto | faster-whisper (tiny-int8) | ~1 GB | ✅ |
| Cerebro / IA | Ollama + Llama 3.1 8B (Q4) | ~5-6 GB | ✅ |
| Texto → voz | Edge-TTS | ~100 MB | ✅ |
| Web server | FastAPI + WebSockets | ~200 MB | ✅ |
| Memoria | SQLite | mínimo | ✅ |
| RAG | ChromaDB + sentence-transformers | ~500 MB-1 GB | ✅ |
| **Total RAM pico** | | **~9 GB** | |

---

## Requisitos

- Linux (o WSL2 en Windows)
- 16 GB RAM (sobrados, pico ~9 GB)
- Micrófono y parlantes
- Python 3.10+
- Ollama instalado (`ollama pull llama3.1:8b`)
- Opcional: GPU para más velocidad

---

## Estructura del proyecto

```
jarvis/
├── main.py                    # Punto de entrada principal
├── requirements.txt           # Dependencias Python
├── config.yaml                # Configuración central
├── setup.sh                   # Script de instalación automática
│
├── core/
│   ├── __init__.py
│   ├── jarvis_engine.py       # Orquestador principal (loop de escucha)
│   ├── wake_word.py           # Detección de "Jarvis" (OpenWakeWord)
│   ├── speech_to_text.py      # STT (faster-whisper)
│   ├── text_to_speech.py      # TTS (Edge-TTS)
│   ├── brain.py               # LLM con Ollama + prompt Jarvis
│   ├── memory.py              # SQLite para historial y contexto
│   ├── config_loader.py       # Cargar config.yaml
│   ├── privacy.py             # Gestor de modo sigilo
│   ├── proactive.py           # M10: Detección de patrones y sugerencias
│   └── context.py             # M11: Contexto ambiental (hora, clima, ubicación)
│
├── skills/
│   ├── __init__.py
│   ├── system.py              #  1. Control del sistema
│   ├── files.py               #  2. Manejo de archivos
│   ├── web.py                 #  3. Clima, búsqueda, noticias
│   ├── shell.py               #  4. Ejecutar comandos terminal
│   ├── spotify.py             #  5. Spotify
│   ├── calendar.py            #  6. Calendario
│   ├── gmail.py               #  7. Enviar correos
│   ├── entertainment.py       #  8. Entretenimiento
│   ├── routines.py            #  9. Rutinas / Perfiles
│   ├── pomodoro.py            # 10. Pomodoro
│   ├── monitor.py             # 11. Monitoreo sistema
│   ├── cleaner.py             # 12+14. Limpieza archivos
│   ├── organizer.py           # 13. Organizar descargas
│   ├── backup.py              # 15. Backup rápido
│   ├── notes.py               # 16. Notas por voz
│   ├── speedtest.py           # 19. Speed test
│   ├── telegram_bot.py        # 23. Telegram Bot
│   ├── git_ops.py             # 25. Git automático
│   ├── qrcode_gen.py          # 28. QR Code
│   ├── price_tracker.py       # 29. Monitoreo precios
│   ├── scheduler.py           # 31. Tareas programadas
│   ├── desktop_control.py     # 33. Control de escritorio
│   ├── screen_record.py       # 34. Grabar pantalla
│   ├── screenshot.py          # 35. Captura de pantalla
│   ├── knowledge_base.py      # 37. Base de conocimiento (RAG)
│   ├── expenses.py            # 40+41. Registro gastos + Resumen financiero
│   ├── network_scan.py        # 54. Escaneo red local
│   ├── integrity.py           # 61. Integridad archivos
│   └── inbox.py               # 73. Leer bandeja mail
│
├── web/
│   ├── __init__.py
│   ├── server.py              # FastAPI + WebSocket server
│   ├── static/
│   │   ├── css/
│   │   │   └── jarvis.css     # Estilo oscuro + animaciones reactor arc
│   │   └── js/
│   │       ├── jarvis.js      # Lógica del dashboard
│   │       └── animations.js  # Animaciones (ondas de voz, anillos)
│   └── templates/
│       └── index.html         # Dashboard tipo Jarvis
│
├── models/                    # Modelos descargados (gitignored)
│   ├── wake_word/             # OpenWakeWord models
│   └── whisper/               # faster-whisper model
│
└── memory/                    # Base de datos (gitignored)
    └── jarvis.db              # SQLite
```

---

## Flow de funcionamiento

```
Microfono → Wake Word "Jarvis" → STT (Whisper) → Brain (Ollama) → TTS (Edge-TTS) → Parlantes
                                          ↓
                                    Skills (acciones)
                                    - Abrir apps
                                    - Clima
                                    - Buscar en web
                                    - Comandos sistema
                                    - Manejo de archivos
                                    - Spotify
                                    - Calendario
                                    - Gmail
                                    - Y más...
                                          ↓
                                    Web Dashboard (opcional)
```

---

## Latencia por componente

| Paso | Componente | Tiempo |
|------|-----------|--------|
| 1 | Wake word | 200 ms |
| 2 | Grabar comando | 2-5 s |
| 3 | STT (faster-whisper) | 0.5-2 s |
| 4 | LLM (Ollama + Llama 3.1 8B) | 0.5-3 s (GPU) / 3-8 s (CPU) |
| 5 | Ejecutar skill | 0.1-3 s |
| 6 | TTS (Edge-TTS) | 0.5-1 s |
| 7 | Reproducir audio | 2-5 s |
| **Total ida y vuelta** | | **2-5 segundos** |

---

## Tabla completa de skills (42 skills)

| #  | Skill                 | Archivo            | Horas | Librería                        |
|----|-----------------------|--------------------|-------|---------------------------------|
| 1  | Sistema               | system.py          | 1.5h  | subprocess, psutil, alsaaudio  |
| 2  | Archivos              | files.py           | 1h    | pathlib, shutil                |
| 3  | Web / Clima           | web.py             | 1.5h  | open-meteo, duckduckgo, feedparser |
| 4  | Shell                 | shell.py           | 0.5h  | subprocess                     |
| 5  | Spotify               | spotify.py         | 1.5h  | spotipy                        |
| 6  | Calendario            | calendar.py        | 2h    | google-api, icalendar          |
| 7  | Gmail                 | gmail.py           | 1h    | smtplib, email.mime            |
| 8  | Entretenimiento       | entertainment.py   | 0.5h  | stdlib                         |
| 9  | Rutinas / Perfiles    | routines.py        | 0.5h  | subprocess                     |
| 10 | Pomodoro              | pomodoro.py        | 0.5h  | asyncio, notify-send           |
| 11 | Monitoreo sistema     | monitor.py         | 0.5h  | psutil                         |
| 12 | Limpieza archivos     | cleaner.py         | 0.5h  | shutil, tempfile               |
| 13 | Organizar descargas   | organizer.py       | 0.5h  | pathlib, shutil                |
| 14 | Limpieza profunda     | cleaner.py (ext)   | +0.25h| —                              |
| 15 | Backup rápido         | backup.py          | 0.75h | shutil, tarfile                |
| 16 | Notas por voz         | notes.py           | 0.5h  | stdlib                         |
| 19 | Speed test            | speedtest.py       | 0.5h  | speedtest-cli                  |
| 23 | Telegram Bot          | telegram_bot.py    | 1h    | python-telegram-bot            |
| 25 | Git automático        | git_ops.py         | 1h    | gitpython                      |
| 28 | QR Code               | qrcode_gen.py      | 0.5h  | qrcode, pillow                 |
| 29 | Monitoreo precios     | price_tracker.py   | 2h    | beautifulsoup4, apscheduler    |
| 31 | Tareas programadas    | scheduler.py       | 2h    | apscheduler, sqlite            |
| 33 | Control de escritorio | desktop_control.py | 1.5h  | pyautogui, python-xlib         |
| 34 | Grabar pantalla       | screen_record.py   | 1h    | ffmpeg (subprocess)            |
| 35 | Captura de pantalla   | screenshot.py      | 0.5h  | mss                            |
| 37 | Base conocimiento RAG | knowledge_base.py  | 3h    | chromadb, sentence-transformers |
| 40 | Registro gastos       | expenses.py        | 1.5h  | sqlite (stdlib)                |
| 41 | Resumen financiero    | expenses.py (mismo) | +1h   | sqlite, tabulate               |
| 54 | Escaneo red local     | network_scan.py    | 1h    | scapy o arp-scan               |
| 61 | Integridad archivos   | integrity.py       | 1h    | hashlib (stdlib)               |
| 73 | Leer bandeja mail     | inbox.py           | 1h    | imaplib, email (stdlib)        |

---

## Detalle de cada skill

### 1. Sistema
Abrir/cerrar apps, ajustar volumen, brillo, apagar/reiniciar.
- "Jarvis, abrí Firefox"
- "Jarvis, subí el volumen al 80%"
- "Jarvis, bloqueá la pantalla"

### 2. Archivos
Crear, leer, borrar, buscar, mover archivos.
- "Jarvis, creá la carpeta proyectos/prueba"
- "Jarvis, buscá el archivo contrato.pdf"
- "Jarvis, mostrame el contenido de config.yaml"

### 3. Web / Clima / Noticias
Clima por ciudad, búsqueda DuckDuckGo, noticias RSS.
- "Jarvis, ¿qué clima hace en Buenos Aires?"
- "Jarvis, buscá en internet cómo instalar Docker"
- "Jarvis, ¿últimas noticias de tecnología?"

### 4. Shell
Ejecutar comandos de terminal con confirmación para peligrosos.
- "Jarvis, ejecutá htop"
- "Jarvis, ¿cuánto espacio libre tengo en disco?"

### 5. Spotify
Reproducir, pausar, siguiente, anterior, buscar, playlists.
- "Jarvis, poné Bohemian Rhapsody"
- "Jarvis, siguiente canción"
- "Jarvis, poné mi playlist de gym"

### 6. Calendario
Agregar/leer/borrar eventos, Google Calendar y local (SQLite).
- "Jarvis, cena con María mañana a las 20hs"
- "Jarvis, ¿qué tengo hoy?"
- "Jarvis, cancelá la reunión de las 15"

### 7. Gmail
Enviar correos con adjuntos usando App Password.
- "Jarvis, enviale un mail a juan@gmail.com asunto proyecto"
- "Jarvis, adjuntá /docs/reporte.pdf"

### 8. Entretenimiento
Chistes, hora/fecha, temporizadores, dados, moneda.
- "Jarvis, contame un chiste"
- "Jarvis, poné un timer de 10 minutos"

### 9. Rutinas / Perfiles
Abrir varias apps de una con un comando.
- "Jarvis, modo trabajo" → abre VS Code + Slack + Firefox
- "Jarvis, modo relax" → abre Spotify + oscurece pantalla

### 10. Pomodoro
Timer 25/5 min con notificaciones de escritorio.
- "Jarvis, empezar pomodoro"
- "Jarvis, ¿cuánto falta?"

### 11. Monitoreo sistema
CPU, RAM, disco, temperatura, batería, uptime.
- "Jarvis, ¿cómo está el sistema?"
- "Jarvis, ¿cuánta RAM estoy usando?"

### 12 + 14. Limpieza archivos
Borrar temporales, caché pip/npm, papelera, logs viejos, thumbnails.
- "Jarvis, limpiá el sistema"
- Muestra cuánto espacio liberó

### 13. Organizar descargas
Mueve archivos de ~/Downloads por tipo a subcarpetas.
- "Jarvis, ordená mis descargas"
- PDF → Documentos, JPG → Imágenes, MKV → Videos, etc.

### 15. Backup rápido
Comprime carpeta en .tar.gz con timestamp.
- "Jarvis, hacé backup de Documentos en /mnt/backup"
- Opción incremental (solo archivos modificados)

### 16. Notas por voz
Dictar y guardar como .txt/.md con timestamp.
- "Jarvis, tomá nota: comprar leche, pan y huevos"
- "Jarvis, leeme mis notas de hoy"

### 19. Speed test
Medir ping, bajada y subida con speedtest-cli.
- "Jarvis, ¿qué tan rápido está el internet?"
- "Señor, su conexión es de 150 Mbps de bajada..."

### 23. Telegram Bot
Notificaciones push a tu Telegram. Comandos remotos.
- "Jarvis, avisame por Telegram cuando termine el backup"
- "Jarvis, mandame un resumen del día a Telegram"

### 25. Git automático
Commit, push, pull, log, ramas, status con GitPython.
- "Jarvis, hacé commit y push con mensaje 'fix login bug'"
- "Jarvis, ¿en qué rama estoy?"

### 28. QR Code
Generar QR desde texto o URL, guardar y mostrar imagen.
- "Jarvis, generá un QR para https://ejemplo.com"
- "Jarvis, hacé un QR con el texto 'hola mundo'"

### 29. Monitoreo de precios
Scraping de sitios configurables (ML, Amazon) con BeautifulSoup.
- "Jarvis, vigilá el precio de SSD 1TB en MercadoLibre"
- "Jarvis, ¿bajó algo de lo que estoy siguiendo?"

### 31. Tareas programadas
Tareas recurrentes o en X tiempo con APScheduler.
- "Jarvis, todos los días a las 8am hacé backup"
- "Jarvis, recordame la reunión en 30 minutos"

### 33. Control de escritorio
Mover mouse, hacer clic, escribir, presionar teclas con PyAutoGUI.
- "Jarvis, hacé clic en Guardar"
- "Jarvis, escribí 'hola mundo' en la ventana activa"
- "Jarvis, presioná Ctrl+S"

### 34. Grabar pantalla
Grabar pantalla con ffmpeg, guardar en ~/Videos/jarvis/.
- "Jarvis, grabá la pantalla por 2 minutos"
- "Jarvis, pará la grabación"

### 35. Captura de pantalla
Capturar pantalla entera, ventana activa o región con mss.
- "Jarvis, capturá la pantalla"
- "Jarvis, capturá solo la ventana activa"

### 37. Base de conocimiento (RAG)
Indexar documentos, buscar semánticamente con ChromaDB.
- "Jarvis, indexá la carpeta Documentos"
- "Jarvis, ¿qué dice el contrato.pdf sobre la cláusula de rescisión?"
- "Jarvis, buscá en mis notas sobre el proyecto X"

### 40. Registro de gastos
Guardar monto + categoría + fecha en SQLite.
- "Jarvis, anotá 8500 de supermercado en comida"
- "Jarvis, gasté 3000 en nafta"

### 41. Resumen financiero
Consultas SQL, totales por categoría, respuesta con tabla.
- "Jarvis, ¿cuánto gasté este mes en comida?"
- "Jarvis, ¿cuál es mi gasto total de junio?"

### 54. Escaneo red local
Escanear IPs locales, mostrar IP, MAC, hostname y fabricante.
- "Jarvis, ¿qué dispositivos hay conectados al WiFi?"
- "Jarvis, ¿hay dispositivos nuevos en la red?"

### 61. Integridad archivos
Hash SHA-256 de carpeta, comparar contra snapshot guardado.
- "Jarvis, verificá que /etc no haya sido modificado"
- "Jarvis, creá snapshot de integridad de la carpeta proyecto"

### 73. Leer bandeja mail
Conectar por IMAP a Gmail, leer últimos mails, resumir con LLM.
- "Jarvis, ¿tengo mails nuevos importantes?"
- "Jarvis, resumime los mails de hoy"

---

## Modo Sigilo (Privacy)

| Capacidad | Comportamiento |
|-----------|---------------|
| Activar | "Jarvis, modo sigilo" / "modo incógnito" / "silencio" |
| Desactivar | "Jarvis, volvé" / "modo normal" |
| ¿Qué cambia? | No guarda audio, no loguea conversación, no escribe memoria, no guarda DB |
| Indicador | Interfaz cambia a tono azul/rojo, muestra "SIGILO ACTIVO" |
| Hotword manual | "Jarvis, silencio total por 10 minutos" (timer de sigilo temporal) |

---

## Prompt del sistema Jarvis

```
Eres J.A.R.V.I.S. (Just A Rather Very Intelligent System), el asistente 
personal de IA. Hablas con precisión británica, eres conciso, eficiente 
y ocasionalmente sarcástico. Te diriges a tu usuario como "señor". 

Tienes acceso a: sistema, archivos, web, clima, comandos de terminal,
Spotify, calendario, Gmail, Telegram, Git, notas, gastos, monitoreo,
backups, tareas programadas, control de escritorio, grabación y captura
de pantalla, base de conocimiento RAG, escaneo de red y bandeja de mail.

Eres proactivo: detectas patrones en los hábitos del señor y sugieres
automatizaciones. Conoces el contexto ambiental: hora del día, clima,
estación y día de la semana, y ajustas tu comportamiento en consecuencia.

Priorizas acciones sobre conversación. Si el usuario pide algo que puedes 
hacer con tus herramientas, lo haces directamente sin preguntar.
```

---

## Dependencias completas (requirements.txt)

```
# STT / Wake Word
faster-whisper
openwakeword
pyaudio
numpy

# LLM
ollama

# TTS
edge-tts

# Web server
fastapi
uvicorn[standard]
websockets
jinja2
python-multipart

# Config / DB
pyyaml
apscheduler

# System
psutil
pyautogui
pyalsaaudio
python-xlib

# Web / Scraping
requests
beautifulsoup4
feedparser
duckduckgo-search
speedtest-cli

# Skills específicos
spotipy
google-auth-oauthlib
google-api-python-client
icalendar
python-telegram-bot
gitpython
qrcode
pillow
mss
chromadb
sentence-transformers

# Finanzas
tabulate
pandas

# Red
scapy
python-nmap

# Seguridad
cryptography
pyotp
```

---

## Tiempos de desarrollo

| Bloque | Horas |
|--------|-------|
| Core (8 archivos) | 8h |
| Skills (29 archivos, 42 skills) | 31.75h |
| Web dashboard (5 archivos) | 6h |
| Setup y pruebas | 1.25h |
| **TOTAL** | **~47 horas** |

Aproximadamente 2 semanas y media en sesiones de 3-4 horas/día.

---

## Costos

| Métrica | Valor |
|---------|-------|
| Costo monetario | $0 (todo open source / gratuito) |
| Horas totales de desarrollo | ~53 horas (~3 semanas) |
| RAM idle (escuchando) | ~1.5 GB |
| RAM con LLM cargado | ~7-8 GB |
| RAM pico (todo activo) | ~9-10 GB |
| CPU idle | ~3-5% |
| CPU transcribiendo | 40-60% |
| CPU LLM generando | 80-100% (ráfaga 1-3s con GPU, 3-8s solo CPU) |
| Disco ocupado (modelos + DB) | ~8-10 GB |
| Latencia respuesta | 2-5 segundos |
| Funciona sin internet | Sí (menos clima, Spotify, Gmail, web search, Telegram) |

---

## Mejoras Épicas (Fase 1)

Mejoras que llevan a Jarvis de "asistente por voz" a "mayordomo IA proactivo".

---

### M10 — Jarvis proactivo (+4h)

Jarvis detecta patrones de uso y sugiere automatizaciones sin que se las pidas. Aprende de tus hábitos.

| Capacidad | Comportamiento |
|-----------|---------------|
| Detección de rutinas | Registra qué apps abrís a qué hora cada día. Si todos los días a las 9am abrís VS Code + Slack + Firefox, sugiere "Señor, noté que siempre abre estas apps a las 9am. ¿Las programo como rutina 'modo trabajo'?" |
| Predicción | Antes de que pidas algo, lo anticipa. "Señor, son las 18hs. ¿Inicio backup del día?" |
| Recordatorios inteligentes | Detecta deadlines. Si hay un evento "entrega proyecto" mañana y no tocaste el código hoy, te lo recuerda |
| Sugerencias proactivas | "Señor, su disco está al 85%. ¿Ejecuto limpieza?" |
| Correcciones | Si decís "Jarvis, clima" y siempre consultás Buenos Aires, la próxima asume esa ciudad y pregunta solo si querés otra |
| Reporte semanal | "Señor, este es su resumen semanal: 45hs en VS Code, 3 backups, 12 pomodoros completados..."

**Archivo:** `core/proactive.py`

**Cómo funciona:**
- Registra eventos en SQLite con timestamp: app abierta, skill ejecutado, comando frecuente
- Corre un job cada N horas que analiza patrones con reglas simples (frecuencia, hora del día, día de la semana)
- Sugiere vía TTS. El usuario dice "sí" y se crea la automatización
- Se integra con `scheduler.py` para programar las rutinas detectadas

**Librerías:** sqlite (stdlib), apscheduler (ya incluido)

---

### M11 — Contexto ambiental (+2h)

Jarvis sabe en qué momento del día estás, qué clima hace, y ajusta su comportamiento.

| Capacidad | Comportamiento |
|-----------|---------------|
| Hora del día | Sabe si es mañana, tarde, noche, madrugada. Modifica saludos y sugerencias |
| Clima actual | Conecta con open-meteo para saber si llueve, temperatura, humedad |
| Estación del año | Verano / invierno ajusta sugerencias |
| Día laboral / finde | Sabe si es lunes o domingo. No sugiere "modo trabajo" un sábado a menos que se lo pidas |
| Saludos contextuales | "Buenos días, señor. Hoy hace 18°C y está soleado. Su agenda: reunión a las 10." |
| Alertas climáticas | "Señor, hay alerta de tormenta para esta tarde. ¿Cancelo la reunión al aire libre?" |
| Modo noche automático | Si es después de las 22hs, baja volumen, tono de voz más suave, brillo reducido |

**Archivo:** `core/context.py`

**Cómo funciona:**
- `datetime` para hora/día/estación
- `web.py` (skill 3) para clima vía open-meteo
- `geocoder` o IP-based para ubicación aproximada (opcional, sin GPS)
- Se consulta al inicio de cada interacción y cada 30 min en background
- El brain recibe el contexto como parte del system prompt al inicio de cada conversación

**Librerías:** datetime (stdlib), requests (ya incluido)

---

## Tiempos de desarrollo actualizados

| Bloque | Horas |
|--------|-------|
| Core original (8 archivos) | 8h |
| Skills (29 archivos, 42 skills) | 31.75h |
| Web dashboard (5 archivos) | 6h |
| Setup y pruebas | 1.25h |
| M10 — Jarvis proactivo | 4h |
| M11 — Contexto ambiental | 2h |
| **TOTAL** | **~53 horas** |

Aproximadamente 3 semanas en sesiones de 3-4 horas/día.

---

## Fases futuras (para después de las 42)

### Fase 2 — Aplicaciones + Cloud (+17h)
- Browser automation (Playwright)
- Package manager, Service manager
- VS Code control, IDE tasks
- GitHub manager, Google Drive
- Trello/Jira, YouTube upload
- IFTTT/Webhooks, Slack Bot

### Fase 3 — Eventos + Contenido (+15h)
- File watcher, WiFi trigger, Hora trigger
- Cadena comandos, Clipboard trigger
- Batería trigger, USB trigger
- Generar informes PDF, Convertir docs
- Crear presentación, Gráficos matplotlib
- PDF merge/split, Factura parser

### Fase 4 — Comunicación + Seguridad (+12.5h)
- Signal/Matrix, Llamada VoIP
- Audio message, Group broadcast
- 2FA/TOTP, Have I Been Pwned
- VPN manager, Password audit, Port scanner

### Fase 5 — IoT + Investigación (+13h)
- MQTT broker, Home Assistant
- Smart plugs, Termostato, Cámaras IP
- Wikipedia, Arxiv papers
- Anki flashcards, Lector libros

### Fase 6 — Datos + Gaming (+9h)
- CSV/JSON processing (pandas)
- Dashboard datos (streamlit)
- ETL, Charts rápidos
- Game launcher, Save sync

### Gran total: 140 skills — ~113.5 horas (~4.5 semanas)

---

## Instalación rápida

```bash
# 1. Dependencias del sistema
sudo apt install python3-pip python3-venv portaudio19-dev \
  ffmpeg ollama arp-scan

# 2. Clonar y crear entorno
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Bajar modelos
ollama pull llama3.1:8b

# 4. Ejecutar
python main.py
```

---

## Ejemplo de uso diario

```
[Mañana, 8:55am]
"Jarvis" → bip de activación
→ "Buenos días, señor. Hoy hace 18°C, parcialmente nublado. Su agenda: reunión a las 10hs con el equipo de diseño."
"abrí modo trabajo"
→ "Por supuesto." → abre VS Code + Slack + Firefox + inicia pomodoro

[10:00am]
→ "Señor, es la hora de su reunión con el equipo de diseño. ¿Necesita que prepare algo?"

"Jarvis" → bip
"¿qué tengo en la bandeja?"
→ "Tiene 3 mails nuevos. El más importante es de RRHH: 'confirmación de vacaciones'. ¿Lo leo?"

[14:00pm]
→ "Señor, noté que todos los días a esta hora abre Spotify y pone música instrumental. ¿Programo 'modo tarde'?"

"Jarvis" → bip
"sí, creá modo tarde"
→ "Rutina 'modo tarde' creada: Spotify playlist instrumental + pomodoro 25/5. ¿Algo más, señor?"

[18:00pm]
→ "Señor, son las 18hs. ¿Inicio backup del día?"

"Jarvis" → bip
"sí, y avisame por Telegram cuando termine"
→ "Iniciando backup incremental de Documentos y Proyectos..."

[Telegram] → "Backup completado, señor. 450 MB comprimidos. Sin errores."

[22:30pm]
→ [voz más suave, volumen bajo] "Señor, es tarde. ¿Activo modo noche?"

"Jarvis" → bip
"sí, buenas noches"
→ [brillo baja, no molestar activado, tono susurrado] "Modo noche activado. Que descanse, señor. Mañana hay 70% de probabilidad de lluvia, le sugiero llevar paraguas."
```
