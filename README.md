# MTG Life Counter — iOS App

A Magic: The Gathering life counter app built with SwiftUI for iPhone and iPad.

## Features

- **Multiple Formats**: Commander (40 life), Standard/Modern (20 life)
- **2–4 Players**: Auto-layouts rotate top players 180° so everyone faces their own counter
- **Tap Zones**: Tap left half to subtract 1 life, right half to add 1 life
- **Long Press**: Hold for ±5 life change
- **Commander Damage Tracking**: Per-opponent commander damage tracker with lethal (21+) warnings
- **Elimination Detection**: Players at 0 life or 21+ commander damage are shown as eliminated
- **Game History**: Full log of all life changes during the game
- **Dark Theme**: Designed for table play in dim environments

## Requirements

- iOS 17.0+
- Xcode 15+

## Project Structure

```
MTGLifeCounter/
├── MTGLifeCounter.xcodeproj/
└── MTGLifeCounter/
    ├── MTGLifeCounterApp.swift       # App entry point
    ├── Models/
    │   └── GameState.swift           # Player & game state (ObservableObject)
    ├── Views/
    │   ├── ContentView.swift         # Root view (setup vs game)
    │   ├── SetupView.swift           # Format & player count picker
    │   ├── GameView.swift            # Game screen with layout selection
    │   ├── PlayerCardView.swift      # Individual player tile
    │   ├── CommanderDamageView.swift # Commander damage sheet
    │   └── HistoryView.swift         # Game history log sheet
    └── Assets.xcassets/
```

## Usage

1. Open `MTGLifeCounter.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build & run (⌘R)

## Gameplay

- **Setup Screen**: Choose format and number of players, then tap "Start Game"
- **In-Game**: Each player has a colored tile
  - Tap left side to decrease life, right side to increase
  - Long press for ±5 jump
  - Tap the shield icon to track commander damage from each opponent
  - Use the clock icon (top-left) to view the game history
  - Use the reset icon (top-right) to reset all life totals
  - Tap "Menu" to return to the setup screen
