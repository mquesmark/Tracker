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
- Supports iOS 17+

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

## Screenshots

<p align="left">
  <img src="https://github.com/user-attachments/assets/994766f7-34a4-4ce5-aa22-8c10586bb21f" width="150" />
  <img src="https://github.com/user-attachments/assets/6943a765-7365-412c-9793-797dd6374728" width="150" />
  <img src="https://github.com/user-attachments/assets/5445f792-52a8-486f-8f49-6bda4e288170" width="150" />
  <img src="https://github.com/user-attachments/assets/e4947332-d43c-40a9-b900-c9e963894aeb" width="150" />
  <img src="https://github.com/user-attachments/assets/82233d88-33ed-4ea6-90d7-6385a0e8844a" width="150" />
</p>

## Architecture

The project is divided into several main parts:

- **Trackers list** — displaying trackers, filtering by date, and marking completed activities
- **Habit creation** — creating trackers, choosing emoji, color, category, and schedule
- **Categories** — managing tracker categories
- **Statistics** — viewing user progress
- **Core Data stores** — local data storage for trackers, categories, and records

## Result

This project demonstrates building a multi-screen iOS application with local persistence, structured data storage, collection and table views, and tracker management logic.
