# Tracker

Tracker is an iOS app for tracking habits and irregular events. The app allows users to create trackers, organize them by category, set schedules, mark completed activities, and view statistics.

## Features

- Create habit and event trackers
- Organize trackers by categories
- Set a schedule for regular habits
- Mark completed activities by date
- Track completed records
- Statistics screen
- Onboarding flow
- Local data persistence
- iOS interface built with UIKit

## Tech Stack

- Swift
- UIKit
- Core Data
- UserDefaults
- UICollectionView
- UITableView
- UIDatePicker

## Installation

1. Clone the repository:
   `git clone https://github.com/maximgv3/Tracker.git`

2. Open the project:
   `open Tracker.xcodeproj`

3. Run the app in Xcode.

## Architecture

The project is divided into several main parts:

- **Trackers list** — displaying trackers, filtering by date, and marking completed activities
- **Habit creation** — creating trackers, choosing emoji, color, category, and schedule
- **Categories** — managing tracker categories
- **Statistics** — viewing user progress
- **Core Data stores** — local data storage for trackers, categories, and records

## Result

This project demonstrates building a multi-screen iOS application with local persistence, structured data storage, collection and table views, and tracker management logic.
