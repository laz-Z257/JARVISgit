# J.A.R.V.I.S. — Plan de Desarrollo Final

## Resumen de arquitectura

**Celular como núcleo siempre activo + PC como potencia extra (cuando se prende)**

```
CELULAR (24/7)                          PC (cuando se prende)
──────────────────                      ──────────────────────
Wake Word: Porcupine                    LLM: Llama 3.1 8B (Ollama)
STT: whisper.cpp tiny (50 MB)           RAG: ChromaDB
TTS: nativo Android/iOS                 TTS: Edge-TTS
DB: jarvis_mobile.db                    DB maestra: jarvis.db
                                        Aprendizaje + memoria conversacional
Skills siempre activos:                 Skills pesados:
  SMS, llamadas, cámara, GPS            Shell, git, backup, escritorio
  Contactos, alarmas, linterna          Grabación, red, integridad
  Notas, gastos, sensores               Spotify, Gmail, web, RAG
  WiFi/BT, apps, portapapeles
  Notificaciones, salud
                              │
             Sync automático ▼ cuando la PC se prende (Tailscale)
```

---

## Stack tecnológico final

| Componente | Celular | PC |
|---|---|---|
| Wake word | Porcupine (~20 MB) | OpenWakeWord (~200 MB) |
| STT | whisper.cpp tiny (~50 MB) | faster-whisper (~1 GB) |
| Cerebro | Llama 3.2 1B (opcional, local) | Ollama + Llama 3.1 8B |
| TTS | Nativo Android/iOS | Edge-TTS |
| DB | SQLite local (jarvis_mobile.db) | SQLite maestra (jarvis.db) |
| RAG | — | ChromaDB + sentence-transformers |
| Comunicación | Tailscale VPN ($0) | Tailscale VPN ($0) |
| Framework mobile | Flutter (Android + iOS) | — |
| Server | — | FastAPI + WebSockets |
| UI PC | — | Ícono en bandeja del sistema (pystray) |
| Costo total | $0 | $0 |

---

## Estructura del proyecto

