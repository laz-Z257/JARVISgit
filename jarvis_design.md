# J.A.R.V.I.S. — Diseño de Arquitectura y UI

---

## 1. Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                        CASA (LAN)                               │
│                                                                 │
│  ┌────────────────────────┐      ┌──────────────────────────┐   │
│  │       CELULAR          │      │          PC               │   │
│  │      (24/7 ON)         │      │    (Cuando se prende)     │   │
│  │                        │      │                          │   │
│  │  ┌──────────────────┐  │      │  ┌────────────────────┐  │   │
│  │  │  Wake Word (PPN) │  │      │  │  Wake Word (OWW)   │  │   │
│  │  │  Porcupine 20MB  │  │      │  │  OpenWakeWord 200MB│  │   │
│  │  └────────┬─────────┘  │      │  └────────┬───────────┘  │   │
│  │           │            │      │           │              │   │
│  │  ┌────────▼─────────┐  │      │  ┌────────▼───────────┐  │   │
│  │  │  STT Local        │  │      │  │  STT               │  │   │
│  │  │  whisper.cpp tiny │  │      │  │  faster-whisper    │  │   │
│  │  │  ~50MB            │  │      │  │  ~1GB              │  │   │
│  │  └────────┬─────────┘  │      │  └────────┬───────────┘  │   │
│  │           │            │      │           │              │   │
│  │  ┌────────▼─────────┐  │      │  ┌────────▼───────────┐  │   │
│  │  │  LLM Local (opt) │  │      │  │  Brain             │  │   │
│  │  │  Llama 3.2 1B    │  │      │  │  Ollama + Llama    │  │   │
│  │  │  ~1GB            │  │      │  │  3.1 8B ~5-6GB     │  │   │
│  │  └────────┬─────────┘  │      │  └────────┬───────────┘  │   │
│  │           │            │      │           │              │   │
│  │  ┌────────▼─────────┐  │      │  ┌────────▼───────────┐  │   │
│  │  │  Skills Locales   │  │      │  │  Skills PC (32)    │  │   │
│  │  │  SMS, GPS, Cámara │  │      │  │  Shell, Spotify,   │  │   │
│  │  │  Contactos, etc   │  │      │  │  Gmail, RAG, etc   │  │   │
│  │  │  (24 skills)      │  │      │  │  (32 skills)       │  │   │
│  │  └────────┬─────────┘  │      │  └────────┬───────────┘  │   │
│  │           │            │      │           │              │   │
│  │  ┌────────▼─────────┐  │      │  ┌────────▼───────────┐  │   │
│  │  │  DB Local         │  │      │  │  DB Maestra        │  │   │
│  │  │  jarvis_mobile.db │  │      │  │  jarvis.db         │  │   │
│  │  │  SQLite           │  │      │  │  SQLite + ChromaDB │  │   │
│  │  └────────┬─────────┘  │      │  └────────┬───────────┘  │   │
│  │           │            │      │           │              │   │
│  └───────────┼────────────┘      └───────────┼──────────────┘   │
│              │                               │                  │
│              └──────────Tailscale VPN─────────┘                  │
│                         (WireGuard)                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                      INTERNET                             │
│  Spotify API · Gmail SMTP/IMAP · Telegram Bot API         │
│  Open-Meteo · DuckDuckGo · Google Calendar API            │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Flujo de Ejecución

```
─── CELULAR CONECTADO A PC ───

  [Micrófono]
      │
      ▼
  ┌──────────────┐     ┌─────────────────┐
  │ Wake Word    │────→│ ¿Detectó        │
  │ (Porcupine)  │  no │ "Jarvis"?       │
  └──────────────┘     └────────┬────────┘
                               │ sí
                               ▼
  ┌──────────────────────────────────┐
  │  Vibra · Muestra anillo azul     │
  │  Envía audio chunks vía WS       │
  └──────────────┬───────────────────┘
                 │ WebSocket (Tailscale)
                 ▼
         ┌──────────────────┐
         │   Servidor PC     │
         │   main.py         │
         └────────┬─────────┘
                  │
          ┌───────▼────────┐
          │  STT (Whisper)  │
          │  audio → texto  │
          └───────┬────────┘
                  │ texto
          ┌───────▼────────┐
          │  Brain (Ollama) │
          │  texto → intent │
          └───────┬────────┘
                  │
          ┌───────▼────────┐
          │  Router Skills  │
          │  ¿Qué skill?    │
          └───────┬────────┘
                  │
         ┌────────┴────────┐
         ▼                  ▼
  ┌────────────┐   ┌──────────────┐
  │  Skill PC   │   │  Skill Mobile │
  │  (ej: clima)│   │  (ej: SMS)    │
  └─────┬──────┘   │  puente WS    │
        │          └──────┬───────┘
        ▼                 │
  ┌────────────┐          │
  │  Respuesta  │◄────────┘
  │  texto      │
  └─────┬──────┘
        │
  ┌─────▼──────┐
  │  TTS       │
  │  Edge-TTS  │
  └─────┬──────┘
        │ audio
        ▼
  [Parlantes / Auriculares]


─── CELULAR MODO AUTÓNOMO (PC APAGADA) ───

  [Wake Word] → [STT local whisper.cpp] → [Skills locales]
  → [TTS nativo SO] → [Guarda en SQLite local]
  → [Cuando PC prende: sync automático via Tailscale]
```

