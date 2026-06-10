# J.A.R.V.I.S. — Asistente de Voz IA Estilo Tony Stark

Asistente personal de IA 100% open source, gratuito, local. Celular como núcleo siempre activo + PC como potencia extra cuando está prendida.

---

## Características

- **56 skills** (32 en PC, 24 en celular)
- **Siempre disponible** — El celu funciona autónomo sin la PC prendida
- **Conversacional** — Con personalidad, memoria, aprendizaje continuo y detección de ánimo
- **Sincronización automática** — Celu y PC comparten la misma cuenta via Tailscale
- **Privacidad total** — Todo local, $0, sin APIs cloud
- **Modo sigilo** — No guarda audio, no loguea, no escribe DB
- **PC en segundo plano** — Corre como daemon, solo un ícono en la bandeja del sistema que cambia de color
- **App mobile** — Flutter (Android + iOS), UI minimalista: solo un anillo flotante que pulsa y reacciona

---

## Arquitectura

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

## Stack tecnológico

| Componente | Celular | PC |
|---|---|---|
| Wake word | Porcupine (~20 MB) | OpenWakeWord (~200 MB) |
| STT | whisper.cpp tiny (~50 MB) | faster-whisper (~1 GB) |
| Cerebro | Llama 3.2 1B (opcional) | Ollama + Llama 3.1 8B |
| TTS | Nativo Android/iOS | Edge-TTS |
| DB | SQLite local | SQLite maestra |
| RAG | — | ChromaDB + sentence-transformers |
| Comunicación | Tailscale VPN ($0) | Tailscale VPN ($0) |
| App mobile | Flutter (Android + iOS) | — |
| Server | — | FastAPI + WebSockets |
| Dashboard | — | FastAPI + Jinja2 |
| **Costo total** | **$0** | **$0** |

---

## Skills

### PC (32 skills)
Sistema, Archivos, Web/Clima, Shell, Spotify, Calendario, Gmail, Entretenimiento, Rutinas, Pomodoro, Monitoreo, Limpieza, Organizador, Backup, Notas, Speedtest, Telegram, Git, QR Code, Monitoreo Precios, Scheduler, Control Escritorio, Grabar Pantalla, Screenshot, RAG, Gastos, Red Local, Integridad, Inbox

### Celular (24 skills)
SMS, Llamadas, Cámara, GPS, Contactos, Notificaciones, Sensores, Portapapeles, Linterna, WiFi/BT/Hotspot, Sistema UI, Apps, Alarmas, Galería, QR Scanner, Mapas, Salud, Browser, Remote PC, Drive Mode, Notas, Gastos, Timers, Compartir

---

## Sistema conversacional + Aprendizaje

- **7 tonos dinámicos**: formal, estándar, casual, directo, sarcástico, empático, juguetón
- **Memoria a corto y largo plazo**: recuerda conversaciones, gustos, proyectos
- **Detección de ánimo**: ajusta respuesta según cómo hablás
- **Aprendizaje continuo**: aprende preferencias, vocabulario, rutinas sin configuración manual
- **Proactivo**: sugiere automatizaciones, recuerda deadlines, cuida tu salud

---

## Requisitos

