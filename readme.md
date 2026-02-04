# 🌙 WakeWell
## Smart Sleep & Wake Optimization App (iOS + watchOS)

---

## 📌 Project Overview

WakeWell is an **iOS + watchOS application** designed to help **working professionals wake up refreshed** by intelligently detecting **optimal wake moments** within a user-defined time window.

The app combines:
- Real-time physiological signals (during a short wake window)
- Post-sleep insights from Apple Health
- Minimal, focused features that support better wake quality (not generic sleep tracking)

> ⚠️ WakeWell is **not a medical or clinical sleep diagnosis tool**.

---

## 🎯 Core Philosophy

**We do not try to replace Apple’s sleep engine.**  
We use Apple’s ecosystem **as intended**:

- **Apple** → Sleep insights (after sleep ends)
- **WakeWell** → Real-time wake decision (during wake window)

This repository exists to build a **reliable, battery-aware, iOS-native experience**.

---

## 🧠 Key Features (MVP Scope)

### 1️⃣ Smart Alarm (Core Feature)
- User sets a wake window (e.g., 5:30–6:00 AM)
- App activates **Workout Mode only inside this window**
- Uses:
  - Continuous heart rate
  - Wrist micro-movements (accelerometer)
- Wakes the user at the **earliest optimal wake moment**
- Falls back to a hard alarm at window end

---

### 2️⃣ Sleep Depth Feedback (Post-Sleep)
- Reads Apple Health sleep stages after wake
- Detects chronic sleep debt patterns
- Suggests:
  - Earlier bedtime
  - Expanded wake window (with user consent)

---

### 3️⃣ Curated Sleep Sounds
- Helps users fall asleep faster
- Automatically stops when sleep is detected (system-driven)
- No constant background processing

---

### 4️⃣ Power Nap (PawanNap)
- Short nap timer (20–30 minutes)
- Optional gentle wake logic
- No deep sleep tracking

---

## 🚫 Explicit Non-Goals (DO NOT BUILD)

To avoid scope creep, **we will NOT**:
- Predict REM / Deep / Core sleep in real time
- Compete with Apple’s sleep accuracy
- Track diet, caffeine, or workout plans
- Use workout mode all night
- Make medical or clinical claims
- Over-optimize battery usage beyond Apple guidelines

---

## 🧩 Technical Architecture (High-Level)

### Platforms
- iOS (Swift, SwiftUI)
- watchOS (SwiftUI)

### Frameworks
- HealthKit (read-only sleep data)
- Core Motion (accelerometer during workout mode)
- WatchKit / WatchConnectivity
- AVFoundation (sleep sounds)

### Data Modes

| Mode | Purpose |
|-----|--------|
| Post-Sleep | Sleep stages, trends |
| Passive | App context only |
| Workout Session | Wake decision logic |

---

## 🧑‍💻 Development Guidelines

### 🔀 Branching Rules
- **Never commit directly to `main`**
- Always create a feature branch:
feature/smart-alarm
feature/watch-sensors
fix/battery-drain

- Use Pull Requests for all merges

---

### 📝 Commit Message Format
[watchOS] Implement wake window workout session
[iOS] Add sleep summary UI
[fix] Prevent duplicate alarm trigger


---

## 🔐 Permissions & Privacy
- Request HealthKit permissions **only when required**
- Clearly explain **why workout mode is used**
- Never store raw health data externally

---

## ⚠️ Disclaimer

WakeWell is a wellness-focused educational project and **not a medical device**.

testing