---

## 3. Máquina de Estados del Asistente

```
                    ┌──────────────────────────────────────┐
                    │                                      │
                    ▼                                      │
            ┌──────────────┐                              │
    ┌──────→│    IDLE      │──────┐                       │
    │       │  Anillo azul │      │                       │
    │       │  Pulso 3s    │      │ wake word             │
    │       └──────────────┘      ▼                       │
    │                            ┌──────────────────┐     │
    │                            │  WAKE_DETECTED    │     │
    │                            │  Anillo blanco    │     │
    │                            │  Expansión rápida │     │
    │                            └────────┬─────────┘     │
    │                                     │               │
    │                                     ▼               │
    │                            ┌──────────────────┐     │
    │  ┌─────────────────────────│   LISTENING      │     │
    │  │                        │  Anillo azul      │     │
    │  │                        │  Micro-pulsos     │     │
    │  │                        └────────┬─────────┘     │
    │  │    timeout 10s                  │               │
    │  │    sin audio                    │ fin audio     │
    │  │    ◄────────────────────────────┘               │
    │  │                                                 │
    │  ▼                                                 │
    │  ┌──────────────────┐                              │
    │  │   PROCESSING     │                              │
    │  │  Anillo naranja  │                              │
    │  │  Anillos conc.   │                              │
    │  │  Girando         │                              │
    │  └────────┬─────────┘                              │
    │           │                                        │
    │           ▼                                        │
    │  ┌──────────────────┐                              │
    │  │   SPEAKING       │                              │
    │  │  Anillo verde    │                              │
    │  │  Ritmo voz       │                              │
    │  └────────┬─────────┘                              │
    │           │ fin TTS                                │
    │           └────────────────────────────────────────┘
    │
    │  ┌──────────────────┐
    │  │   ERROR          │
    │  │  Anillo blanco   │
    │  │  Titila 2 veces  │
    │  └──────────────────┘
    │
    │  ┌──────────────────┐
    │  │   STEALTH        │
    │  │  Anillo rojo     │
    │  │  Opaco, pulso mín│
    │  └──────────────────┘
    │
    │  ┌──────────────────┐
    │  │   OFFLINE        │
    │  │  Anillo gris     │
    │  └──────────────────┘
    │
    │  Estados pausa:
    │  ┌──────────────────┐
    │  │   AWAITING_SKILL │ ← cuando un skill necesita confirmación
    │  │  Ej: "¿Ejecuto   │     "¿Está seguro?""
    │  │  este comando?"  │
    │  └──────────────────┘
    │
    └─────────────────────────────────────────────────────

  Transiciones:
  ┌────────────────────────────────────────────────────┐
  │ IDLE → WAKE_DETECTED     (wake word detectado)      │
  │ WAKE_DETECTED → LISTENING (empieza a grabar)        │
  │ LISTENING → PROCESSING   (usuario dejó de hablar)   │
  │ PROCESSING → SPEAKING    (respuesta lista)          │
  │ SPEAKING → IDLE          (TTS terminó)              │
  │ LISTENING → IDLE         (timeout sin audio)        │
  │ PROCESSING → ERROR       (falló STT/LLM/skill)      │
  │ ERROR → IDLE             (2 seg)                    │
  │ IDLE → STEALTH           ("modo sigilo")            │
  │ STEALTH → IDLE           ("volvé" / "modo normal")  │
  │ IDLE → OFFLINE           (sin conexión a PC)        │
  │ OFFLINE → IDLE           (PC conectada)             │
  │ SPEAKING → LISTENING     (interrupción por voz)     │
  └────────────────────────────────────────────────────┘
```