```
jarvis/
├── README.md
├── setup.sh
├── requirements.txt
├── config.yaml
│
├── server/                                    # === PC ===
│   ├── main.py                                # Punto de entrada
│   ├── core/
│   │   ├── __init__.py
│   │   ├── jarvis_engine.py                   # Orquestador principal
│   │   ├── wake_word.py                       # OpenWakeWord
│   │   ├── speech_to_text.py                  # faster-whisper
│   │   ├── text_to_speech.py                  # Edge-TTS
│   │   ├── brain.py                           # Ollama + prompt personalidad
│   │   ├── memory.py                          # SQLite operativa
│   │   ├── conversation_memory.py             # Memoria conversacional
│   │   ├── personality.py                     # Motor de tono/personalidad
│   │   ├── mood_detector.py                   # Detección de ánimo
│   │   ├── learning.py                        # Aprendizaje continuo
│   │   ├── proactive.py                       # Sugerencias proactivas
│   │   ├── context.py                         # Contexto ambiental
│   │   ├── privacy.py                         # Modo sigilo
                                                                 │   │   ├── session_manager.py                 # Multi-dispositivo
│   │   ├── sync_engine.py                     # Sync celu ↔ PC
│   │   ├── tray.py                            # Ícono en bandeja del sistema (segundo plano)
│   │   └── config_loader.py                   # Cargar config.yaml
│   │
│   ├── skills/
│   │   ├── __init__.py
│   │   ├── system.py                          # Control sistema PC
│   │   ├── files.py                           # Manejo archivos
│   │   ├── web.py                             # Clima, búsqueda, noticias
│   │   ├── shell.py                           # Terminal
│   │   ├── spotify.py                         # Spotify
│   │   ├── calendar.py                        # Calendario
│   │   ├── gmail.py                           # Enviar correos
│   │   ├── entertainment.py                   # Chistes, timers
│   │   ├── routines.py                        # Rutinas / Perfiles
│   │   ├── pomodoro.py                        # Pomodoro
│   │   ├── monitor.py                         # CPU, RAM, disco
│   │   ├── cleaner.py                         # Limpieza archivos
│   │   ├── organizer.py                       # Organizar descargas
│   │   ├── backup.py                          # Backup rápido
│   │   ├── notes.py                           # Notas por voz
│   │   ├── speedtest.py                       # Speed test
│   │   ├── telegram_bot.py                    # Telegram Bot
│   │   ├── git_ops.py                         # Git automático
│   │   ├── qrcode_gen.py                      # QR Code
│   │   ├── price_tracker.py                   # Monitoreo precios
│   │   ├── scheduler.py                       # Tareas programadas
│   │   ├── desktop_control.py                 # PyAutoGUI
│   │   ├── screen_record.py                   # Grabar pantalla
│   │   ├── screenshot.py                      # Captura pantalla
│   │   ├── knowledge_base.py                  # RAG
│   │   ├── expenses.py                        # Gastos + resumen financiero
│   │   ├── network_scan.py                    # Escaneo red
│   │   ├── integrity.py                       # Integridad archivos
│   │   ├── inbox.py                           # Leer bandeja mail
│   │   └── mobile_bridge.py                   # Skills del celu viajan al server
│   │
│   ├── web/                                    # Dashboard opcional (debug)
│   │   ├── __init__.py
│   │   ├── server.py                          # FastAPI + WebSocket + REST
│   │   └── templates/
│   │       └── index.html                     # Página opcional de debug
│   │
│   ├── models/                                # Gitignored
│   │   ├── wake_word/
│   │   └── whisper/
│   │
│   └── memory/                                # Gitignored
│       ├── jarvis.db                          # DB maestra
│       └── chroma/                            # ChromaDB
│
├── mobile/                                    # === App Flutter ===
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/
│   │   │   ├── ws_client.dart                 # WebSocket a PC
│   │   │   ├── connection_manager.dart        # Auto-detect PC on/off
│   │   │   ├── audio_recorder.dart            # Grabación nativa
│   │   │   ├── audio_player.dart              # Reproducir TTS
│   │   │   ├── wake_word.dart                 # Porcupine on-device
│   │   │   ├── local_stt.dart                 # whisper.cpp on-device
│   │   │   ├── local_tts.dart                 # TTS nativo del SO
│   │   │   ├── local_db.dart                  # SQLite local celu
│   │   │   ├── sync_service.dart              # Sync con PC
│   │   │   ├── fallback_handler.dart          # Decide modo local vs remoto
│   │   │   └── tailscale.dart                 # Config Tailscale
│   │   ├── skills/
│   │   │   ├── sms.dart                       # Leer/enviar SMS
│   │   │   ├── phone.dart                     # Llamadas
│   │   │   ├── camera.dart                    # Foto / video
│   │   │   ├── location.dart                  # GPS
│   │   │   ├── contacts.dart                  # Contactos
│   │   │   ├── notifications.dart             # Push nativas
│   │   │   ├── sensors.dart                   # Acelerómetro, salud
│   │   │   ├── clipboard.dart                 # Portapapeles
│   │   │   ├── flashlight.dart                # Linterna
│   │   │   ├── wifi_bt.dart                   # WiFi / Bluetooth / Hotspot
│   │   │   ├── system_ui.dart                 # Brillo, volumen, rotación, DND
│   │   │   ├── apps.dart                      # Abrir apps del celu
│   │   │   ├── alarms.dart                    # Alarmas nativas
│   │   │   ├── gallery.dart                   # Galería
│   │   │   ├── qr_scanner.dart                # Escáner QR
│   │   │   ├── maps.dart                      # Navegación GPS
│   │   │   ├── health.dart                    # Datos de salud
│   │   │   ├── remote_control.dart            # Control remoto de la PC
│   │   │   ├── drive_mode.dart                # Modo coche
│   │   │   └── browser.dart                   # Abrir URLs
│   │   ├── models/
│   │   │   └── message.dart                   # Protocolo JSON WS
│   │   ├── ui/
│   │   │   ├── home.dart                      # Pantalla principal
│   │   │   ├── conversation.dart              # Historial
│   │   │   ├── settings.dart                  # Config
│   │   │   └── widgets/
│   │   │       └── arc_ring.dart              # Anillo reactor arc
│   │   └── theme/
│   │       └── jarvis_theme.dart              # Estilo oscuro
│   │
│   └── android/ & ios/                        # Permisos nativos
│
└── memory/                                    # Gitignored
    └── jarvis.db                              # DB temporal (se mergea con server/)
```