### PC
- Linux (o WSL2), 16+ GB RAM, Python 3.10+
- [Ollama](https://ollama.com) (`ollama pull llama3.1:8b`)
- [Tailscale](https://tailscale.com) instalado
- Micrófono y parlantes

### Celular
- Android 8+ o iOS 14+
- [Tailscale](https://tailscale.com) instalado
- 200 MB libres

---

## Instalación

```bash
# 1. Dependencias del sistema
sudo apt install python3-pip python3-venv portaudio19-dev \
  ffmpeg ollama arp-scan

# 2. Clonar y crear entorno
git clone https://github.com/tuusuario/jarvis.git
cd jarvis
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Bajar modelos
ollama pull llama3.1:8b

# 4. Ejecutar servidor
cd server
python main.py

# 5. App mobile
cd mobile
flutter pub get
flutter run
```

---

## Costos

| Concepto | Costo |
|---|---|
| Desarrollo | $0 (open source) |
| APIs externas | $0 (todo local) |
| Tailscale | $0 (hasta 3 dispositivos) |
| **Total** | **$0** |

---

## Tiempo de desarrollo estimado

| Fase | Horas |
|---|---|
| 1. Core servidor PC | 12h |
| 2. Skills PC esenciales | 12h |
| 3. Skills PC avanzados | 10h |
| 4. Servidor WebSocket + Dashboard opcional | 4h |
| 5. Sistema conversacional + aprendizaje | 12h |
| 6. App Flutter: base + conexión | 8h |
| 7. App Flutter: modo autónomo | 8h |
| 8. Skills mobile esenciales | 10h |
| 9. Skills mobile avanzados + UI | 8h |
| 10. Pruebas, sync, ajustes | 6h |
| **TOTAL** | **~90 horas (~5 semanas)** |

---

## Diseño UI

Jarvis es discreto. No invade. Está ahí y reacciona cuando le hablás.

### App Mobile
- Fondo: degradé azul muy oscuro a negro (#0A0E17 → #000000)
- Partículas azules flotando MUY sutiles (opacidad 10-15%)
- Centro: anillo flotante (~120px) con glow, cambia según estado
- Debajo del anillo: texto de respuesta con fade suave
- Toque largo = activar micrófono manual
- Esquina superior derecha: puntito verde (PC online) o gris (offline)
- Esquina superior izquierda: puntito rojo (modo sigilo activo)

Estados del anillo:
- Azul cian (#00D4FF) = idle, pulso lento cada 3s, gira suave
- Blanco = wake word detectado, expansión rápida
- Naranja (#FF6B35) = pensando, anillos concéntricos girando
- Verde (#00FF88) = hablando, expansión/contracción rítmica
- Rojo (#FF3366) = modo sigilo, opaco, pulso mínimo
- Gris = sin conexión

### PC (segundo plano)
- Sin ventana. Corre como daemon de fondo.
- Solo un ícono en la bandeja del sistema (16x16 o 24x24)
- Mismos colores que el anillo mobile según estado
- Click derecho: Activar micrófono | Modo sigilo | Salir

### Prompt para generar las vistas (v0.dev, Galileo AI, Figma AI, etc.)

```
Diseñame la UI de J.A.R.V.I.S., asistente de voz IA tipo mayordomo 
británico. Minimalista. Dos interfaces: mobile con anillo flotante, 
y PC en segundo plano con ícono en bandeja del sistema.

========== APP MOBILE ==========
- Fondo: degradé azul muy oscuro a negro (#0A0E17 → #000000)
- Partículas azules flotando MUY sutiles (opacidad 10-15%)
- Centro: anillo flotante (~120px) con glow cian suave (#00D4FF)
- Debajo del anillo: texto de respuesta con fade suave
- Toque largo = activar micrófono manual
- Esquina superior derecha: puntito verde (PC online) o gris (offline)
- Esquina superior izquierda: puntito rojo (modo sigilo activo)

Estados del anillo:
- Idle: azul cian, pulso lento cada 3s, gira suave
- Wake word: expansión rápida 20%, glow blanco
- Escuchando: micropulsaciones reaccionando a la voz
- Pensando: anillos concéntricos naranja (#FF6B35) girando
- Hablando: verde cian (#00FF88), expansión/contracción rítmica
- Skill ejecutando: destello rápido según tipo (SMS=verde, cámara=flash)
- Sigilo: rojo suave (#FF3366), opaco, pulso mínimo
- Error: titila blanco 2 veces
- Offline: gris azulado opaco

========== PC — SYSTEM TRAY (SEGUNDO PLANO) ==========
- Sin ventana. Sin dashboard. Corre de fondo como daemon.
- Solo un ícono en la bandeja del sistema (16x16 o 24x24)
- Mismos colores que el anillo mobile según estado
- Click derecho en el ícono:
    Activar micrófono | Modo sigilo | Salir

========== COLORES ==========
Fondo: #0A0E17
Cian idle: #00D4FF
Blanco wake: #FFFFFF
Naranja pensar: #FF6B35
Verde hablar: #00FF88
Rojo sigilo: #FF3366
Gris offline: #5A6A7A
Texto: #E0E6ED
Tipografía: Inter

========== REFERENCIA ==========
Algo etéreo, como el anillo de Cortana pero más oscuro y discreto.
La vibra de un mayordomo británico que está ahí sin molestar.
```

---

## Licencia

MIT — 100% open source.