---

## 4. UI Mobile — Wireframes

### 4.1 Home — Pantalla Principal

```
┌─────────────────────────────────────┐
│  ●                          ●      │ ← Esquina izq: Rojo (sigilo activo)
│                                     │   Esquina der: Verde (PC online)
│                                     │                 Gris (PC offline)
│                                     │
│                                     │
│              ╭─────────╮            │
│             ╱           ╲           │
│            │    ◉ ◉ ◉    │          │ ← Anillo flotante ~120px
│            │   ◉◉◉◉◉    │          │   Color según estado
│             ╲    ◉    ╱            │   Glow suave
│              ╰─────────╯            │
│                                     │
│        ┌─────────────────┐          │
│        │  Buenos días,    │          │ ← Texto respuesta
│        │  señor. ¿En qué  │          │   Fade suave
│        │  puedo ayudarle? │          │   Alineado centro
│        └─────────────────┘          │
│                                     │
│                                     │
│                                     │
│                                     │
│      [ Toque largo = hablar ]       │ ← Hint inferior
│                                     │
└─────────────────────────────────────┘

  Fondo: degradé #0A0E17 → #000000
  Partículas: azules opacidad 10-15%
  Tipografía: Inter
  Texto estático: #E0E6ED
```

### 4.2 Conversación — Historial

```
┌─────────────────────────────────────┐
│  ← Atrás      Historial             │ ← Header
├─────────────────────────────────────┤
│                                     │
│  ┌────────────────────────────┐     │
│  │  ¿Qué clima hace?          │     │ ← Burbuja usuario
│  └────────────────────────────┘     │   Alineada derecha
│                                     │
│  ┌────────────────────────────────┐ │
│  │  Buenos días, señor. Hoy      │ │ ← Burbuja Jarvis
│  │  22°C y soleado en Córdoba.   │ │   Alineada izquierda
│  └────────────────────────────────┘ │   Borde sutil cian
│                                     │
│  ┌────────────────────────────┐     │
│  │  Reproducir música         │     │
│  └────────────────────────────┘     │
│                                     │
│  ┌────────────────────────────────┐ │
│  │  ¿Qué género prefiere,         │ │
│  │  señor?                        │ │
│  └────────────────────────────────┘ │
│                                     │
│                                     │
│                                     │
│                                     │
│  ┌──────────────────────────────┐   │
│  │  Escribí un mensaje...    ▶️  │   │ ← Input inferior
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 4.3 Settings

```
┌─────────────────────────────────────┐
│  ← Atrás        Configuración       │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🎤 Wake Word              │    │
│  │  ─────────────────────     │    │
│  │  Sensibilidad: [═══●═══]   │    │ ← Slider
│  │  Palabra: "Jarvis"         │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🗣️ Voz / TTS              │    │
│  │  ─────────────────────     │    │
│  │  Voz: Elena (es-AR)        │    │
│  │  Velocidad: [●───────]     │    │
│  │  Volumen:  [━━━━━●───]     │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🧠 Personalidad            │    │
│  │  ─────────────────────     │    │
│  │  Tono: Estándar     ▼      │    │ ← Selector
│  │  Tono adaptativo: [ON]     │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🔒 Privacidad              │    │
│  │  ─────────────────────     │    │
│  │  Modo sigilo:      [OFF]   │    │
│  │  Guardar audio:   [OFF]    │    │
│  │  Guardar historial:[ON]    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🔗 Conexión               │    │
│  │  ─────────────────────     │    │
│  │  PC: ● Conectado           │    │
│  │  Tailscale: 100.x.x.x      │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  💾 Datos / Sync           │    │
│  │  ─────────────────────     │    │
│  │  Sync automático:  [ON]    │    │
│  │  Último sync: hoy 10:30    │    │
│  │  [ Forzar sync ]           │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

### 4.4 Estados del Anillo (ArcRing)

