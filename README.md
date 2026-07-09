# LangVor

A cross-platform (Windows & macOS) desktop app for practicing Russian → English translation. Paste a Russian text, write your own translation next to it, and get real-time feedback — spelling and grammar checked locally, translation quality checked against a live reference translation. Includes a spaced-repetition (SM-2) vocabulary trainer.

[![CI](https://github.com/stormi-oss/LangVor/actions/workflows/ci.yml/badge.svg)](https://github.com/stormi-oss/LangVor/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Download

<p>
  <a href="https://github.com/stormi-oss/LangVor/releases/latest/download/langvor-windows.zip">
    <img alt="Download for Windows" src="https://img.shields.io/badge/Download-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white">
  </a>
  &nbsp;
  <a href="https://github.com/stormi-oss/LangVor/releases/latest/download/langvor-macos.zip">
    <img alt="Download for macOS" src="https://img.shields.io/badge/Download-macOS-000000?style=for-the-badge&logo=apple&logoColor=white">
  </a>
</p>

Or browse all releases: **[github.com/stormi-oss/LangVor/releases](https://github.com/stormi-oss/LangVor/releases)**

These builds are **not signed** with a paid developer certificate, so both operating systems will show a warning the first time you open the app. This is normal for independently distributed apps — see below for how to proceed.

### Opening on macOS

1. Unzip the download and drag `langvor.app` to `/Applications`.
2. macOS will refuse to open it the first time ("cannot be opened because the developer cannot be verified" / the app appears "damaged"). This is Gatekeeper reacting to the missing paid signature, not an actual problem with the file.
3. Fix it with either of these:
   - **Terminal** (fastest): `xattr -cr /Applications/langvor.app`, then open the app normally.
   - **Finder**: right-click `langvor.app` → *Open* → *Open* again in the confirmation dialog. If that option isn't offered, go to **System Settings → Privacy & Security**, scroll down, and click **Open Anyway** next to the LangVor warning.

### Opening on Windows

1. Unzip the download and run `langvor.exe`.
2. Windows SmartScreen will show "Windows protected your PC".
3. Click **More info**, then **Run anyway**.

## Features

- **Dual-pane translation workspace** — Russian source and your English translation side by side, rich-text editing (bold/italic, verse mode for poetry), with a "Page X of Y" indicator and Previous/Next navigation once a text is long enough to scroll.
- **Graded translation checking, not word-matching** — your translation is compared against a live reference translation from the [MyMemory Translation API](https://mymemory.translated.net/) (free, no API key) and graded on multiple levels (exact / good / partial / needs work), with detailed reviewer feedback: missing words, word-choice hints, and a reference translation. Cached locally to minimize repeat requests.
- **Offline fallback** — spelling (English wordlist) and grammar (rule-based) checks always run locally and instantly; if you're offline or turn off online checking, coverage checking degrades gracefully instead of breaking.
- **Translation trainer** — practice a text sentence by sentence with Easy / Medium / Hard difficulty, a timer, live grading, achievement badges, and a personal-best leaderboard.
- **Vocabulary manager (Finder-style)** — organize words into folders with a sidebar; switch between list, grid, and column views; inline-rename folders, right-click context menus, and drag words between folders. Import from **.txt / .csv / .json / .xlsx** (creates a folder per file) and export to JSON/CSV.
- **Four study modes** — Flashcards, multiple-choice Quiz, Typing, and Listening (text-to-speech), plus SM-2 spaced-repetition review and a results chart.
- **Fully customizable typography** — font size (presets + 10–24px slider), weight (Light → Extra Bold), italic, and line spacing, all applied live across the app.
- **Light and dark themes** with a smooth transition, plus keyboard shortcuts (Ctrl/Cmd+Enter to re-check, Ctrl/Cmd+N for a new text, Escape to dismiss dialogs).

## Privacy

When online checking is enabled (default, toggleable in Settings), the Russian source text is sent to the third-party MyMemory Translation API to fetch a reference translation. Your own English translation text is **not** sent anywhere — comparison happens on-device. Turn "Check against a real translation" off in Settings to keep everything local.

## Building from source

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.44+, stable channel) with the Windows and/or macOS desktop toolchains enabled.

```bash
flutter pub get
flutter run -d macos    # or -d windows
```

Release build:

```bash
flutter build macos --release   # or: flutter build windows --release
```

## Architecture

See [MANUAL.md](MANUAL.md) for a detailed guide to the codebase: layer structure, data flow, and how to extend it.

## License

MIT — see [LICENSE](LICENSE). The bundled offline English wordlist (`assets/dictionary/en_words.txt`) is a public-domain derivative of Webster's Second International Dictionary (1934); see [assets/dictionary/en_words.LICENSE.txt](assets/dictionary/en_words.LICENSE.txt) for provenance.
