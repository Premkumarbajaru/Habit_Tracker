# Habit Tracker App

A minimal Flutter habit tracking application with local data persistence using SharedPreferences.

## ✨ Features

### Core Features (Task Requirements)
1. **Add Habit** - Create new habits via dialog
2. **Complete Habit** - Checkbox to mark daily completion with strikethrough
3. **Edit Habit** - Modify habit names via dialog
4. **Delete Habit** - Remove habits permanently
5. **Statistics Carousel** - Swipeable cards showing Today/Best Streak/Completion%
6. **Reset All** - Restore 3 predefined habits
7. **SharedPreferences** - Persistent local storage
8. **Streak Tracking** - Consecutive days counter with 🔥 

### Predefined Habits
- Sleep Early
- Exercise
- Healthy Eating

## 🏗️ Code Structure

### Single File Architecture
**File:** `lib/main.dart` (240 lines)

```
main.dart
├── HabitApp (MaterialApp)
├── Habit (Model Class)
│   ├── toJson() - Serialize to JSON
│   ├── fromJson() - Deserialize from JSON
│   ├── isDoneToday() - Check completion
│   └── streak - Calculate consecutive days
└── HomeScreen (StatefulWidget)
    ├── _load() - Load from SharedPreferences
    ├── _save() - Save to SharedPreferences
    ├── _add() - Add new habit
    ├── _toggle() - Toggle completion
    ├── _edit() - Edit habit name
    ├── _delete() - Delete habit
    ├── _reset() - Reset to predefined habits
    └── _statCard() - Build statistics card
```

## 💾 Data Persistence

### SharedPreferences Implementation

**Storage Format:**
```dart
Key: 'habits'
Value: List<String> [
  '{"id":"1","name":"Sleep Early","dates":["2024-01-15"]}',
  '{"id":"2","name":"Exercise","dates":["2024-01-15","2024-01-16"]}'
]
```

**Save Operation:**
```dart
Future<void> _save() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('habits', 
    habits.map((e) => json.encode(e.toJson())).toList()
  );
}
```

**Load Operation:**
```dart
Future<void> _load() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getStringList('habits') ?? [];
  if (data.isEmpty) {
    // Load predefined habits
  } else {
    habits = data.map((e) => Habit.fromJson(json.decode(e))).toList();
  }
}
```

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- VS Code
- Android Emulator or Physical Device

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2
```

### Run the App
```bash
# Navigate to project directory
cd habit_tracker

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

## 🎨 UI Components

### Theme
- **Primary Color:** #6366F1 (Indigo)
- **Secondary Color:** #8B5CF6 (Purple)
- **Material Design 3:** Enabled

### Widgets Used
- `Scaffold` - App structure
- `AppBar` - Top bar with menu
- `PageView` - Swipeable statistics carousel
- `ListView.builder` - Habit list
- `Card` - Habit cards
- `Checkbox` - Completion toggle
- `AlertDialog` - Add/Edit dialogs
- `FloatingActionButton` - Add button
- `PopupMenuButton` - Reset menu

## 📊 Statistics Calculation

```dart
final done = habits.where((h) => h.dates.contains(today)).length;
final bestStreak = habits.isEmpty ? 0 : 
  habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
final completion = habits.isEmpty ? 0 : 
  ((done / habits.length) * 100).toInt();
```

## 🐛 Bug Fixes Applied

### Issue 1: Type Cast Error
**Error:** `type 'String' is not a subtype of type 'List<dynamic>?'`  
**Fix:** Added try-catch in `_load()` to clear corrupted data

### Issue 2: Unmodifiable List Error
**Error:** `Cannot add to an unmodifiable list`  
**Fix:** Create new mutable list in `_toggle()` method

## 📱 App Flow

1. **Launch** → Load habits from SharedPreferences
2. **First Time** → Show 3 predefined habits
3. **Add Habit** → Dialog → Save to SharedPreferences
4. **Complete Habit** → Toggle checkbox → Update dates → Save
5. **View Stats** → Swipe carousel cards
6. **Reset** → Restore predefined habits

## 🔧 Optimization Techniques

1. **Single File:** All code in one file (240 lines)
2. **Minimal Dependencies:** Only shared_preferences
3. **Fire-and-Forget Save:** UI updates immediately, save happens async
4. **Efficient Streak Calculation:** Stops at first missing day
5. **Mutable Lists:** Prevents unmodifiable list errors
6. **Error Handling:** Try-catch for data corruption

## 📝 Code Metrics

- **Total Lines:** 240
- **Classes:** 3 (HabitApp, Habit, HomeScreen)
- **Methods:** 10
- **Dependencies:** 1 (shared_preferences)
- **Screens:** 1 (HomeScreen with dialogs)

## 🎓 Learning Outcomes

- SharedPreferences for local storage
- JSON serialization/deserialization
- State management with setState
- Dialog-based navigation
- List manipulation and data persistence
- Error handling and edge cases
- Material Design 3 implementation

# Output Screenshot

<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/36e6b32e-e70e-41e8-bbcb-6f3a8b9070de" />

<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/88c4b8e3-a310-4065-bd7b-ed0af429fff2" />

<img width="1080" height="2400" alt="Image" src="https://github.com/user-attachments/assets/47563f34-acf2-46f6-b838-e70c1e1aa652" />

**Note:** This is a minimal implementation focusing on core functionality without unnecessary complexity. The entire app runs from a single file with only one external dependency.