---

## Protocolo de mensajes WebSocket (JSON)

```json
// CLIENTE → SERVIDOR
{"type": "wake_word_detected", "session_id": "abc123"}
{"type": "audio_chunk", "data": "<base64>", "session_id": "abc123", "seq": 42}
{"type": "audio_end", "session_id": "abc123"}
{"type": "skill_result", "skill": "sms", "action": "sent", "result": "ok"}

// SERVIDOR → CLIENTE
{"type": "listening", "session_id": "abc123"}
{"type": "thinking", "session_id": "abc123"}
{"type": "tts_audio", "data": "<base64>", "text": "...", "session_id": "abc123"}
{"type": "status", "state": "idle|listening|thinking|speaking", "info": {}}
{"type": "sync_available", "version": 42}
```

---

## Flujo de funcionamiento

```
CELULAR (siempre)
─────────────────
App en 2do plano → Wake word "Jarvis" → vibra, muestra anillo azul
→ Graba audio en chunks → WebSocket a PC (Tailscale si fuera de casa)
→ PC procesa: STT → Brain → skills → TTS
→ Celu recibe audio + texto → reproduce TTS → vuelve a idle

PC APAGADA
──────────
App en 2do plano → Wake word "Jarvis" → vibra, modo autónomo
→ STT local (whisper.cpp tiny) → Skills locales → TTS nativo
→ Guarda en SQLite local → cuando PC prende, sync automático
```

---

## Detalle de skills PC (32)

| # | Skill | Ejemplo |
|---|---|---|
| 1 | Sistema | "Abrí Firefox", "Subí volumen" |
| 2 | Archivos | "Creá carpeta X", "Buscá contrato.pdf" |
| 3 | Web | "¿Qué clima hace?", "Buscá en internet..." |
| 4 | Shell | "Ejecutá htop" |
| 5 | Spotify | "Poné Bohemian Rhapsody" |
| 6 | Calendario | "Agendá cena mañana 20hs" |
| 7 | Gmail | "Enviá mail a juan@gmail.com" |
| 8 | Entretenimiento | "Contame un chiste", "Timer 10 min" |
| 9 | Rutinas | "Modo trabajo" → VS Code + Slack + Firefox |
| 10 | Pomodoro | "Empezar pomodoro" |
| 11 | Monitor | "¿Cómo está el sistema?" |
| 12 | Limpieza | "Limpiá el sistema" |
| 13 | Organizador | "Ordená mis descargas" |
| 15 | Backup | "Backup de Documentos" |
| 16 | Notas | "Tomá nota: comprar leche" |
| 19 | Speed test | "¿Qué tan rápido está internet?" |
| 23 | Telegram | "Avisame por Telegram cuando termine" |
| 25 | Git | "Commit y push con mensaje X" |
| 28 | QR Code | "Generá un QR para..." |
| 29 | Precios | "Vigilá el precio de..." |
| 31 | Scheduler | "Todos los días a las 8 backup" |
| 33 | Desktop control | "Hacé clic en Guardar" |
| 34 | Screen record | "Grabá pantalla 2 min" |
| 35 | Screenshot | "Capturá la pantalla" |
| 37 | RAG | "¿Qué dice el contrato sobre...?" |
| 40/41 | Gastos | "Anotá 500 de super", "Resumen del mes" |
| 54 | Red | "¿Qué dispositivos hay en la red?" |
| 61 | Integridad | "Verificá que /etc no se modificó" |
| 73 | Inbox | "¿Tengo mails importantes?" |

---

## Detalle de skills Mobile (24)