```
IDLE (azul cian #00D4FF)
  ╭─────────╮
  │  ○   ○   │  Pulso lento cada 3s
  │    ○     │  Rotación suave horaria
  │  ○   ○   │  Glow suave 10px
  ╰─────────╯

WAKE WORD (blanco #FFFFFF)
  ╭─────────╮
  │  ◉   ◉   │  Expansión rápida 20%
  │    ◉     │  Brillo máximo
  │  ◉   ◉   │  Glow blanco 20px
  ╰─────────╯

LISTENING (azul cian #00D4FF)
  ╭─────────╮
  │  ◉ ● ◉   │  Micro-pulsaciones
  │  ● ◉ ●   │  Reacciona a la voz
  │  ◉ ● ◉   │  Intensidad variable
  ╰─────────╯

PROCESSING (naranja #FF6B35)
  ╭─────────╮
  │  ◉   ◉   │  Anillos concéntricos
  │    ◉     │  Giran rápido
  │  ◉   ◉   │  2 anillos rotando
  ╰─────────╯

SPEAKING (verde #00FF88)
  ╭─────────╮
  │  ◉   ◉   │  Expansión/contracción
  │    ◉     │  Rítmico con la voz
  │  ◉   ◉   │  Glow verde suave
  ╰─────────╯

STEALTH (rojo #FF3366)
  ╭─────────╮
  │  ○   ○   │  Opaco
  │    ○     │  Pulso mínimo
  │  ○   ○   │  Sin glow
  ╰─────────╯

ERROR (blanco #FFFFFF)
  ╭─────────╮
  │  ◉   ◉   │  Titila 2 veces
  │    ◉     │  Vuelve a idle
  │  ◉   ◉   │
  ╰─────────╯

OFFLINE (gris #5A6A7A)
  ╭─────────╮
  │  ○   ○   │  Sin animación
  │    ○     │  Opaco
  │  ○   ○   │  Sin glow
  ╰─────────╯

ANIMACIONES CLAVE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
○ → ○  idle: translateY(0) → translateY(-5px) → translateY(0), 3s
◉ → ◉  wake: scale(1) → scale(1.2) → scale(1), 0.3s
● → ●  listening: opacity varía con RMS del audio
◉ → ◉  processing: rotate(0deg) → rotate(360deg), 1s
◉ → ◉  speaking: scale(1) ↔ scale(1.15) al ritmo del TTS
○ → ○  stealth: opacity(0.3) → opacity(0.5) → opacity(0.3), 4s
◉ → ◉  error: opacity(1)→opacity(0)→opacity(1)→opacity(0), 0.4s
```

---

## 5. Flujo de Sincronización

```
CELULAR                              PC
───────                              ──

jarvis_mobile.db                     jarvis.db
────────────────                     ─────────
                                     │
  [PC se prende]                     │
       │                             │
       │ Tailscale conecta           │
       ▼                             │
  ┌──────────────┐                   │
  │ detecta PC    │                   │
  │ online        │                   │
  └──────┬───────┘                    │
         │                            │
         │ GET /sync/status           │
         ├───────────────────────────→│
         │ ← {version: 42,            │
         │     pendientes: 5}         │
         │                            │
         │ POST /sync/push            │
         │ {cola_sync: [...]}         │
         ├───────────────────────────→│
         │                            │
         │           ┌────────────────┴────┐
         │           │ mergea en DB maestra│
         │           │ resuelve conflictos │
         │           └────────────────┬────┘
         │                            │
         │ ← {ok: true,               │
         │     novedades: {...}}       │
         │                            │
  ┌──────┴──────┐                     │
  │ actualiza    │                     │
  │ cache local  │                     │
  └──────┬──────┘                     │
         │                            │
  ┌──────┴──────┐                     │
  │ limpia       │                     │
  │ cola_sync    │                     │
  └─────────────┘                      │

  REGLAS DE CONFLICTO:
  ┌──────────────────────────────────────────┐
  │ ● Última escritura gana (por timestamp)   │
  │ ● Notas y gastos: merge por ID único      │
  │ ● Preferencias: PC tiene prioridad        │
  │ ● Contactos: celu tiene prioridad         │
  │ ● Sync es bidireccional en cada tabla     │
  └──────────────────────────────────────────┘
```

---

## 6. Arquitectura de Skills (Plugin System)

