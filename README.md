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
- **Dashboard web** — Interfaz oscura estilo reactor arc (FastAPI + WebSockets)
- **App mobile** — Flutter (Android + iOS) con UI estilo Jarvis

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
| 4. Web Dashboard | 6h |
| 5. Sistema conversacional + aprendizaje | 12h |
| 6. App Flutter: base + conexión | 8h |
| 7. App Flutter: modo autónomo | 8h |
| 8. Skills mobile esenciales | 10h |
| 9. Skills mobile avanzados + UI | 8h |
| 10. Pruebas, sync, ajustes | 6h |
| **TOTAL** | **~92 horas (~5-6 semanas)** |

---

## Prompt para diseño UI (v0.dev, Galileo AI, Figma AI, DALL-E, etc.)

Copiá y pegá todo este bloque en una herramienta de diseño IA para generar las vistas:

```
Diseñame las interfaces completas de J.A.R.V.I.S., un asistente de voz 
IA tipo mayordomo británico estilo Tony Stark. App mobile Flutter + 
dashboard web PC. Oscuro, neón, reactor arc.

========== PALETA DE COLORES ==========
Fondo principal: #0A0E17 (azul casi negro)
Fondo secundario: #121826
Acento cian (reactor): #00D4FF
Acento naranja (alertas): #FF6B35
Texto principal: #E0E6ED
Texto secundario: #8892A4
Verde terminal: #00FF88
Rojo sigilo: #FF3366

========== TIPOGRAFÍA ==========
Títulos: Orbitron Bold
Cuerpo: Inter
Terminal: JetBrains Mono

========== ANIMACIONES ==========
- Partículas azules flotando en fondo (sutiles, opacidad 20-40%)
- Anillo reactor arc central pulsando según estado
- Ondas ecualizador que reaccionan a la voz
- Glow neón en bordes y acentos
- Transiciones 300ms ease-in-out

========== ESTADOS DEL ANILLO REACTOR ARC ==========
Azul suave = idle/escuchando
Blanco = wake word detectado
Naranja/ámbar = procesando/pensando
Cian = hablando (TTS)
Rojo = modo sigilo activo

========== 1. APP MOBILE — PANTALLA PRINCIPAL ==========
[SUPERIOR]
- Hora digital grande (Orbitron)
- Fecha debajo
- Clima en esquina superior derecha (ícono + temp)
- Puntito conexión: verde = PC online, gris = modo autónomo

[CENTRO]
- Anillo reactor arc animado (pulsación según estado)
- Última respuesta de Jarvis en texto dentro del anillo (fade out)
- Íconos de skills activos recientes debajo del anillo

[INFERIOR]
- Barra rápida: SIGILO | RUTINAS | NOTAS | AJUSTES
- Botón micrófono flotante abajo-centro

========== 2. APP MOBILE — HISTORIAL DE CONVERSACIÓN ==========
- Acceso: deslizar hacia arriba desde pantalla principal
- Lista tipo chat con burbujas:
  • Usuario: derecha, azul oscuro translúcido, bordes redondeados
  • Jarvis: izquierda, gris oscuro translúcido, bordes redondeados
- Timestamp chico debajo de cada burbuja
- Barra superior: "Conversación" + volver + borrar
- Input de texto abajo (alternativa a voz)

========== 3. APP MOBILE — AJUSTES ==========
Secciones:
- CONEXIÓN: IP server, estado Tailscale, dispositivos vinculados
- VOZ: selector voz (masculina/femenina británica), velocidad, volumen
- PERSONALIDAD: slider sarcasmo, slider formalidad, toggle conversacional
- PRIVACIDAD: toggle modo sigilo default, botón "Borrar memoria" (rojo)
- DATOS: tamaño DB, último sync, botón "Sincronizar ahora"

========== 4. WEB DASHBOARD PC — FULLSCREEN ==========
Layout 3 columnas:

[COLUMNA IZQUIERDA — ESTADO]
- Gráfico circular CPU (% + gradiente verde→rojo)
- Gráfico circular RAM (%)
- Gráfico circular Disco (%)
- Temperatura CPU, Uptime
- Estado servidor: ONLINE/OFFLINE

[COLUMNA CENTRAL — CONVERSACIÓN]
- "J.A.R.V.I.S. — Sistema Activo"
- Área conversación tipo terminal (texto verde neón #00FF88 sobre negro)
- Línea de tiempo con timestamps, auto-scroll
- Ecualizador de audio horizontal debajo
- Botón "Activar micrófono" / "Silenciar"

[COLUMNA DERECHA — DATOS]
- Tarjeta clima (ícono grande + temperatura)
- Próximos eventos calendario
- Últimas notas tomadas
- Resumen gastos del mes
- Dispositivos conectados (celu online/offline)
- Estado modo sigilo

[ENCABEZADO SUPERIOR]
- Logo "J.A.R.V.I.S." (Orbitron)
- Hora digital
- Navegación: Dashboard | Conversación | Skills | Ajustes

========== REFERENCIAS VISUALES ==========
- UI de Iron Man (Marvel) — pantallas holográficas azules
- HUD películas — Minority Report, Oblivion
- Interfaces cyberpunk oscuras con neón

El asistente tiene 56 skills (32 PC, 24 celu). Es conversacional con 
personalidad británica, sarcasmo, memoria y aprendizaje continuo. 
Se comunica via Tailscale VPN. Todo local, $0, open source.
```

---

## Licencia

MIT — 100% open source.

# JARVIS
