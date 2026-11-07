<div align="center">

# Lamha — Instant Selection Translator for macOS

**Lightweight, ultra-fast native macOS utility & browser extension that translates any text selected with your mouse or trackpad.**

[![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-E11D48?style=flat-square&logo=apple)](https://github.com/Binhanaa/LamhaTranslate)
[![Swift](https://img.shields.io/badge/Swift-5.10%20%7C%206.0-F05138?style=flat-square&logo=swift)](https://swift.org)
[![Developer](https://img.shields.io/badge/Developer-%40Binhanaa-181717?style=flat-square&logo=github)](https://github.com/Binhanaa)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E?style=flat-square)](LICENSE)

</div>

---

## ✨ Key Features

- **⚡ Zero-Latency Pre-Fetched Translation**: The moment you select text with your mouse or trackpad, Lamha pre-warms the macOS Accessibility tree on mouse-down and begins translating in the background immediately—so clicking or hovering the floating trigger badge opens the finished translation in **0 ms**.
- **🌓 Native Dark Mode & White Mode Glass Window**:
  - Automatically adapts to your macOS appearance (or manual override): renders a crisp, clear **Dark Glass** window in Dark Mode and a clean, slightly translucent **White Glass** window in Light Mode.
- **🎯 Minimal Header-Only Floating Card & Circular Flag Switcher**:
  - Zero bottom footer clutter.
  - Symmetrical `24×24` circular header controls (`Close`, `Settings`, `Listen / TTS`, `Copy`) opposite a matching `24×24` **Circular Flag Button** that switches target languages on click.
- **🌍 Automatic System Language Detection + 16 Global Languages (`RTL` / `LTR`)**:
  - Automatically detects and matches your macOS system language on launch, with manual selection across **16 languages**: Arabic (`العربية`), English, French, Spanish, German, Turkish, Russian, Chinese (`中文`), Japanese (`日本語`), Korean (`한국어`), Italian, Portuguese, Dutch, Hindi (`हिन्दी`), Urdu (`اردو`), and Persian (`فارسی`).
  - Strict **Right-to-Left (`RTL`)** alignment for Arabic, Urdu, and Persian translations, fields, and dropdown menus.
- **🔄 Smart Reverse Translation**: Automatically detects when selected text is already in your default target language and translates it into your secondary language instead.
- **⌨️ Global Shortcuts**:
  - **Double Copy (`⌘C` twice)** within 0.85 seconds translates any selected text in any app.
  - **Global Hotkey (`⌥ + T`)** works system-wide without requiring Accessibility permissions.
- **🌐 Companion Browser Extension (Manifest V3)**: Located in [`browser-extension/`](browser-extension/) for Chrome, Brave, Arc, Edge, and Safari.

---

## 🚀 Quick Start (macOS App)

### Option 1: Run the Pre-Built macOS App Bundle
Clone the repository or download [`Lamha.app`](Lamha.app) directly:

```bash
git clone https://github.com/Binhanaa/LamhaTranslate.git
cd LamhaTranslate
open Lamha.app
```

### Option 2: Build from Source
Requires **macOS 14.0+** and **Swift 5.10+**:

```bash
./build_app.sh
open Lamha.app
```

---

## 🌐 Browser Extension Installation (Chrome / Brave / Arc / Edge)

1. Open `chrome://extensions` in your browser.
2. Enable **Developer mode** in the top-right corner.
3. Click **Load unpacked** and select the [`browser-extension`](browser-extension/) directory inside this repository.

---

## 📂 Project Structure

```text
LamhaTranslate/
├── Package.swift
├── build_app.sh
├── Lamha.app/                         # Ready-to-run native macOS application bundle
├── Resources/
│   └── AppIcon.icns                   # Native macOS app icon resource
├── Sources/LamhaTranslate/
│   ├── LamhaApp.swift                 # Menu bar controller & app lifecycle
│   ├── Models/
│   │   ├── AppSettings.swift          # System language detection & UserDefaults persistence
│   │   └── Localization.swift         # 16-language UI localization & RTL/LTR layout engine
│   ├── Services/
│   │   ├── SelectionMonitor.swift     # Low-latency AXUIElement + Cmd+C fallback + ⌥T hotkey
│   │   ├── TranslationService.swift   # Pre-fetching, multi-endpoint fallback & smart reverse
│   │   └── SpeechService.swift        # Multi-lingual AVSpeechSynthesizer pronunciation
│   └── UI/
│       ├── DesignSystem.swift         # Palette, surfaces, brand icon & GitHub vector icon
│       ├── WindowBehavior.swift       # Focus-ring suppression across AppKit & SwiftUI
│       ├── FloatingPanels.swift       # NonActivatingPanel controller for floating popups
│       ├── TriggerBadgeView.swift     # Floating cursor trigger badge
│       ├── TranslationPopupView.swift # Header-only Glass Card + Circular Flag selector
│       ├── SettingsView.swift         # 6-tab settings window (Languages, Mouse, Appearance, Features, History, Settings)
│       └── MenuBarView.swift          # Compact single-bar top menu popover
└── browser-extension/                 # Manifest V3 companion browser extension
```

---

## 👨‍💻 Developer

Developed and maintained by **[@Binhanaa](https://github.com/Binhanaa)**.

## 📄 License

Released under the [MIT License](LICENSE). Copyright © 2026 [Binhanaa](https://github.com/Binhanaa).
