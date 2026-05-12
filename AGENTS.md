# AGENTS.md

This file provides guidance to Agents when working with code in this repository.

---

## Overview

**Pao** is an iOS productivity app that helps users stay focused and manage their tasks efficiently. It combines two proven techniques — **Pomodoro** (Deep Focus) and **Eisenhower Matrix** (Task Prioritization) — and simplifies them for general users with no prior knowledge of these methods.
**Pao!** is an iOS Zen-Casual Game designed as a quick mental escape for overwhelmed individuals, where players find relief by shooting projectiles to clear blocks at their own pace with new rows gently advancing only when the ball safely returns to the ground

The app has two main screens:
1. **Home Screen** — Calming visual background with CTA to play the game.
2. **Game Screen** - Game screen where player will be able to relief stress with playing simple slow games.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift |
| UI Framework | SwiftUI |
| Minimum iOS | iOS 26 |
| Architecture | ECS-FSM-Manager |
| Render Engine | SpriteKit |

---

## Project Structure

```
Pao/
├── ECS/
│   ├── Entities/
│   │   ├── PlayerEntity.swift          # 
│   │   ├── BallEntity.swift            # 
│   │   ├── ItemBallEntity.swift        # 
│   │   └── BlockEntity.swift           # 
│   ├── Components/
│   │   ├── RenderComponent.swift       # 
│   │   ├── PositionComponent.swift     # 
│   │   ├── PhysicsComponent.swift      # 
│   │   ├── HealthComponent.swift       # 
│   │   ├── ControlComponent.swift      # 
│   │   ├── ConsumableComponent.swift   # 
│   │   └── Others...                   # 
│   └── Systems/
│       ├── MovementSystem.swift        # 
│       ├── HealthSystem.swift          # 
│       ├── ControllerSystem.swift      # 
│       └── Components/                 # 
├── States/
│   ├── Game/
│   │   ├── FocusView.swift             # 
│   │   ├── TaskListView.swift          # 
│   │   ├── DeepFocusModalView.swift    # 
│   │   └── Components/                 # 
│   ├── Player/
│   │   ├── FocusView.swift             # 
│   │   ├── TaskListView.swift          # 
│   │   ├── DeepFocusModalView.swift    # 
│   │   └── Components/                 # 
│   ├── Ball/
│   │   ├── FocusView.swift             # 
│   │   ├── TaskListView.swift          # 
│   │   ├── DeepFocusModalView.swift    # 
│   │   └── Components/                 # 
│   ├── ItemBall/
│   │   ├── FocusView.swift             # 
│   │   ├── TaskListView.swift          # 
│   │   ├── DeepFocusModalView.swift    # 
│   │   └── Components/                 # 
│   └── Block/
│       ├── FocusView.swift             # 
│       ├── TaskListView.swift          # 
│       ├── DeepFocusModalView.swift    # 
│       └── Components/                 # 
├── UI/
│   ├── Nodes/
│   │   ├── PlayerNodes.swift           # 
│   │   ├── BallNodes.swift             # 
│   │   ├── ItemBallNodes.swift         # 
│   │   └── BlockNodes.swift            # 
│   ├── Scenes/
│   │   └── GameScene.swift             # 
│   ├── Screens/
│   │   ├── HomeView.swift              # 
│   │   └── GameView.swift              # 
│   └── ContentView.swift
├── Utilities/
│   ├── Extensions/
│   │   └── CGPoint+Extension.swift     # 
│   ├── Managers/
│   │   ├── EntityManager.swift         # 
│   │   ├── HapticManager.swift         # 
│   │   ├── MotionManager.swift         #  
│   │   ├── SoundManager.swift          # 
│   │   └── RandomManager.swift         # 
│   ├── Either.swift                    # 
│   └── Constants.swift                 # 
├── Resources/
│   ├── Fonts/
│   ├── Sounds/
│   └── Assets.xcassets                 # App icons, colors, images, textures, etc.
└── PaoApp.swift
```