```
┌──────────────────────────────────────┐
│           jarvis_engine.py            │
│         Orquestador principal         │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────┐
│         Skill Registry               │
│                                      │
│  skills = {                          │
│    "system": SystemSkill(),          │
│    "shell": ShellSkill(),            │
│    "spotify": SpotifySkill(),        │
│    "sms": SMSSkill(),                │
│    "camera": CameraSkill(),          │
│    ...                              │
│  }                                   │
│                                      │
│  def execute(skill_name, action,     │
│              params):                │
│    skill = skills[skill_name]        │
│    return skill.handle(action,params)│
└────────────────┬─────────────────────┘
                 │
        ┌────────┴────────┐
        ▼                  ▼
┌──────────────┐   ┌──────────────┐
│  Skills PC    │   │ Skills Mobile │
│              │   │              │
│ system.py    │   │ sms.py       │
│ files.py     │   │ phone.py     │
│ web.py       │   │ camera.py    │
│ shell.py     │   │ location.py  │
│ spotify.py   │   │ contacts.py  │
│ ...          │   │ ...          │
│              │   │              │
│ Heredan de:  │   │ Llamadas vía │
│ BaseSkill    │   │ WebSocket    │
│              │   │ a mobile     │
└──────────────┘   └──────────────┘

  ┌─────────────────────────────────────┐
  │  Interfaz BaseSkill                 │
  │                                     │
  │  class BaseSkill:                   │
  │      name: str                      │
  │      description: str               │
  │      required_permissions: []       │
  │      timeout: int                   │
  │                                     │
  │      def handle(action, params)     │
  │      def get_actions() → []         │
  │      def validate_params(params)    │
  └─────────────────────────────────────┘
```

---

## 7. Mapa de Colores (Design System)

```
FONDO
  Degradé principal:  #0A0E17 → #000000
  Superficie/elevada: #131A26
  Borde sutil:        #1E293B

TEXTO
  Primario:  #E0E6ED
  Secundario:#94A3B8
  Énfasis:   #00D4FF (cian)

ACENTOS (por estado del anillo)
  Idle:      #00D4FF (cian)
  Wake word: #FFFFFF (blanco)
  Pensando:  #FF6B35 (naranja)
  Hablando:  #00FF88 (verde)
  Sigilo:    #FF3366 (rojo)
  Offline:   #5A6A7A (gris)
  Error:     #FFFFFF (blanco)

BURBUJAS DE CHAT
  Usuario:   #1E293B + borde #334155
  Jarvis:    #0F172A + borde #00D4FF 30%

NOTIFICACIONES
  Éxito:     #00FF88
  Error:     #FF3366
  Info:      #00D4FF
  Alerta:    #FFB800

TIPOGRAFÍA
  Familia:   Inter
  Cuerpo:    16px regular
  Título:    20px semibold
  Énfasis:   14px medium
  Etiqueta:  12px regular
```

---

## 8. Protocolo WebSocket — Mensajes Detallados

### Cliente → Servidor (Celular → PC)

```json
{
  "type": "wake_word_detected",
  "session_id": "uuid-abc-123",
  "timestamp": "2025-01-15T10:30:00Z"
}

{
  "type": "audio_chunk",
  "session_id": "uuid-abc-123",
  "data": "<base64 audio>",
  "seq": 1,
  "timestamp": "2025-01-15T10:30:01Z"
}

{
  "type": "audio_end",
  "session_id": "uuid-abc-123",
  "duration_ms": 3200,
  "timestamp": "2025-01-15T10:30:04Z"
}

{
  "type": "cancel",
  "session_id": "uuid-abc-123",
  "reason": "user_cancelled"
}

{
  "type": "skill_result",
  "skill": "sms",
  "action": "send",
  "result": "success",
  "data": {"message_id": 42}
}

{
  "type": "mood_detected",
  "mood": "happy",
  "confidence": 0.87
}
```

### Servidor → Cliente (PC → Celular)

```json
{
  "type": "listening",
  "session_id": "uuid-abc-123",
  "state": "listening"
}

{
  "type": "thinking",
  "session_id": "uuid-abc-123",
  "state": "thinking"
}

{
  "type": "tts_audio",
  "session_id": "uuid-abc-123",
  "text": "Buenos días, señor.",
  "data": "<base64 audio>",
  "format": "mp3",
  "seq": 1,
  "duration_ms": 1500
}

{
  "type": "skill_executing",
  "skill": "spotify",
  "action": "play",
  "status": "started"
}

{
  "type": "speaking_end",
  "session_id": "uuid-abc-123"
}

{
  "type": "status",
  "state": "idle|listening|thinking|speaking",
  "info": {
    "cpu": 23,
    "ram_used": 4.2,
    "pc_online": true
  }
}

{
  "type": "error",
  "session_id": "uuid-abc-123",
  "code": "stt_failed",
  "message": "No se pudo transcribir el audio"
}

{
  "type": "sync_available",
  "version": 42
}

{
  "type": "proactive_suggestion",
  "text": "Señor, su disco está al 85%. ¿Ejecuto limpieza?",
  "actions": ["yes", "no", "later"]
}
```