| # | Skill | Ejemplo |
|---|---|---|
| M1 | SMS | "Enviá SMS a mamá" |
| M2 | Llamadas | "Llamá a Juan" |
| M3 | Cámara | "Sacá una foto" |
| M4 | GPS | "¿Dónde estoy?" |
| M5 | Contactos | "Agregá a María" |
| M6 | Notificaciones | "Leeme las notificaciones" |
| M7 | Sensores | "¿Cuántos pasos hoy?" |
| M8 | Portapapeles | "Copiá este texto" |
| M9 | Linterna | "Prendé la linterna" |
| M10 | WiFi/BT/Hotspot | "Compartí internet" |
| M11 | Sistema UI | "Bajá el brillo al 30%" |
| M12 | Apps | "Abrí WhatsApp" |
| M13 | Alarmas | "Poné alarma a las 7am" |
| M14 | Galería | "Mostrame las fotos de ayer" |
| M15 | QR Scanner | "Escaneá este QR" |
| M16 | Mapas | "Llevame a casa" |
| M17 | Salud | "¿Cómo dormí anoche?" |
| M18 | Browser | "Abrí youtube.com" |
| M19 | Remote PC | "Apagá la PC", "¿Qué hace la PC?" |
| M20 | Drive mode | Manos libres en auto |
| M21 | Notas | "Tomá nota: comprar pan" |
| M22 | Gastos | "Anotá 500 de super" |
| M23 | Timers | "Poné timer de 10 min" |
| M24 | Compartir | "Compartí esto por WhatsApp" |

---

## Mecanismo de sincronización

```
CELULAR (jarvis_mobile.db)          PC (jarvis.db)
─────────────────────────          ───────────────
Tablas locales:                    Tablas maestras:
  notas                              notas
  gastos                             gastos
  contactos                          contactos
  cola_sync (pendientes)             historial_conversacion
                                     memoria_aprendizaje
                                     rutinas
                                     preferencias

Sincronización:
1. PC prende → Tailscale conecta
2. Celu detecta PC online
3. sync_service.dart envía cola_sync
4. sync_engine.py mergea en DB maestra
5. PC envía confirmación + novedades (rutinas nuevas, cambios de preferencias)
6. Celu actualiza cache local
```

---

## Sistema Conversacional + Aprendizaje

### Motor de personalidad (`personality.py`)
7 tonos dinámicos: formal, estándar, casual, directo, sarcástico, empático, juguetón. Cambian según hora, frecuencia de uso y contexto.

### Memoria conversacional (`conversation_memory.py`)
- Corto plazo: últimos 20 mensajes
- Largo plazo: resúmenes semanales (gustos, preferencias, proyectos activos)
- Recuperable: "Jarvis, ¿qué me dijiste ayer sobre...?"

### Detección de ánimo (`mood_detector.py`)
Analiza velocidad de habla, tono de voz, palabras clave. Ajusta respuesta (empático si estás mal, directo si estás productivo).

### Aprendizaje continuo (`learning.py`)
- **Capa 1**: Aprende preferencias durante la conversación (música, ciudad, café/té)
- **Capa 2**: Corrige por feedback ("No, en Córdoba" → actualiza)
- **Capa 3**: Pregunta cuando detecta vacíos ("¿Prefiere té o café?")
- **Capa 4**: Aprende tu vocabulario ("chisme" = Telegram laboral)
- **Capa 5**: Nuevas rutinas por voz ("Aprendete esto: cuando diga modo creativo...")
- Consolidación nocturna: cada noche el LLM resume lo aprendido

### Sugerencias proactivas (`proactive.py`)
- Detecta patrones de uso y sugiere automatizaciones
- Recuerda deadlines y hábitos
- Cuida salud (descanso, hidratación)
- Reportes semanales
- Alertas climáticas y de contexto

---

## Fases de desarrollo

### Fase 1 — Core del servidor PC (12h)
```
server/main.py
server/core/
  jarvis_engine.py, wake_word.py, speech_to_text.py
  text_to_speech.py, brain.py, memory.py
  config_loader.py, privacy.py, context.py, tray.py
server/models/ (descarga de modelos)
server/memory/ (creación de DB)
```
**Objetivo**: "Jarvis, qué hora es?" → responde con TTS desde la PC. PC corre en segundo plano, solo ícono en bandeja.

### Fase 2 — Skills PC esenciales (12h)
```
server/skills/
  system.py, files.py, web.py, shell.py
  entertainment.py, routines.py, notes.py
  monitor.py, cleaner.py, organizer.py
  backup.py, pomodoro.py, scheduler.py
```
**Objetivo**: 12 skills funcionando desde PC.

