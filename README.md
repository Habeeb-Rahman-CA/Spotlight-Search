# 🔍 Spotlight Search

A macOS Spotlight-inspired application launcher for **Windows**, built with **Qt 6** and **QML**. Instantly search and launch installed applications, desktop shortcuts, and documents — all from a sleek, frosted-glass overlay window — entirely via keyboard.

---

## ✨ Features

- **⚡ Instant Search** — Real-time fuzzy search across installed apps, desktop shortcuts, and documents
- **🚀 One-key Launch** — Press `Enter` to launch the highlighted result instantly
- **⌨️ Keyboard First** — Navigate results with `↑` / `↓` arrow keys, dismiss with `Escape`
- **🖱️ Mouse Support** — Hover to highlight, click to launch
- **🌑 Frosted Glass UI** — Frameless, always-on-top overlay with a dark translucent design
- **🔒 Global Hotkey** — Toggle the search window from anywhere with `Ctrl + Space`
- **📁 File Icons** — Displays native system icons for each result
- **🔕 System Tray Friendly** — Runs silently in the background; doesn't appear in the taskbar

---

## 🖼️ Preview

> The search overlay appears centered on screen, ready for input, with results updating as you type.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | C++17 |
| UI Framework | Qt 6 / QML |
| Build System | CMake 3.16+ |
| Compiler | MinGW 13 (64-bit) |
| Platform | Windows 10/11 |

---

## 📁 Project Structure

```
SpotlightSearch/
├── main.cpp          # App entry point, hotkey filter, QML image provider
├── backend.h         # Backend class interface (search + launch)
├── backend.cpp       # App indexing, search logic, process launching
├── Main.qml          # Frosted glass UI — search bar + results list
├── CMakeLists.txt    # Build configuration
└── .gitignore        # Ignores build/IDE artifacts
```

---

## 🚀 Building from Source

### Prerequisites

- [Qt 6.x](https://www.qt.io/download) with the **MinGW 64-bit** kit
- CMake 3.16+ (bundled with Qt)
- Ninja (bundled with Qt)

### Build Steps

```bash
# 1. Configure
/c/Qt/Tools/CMake_64/bin/cmake.exe -B build -S . \
  -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/mingw_64" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MAKE_PROGRAM="C:/Qt/Tools/Ninja/ninja.exe" \
  -G Ninja

# 2. Compile
/c/Qt/Tools/CMake_64/bin/cmake.exe --build build --config Release -j4
```

The executable will be at:
```
build\appSpotlightSearch.exe
```

### Deploy (bundle Qt DLLs)

```bash
# Copy Qt runtime DLLs next to the executable
/c/Qt/6.x.x/mingw_64/bin/windeployqt6.exe --qmldir . "build/appSpotlightSearch.exe"

# Copy MinGW runtime DLLs
cp /c/Qt/Tools/mingw1310_64/bin/libgcc_s_seh-1.dll \
   /c/Qt/Tools/mingw1310_64/bin/libstdc++-6.dll \
   /c/Qt/Tools/mingw1310_64/bin/libwinpthread-1.dll \
   build/
```

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|---|---|
| `Ctrl + Space` | Toggle search window (global) |
| `↑` / `↓` | Navigate results |
| `Enter` | Launch selected result |
| `Escape` | Dismiss search window |

---

## 🔍 How It Works

1. **On startup**, the backend indexes apps from:
   - **Applications** (`%APPDATA%\Microsoft\Windows\Start Menu`)
   - **Desktop** shortcuts
   - **Documents** folder
2. **As you type**, the query is matched case-insensitively against indexed names (up to 10 results shown)
3. **On launch**, the file is opened via `QDesktopServices::openUrl`, which respects file associations
4. The **global hotkey** (`Ctrl + Space`) is registered via the Windows `RegisterHotKey` API and caught by a native event filter

---

## 📦 Distribution

Zip the entire deploy folder and share it — no Qt or MinGW installation required on the target machine.

---

## 📄 License

MIT License — feel free to use, modify, and distribute.