---

## 9. Stack Completo — Diagrama de Capas

```
┌────────────────────────────────────────────────────────────┐
│                    INTERFAZ DE USUARIO                      │
│  ┌──────────────────┐     ┌────────────────────────────┐   │
│  │  App Mobile       │     │  PC System Tray            │   │
│  │  Flutter          │     │  pystray (ícono bandeja)   │   │
│  │  Ring UI + Chat   │     │  Mismos colores de estado  │   │
│  └────────┬─────────┘     └──────────────┬─────────────┘   │
│           │                               │                │
├───────────┼───────────────────────────────┼────────────────┤
│           │         WEB SOCKET            │                │
│           ▼                               ▼                │
│  ┌────────────────────────────────────────────────────┐    │
│  │              CAPA DE COMUNICACIÓN                   │    │
│  │  FastAPI + WebSockets + Tailscale (WireGuard)      │    │
│  │  Mensajes JSON · Sessions · Reconnection · Auth    │    │
│  └────────────────────────┬───────────────────────────┘    │
│                           │                                 │
├───────────────────────────┼─────────────────────────────────┤
│                           ▼                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │              ORQUESTADOR (jarvis_engine)            │    │
│  │  Router de skills · Contexto · Privacidad · Logging │    │
│  └───────┬──────────┬──────────┬───────────┬──────────┘    │
│           │          │          │           │               │
│           ▼          ▼          ▼           ▼               │
│  ┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ STT    │ │ Brain     │ │ Skills   │ │ TTS      │        │
│  │ Whisper│ │ Ollama    │ │ 56 total │ │ Edge-TTS │        │
│  └────────┘ └──────────┘ └──────────┘ └──────────┘        │
│                           │                                 │
│                           ▼                                 │
│  ┌────────────────────────────────────────────────────┐    │
│  │              CAPA DE DATOS                          │    │
│  │  SQLite (relacional) + ChromaDB (vectores RAG)     │    │
│  │  Memoria · Preferencias · Sync Queue · Skills      │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────┘
```

---

## 10. Diagrama de Base de Datos (Relaciones)

```
┌──────────────┐       ┌──────────────────┐
│   sessions   │       │  conversations   │
├──────────────┤       ├──────────────────┤
│ id (PK)      │       │ id (PK)          │
│ device_type  │──────→│ session_id (FK)  │
│ device_name  │       │ role             │
│ connected_at │       │ content          │
│ last_seen    │       │ mood             │
│ active       │       │ tone_used        │
└──────────────┘       │ timestamp        │
                       │ synced           │
                       └──────────────────┘
                              │
                              │ (resúmenes semanales)
                              ▼
                       ┌──────────────────┐
                       │ memory_long_term │
                       ├──────────────────┤
                       │ id (PK)          │
                       │ week_start       │
                       │ summary          │
                       │ preferences (JSON)│
                       │ projects (JSON)  │
                       └──────────────────┘

┌──────────────────┐    ┌──────────────────┐
│   notes          │    │   expenses       │
├──────────────────┤    ├──────────────────┤
│ id (PK)          │    │ id (PK)          │
│ content          │    │ amount           │
│ category         │    │ category         │
│ created_at       │    │ description      │
│ synced           │    │ date             │
└──────────────────┘    │ synced           │
                        └──────────────────┘

┌──────────────────┐    ┌──────────────────────┐
│   routines       │    │ learned_preferences  │
├──────────────────┤    ├──────────────────────┤
│ id (PK)          │    │ id (PK)              │
│ name             │    │ key (UNIQUE)          │
│ actions (JSON)   │    │ value                │
│ trigger          │    │ source               │
│ active           │    │ confidence           │
│ created_at       │    │ updated_at           │
└──────────────────┘    └──────────────────────┘

┌──────────────────┐    ┌──────────────────┐
│   sync_queue     │    │  skill_states    │
├──────────────────┤    ├──────────────────┤
│ id (PK)          │    │ id (PK)          │
│ table_name       │    │ skill_name       │
│ record_id        │    │ state (JSON)     │
│ action           │    │ updated_at       │
│ data (JSON)      │    └──────────────────┘
│ synced           │
│ created_at       │    ┌──────────────────┐
└──────────────────┘    │  mood_history    │
                        ├──────────────────┤
                        │ id (PK)          │
                        │ mood             │
                        │ confidence       │
                        │ trigger_phrase   │
                        │ timestamp        │
                        └──────────────────┘
```