### Fase 3 — Skills PC avanzados (10h)
```
server/skills/
  spotify.py, calendar.py, gmail.py, inbox.py
  telegram_bot.py, git_ops.py, speedtest.py
  desktop_control.py, screen_record.py, screenshot.py
  qrcode_gen.py, price_tracker.py, network_scan.py
  integrity.py, knowledge_base.py (RAG), expenses.py
```
**Objetivo**: 32 skills PC completos.

### Fase 4 — Servidor WebSocket + Dashboard opcional (4h)
```
server/web/
  server.py (FastAPI + WebSocket)
  templates/index.html (página mínima de debug)
```
**Objetivo**: API WebSocket funcional para cliente mobile. Dashboard opcional solo para debug.

### Fase 5 — Sistema conversacional + aprendizaje (12h)
```
server/core/
  personality.py, mood_detector.py
  conversation_memory.py, learning.py
  proactive.py (mejorado), session_manager.py
  sync_engine.py
```
**Objetivo**: Jarvis con personalidad, memoria, aprendizaje. Listo para multi-dispositivo.

### Fase 6 — App Flutter: base + conexión (8h)
```
mobile/
  pubspec.yaml, main.dart
  services/
    ws_client.dart, connection_manager.dart
    audio_recorder.dart, audio_player.dart
    wake_word.dart, tailscale.dart
    fallback_handler.dart
  models/message.dart
  ui/home.dart, settings.dart, theme/
```
**Objetivo**: App se conecta a PC vía Tailscale, stremea audio, reproduce TTS.

### Fase 7 — App Flutter: modo autónomo (8h)
```
mobile/services/
  local_stt.dart (whisper.cpp)
  local_tts.dart
  local_db.dart
  sync_service.dart
```
**Objetivo**: App funciona sin PC. Notas, gastos, alarmas locales.

### Fase 8 — Skills mobile esenciales (10h)
```
mobile/skills/
  sms.dart, phone.dart, camera.dart, location.dart
  contacts.dart, notifications.dart, flashlight.dart
  wifi_bt.dart, system_ui.dart, apps.dart, alarms.dart
  clipboard.dart
```
**Objetivo**: 12 skills mobile funcionando offline.

### Fase 9 — Skills mobile avanzados + integración (8h)
```
mobile/skills/
  sensors.dart, gallery.dart, qr_scanner.dart
  maps.dart, health.dart, remote_control.dart
  drive_mode.dart, browser.dart
mobile/ui/conversation.dart, widgets/arc_ring.dart
```
**Objetivo**: 24 skills mobile. App completa con UI estilo Jarvis.

### Fase 10 — Pruebas, sync, ajustes finales (6h)
```
- Pruebas de sync celu ↔ PC
- Pruebas de Tailscale en distintas redes
- Modo sigilo unificado
- Ajustes de latencia y consumo de batería
- Documentación (README.md)
```

---

## Tiempos totales

| Fase | Descripción | Horas |
|---|---|---|
| 1 | Core servidor PC | 12h |
| 2 | Skills PC esenciales | 12h |
| 3 | Skills PC avanzados | 10h |
| 4 | Servidor WebSocket + Dashboard opcional | 4h |
| 5 | Sistema conversacional + aprendizaje | 12h |
| 6 | App Flutter: base + conexión | 8h |
| 7 | App Flutter: modo autónomo | 8h |
| 8 | Skills mobile esenciales | 10h |
| 9 | Skills mobile avanzados + UI | 8h |
| 10 | Pruebas, sync, ajustes | 6h |
| **TOTAL** | | **~90 horas** |

**~5 semanas** en sesiones de 3-4 horas/día.

---

## Requisitos finales

### PC
- Linux (o WSL2)
- 16+ GB RAM
- Python 3.10+
- Ollama (`ollama pull llama3.1:8b`)
- Tailscale instalado
- Micrófono y parlantes

### Celular
- Android 8+ o iOS 14+
- Tailscale instalado
- 200 MB libres (modelos + app)

### Opcional
- GPU para más velocidad de LLM en PC
- 20+ GB disco si se indexan muchos documentos (RAG)

---

## Costos

| Concepto | Costo |
|---|---|
| Desarrollo | $0 (open source) |
| APIs externas | $0 (todo local) |
| Tailscale | $0 (hasta 3 dispositivos) |
| Servicios cloud | $0 |
| **Total** | **$0** |
