## Developer

Szymon Kopańko

## Application Description

This mobile app is designed for Android devices to track strength training workouts. It enables users to efficiently monitor and manage their workouts, progress, and related strength training data.

## Features

### Exercise Entry Management
- Users can add new exercises by specifying the type of exercise, date, weights, and number of repetitions.
- Options to delete, edit, and review previously entered exercises are available.

### 1RM Calculation and Monitoring
- The app calculates the theoretical one-repetition maximum (1RM) for specific exercises over time.
- Users can track their progress and changes in their lifting capacity.

### Progress Tracking with Charts
- Generates charts from the database to help users track their progress in terms of 1RM, body mass, and fat levels.

### Training Management
- Users can create their own workouts by selecting exercises from the available database.
- Features include the ability to delete, edit, and check workouts, allowing flexible management of training plans.

### Weekly Notifications for Training Plans
- Allows users to set up weekly notifications for selected workouts.
- Features to delete and review previously added notifications are planned but not yet implemented.

## Technical Architecture

- The app is written in Dart using the Flutter framework.
- It follows the MVC architecture to separate data models, user interface, and data handling.
- Utilizes an SQLite database. Plans include developing a web frontend in Angular and a RESTful API service in Java Spring Boot.

## Screens

1. `main.dart`
[Screenshot of main dashboard](readme_images/Screenshot_20240603-152235.png)
2. `show_exercises.dart`
[Exercises](readme_images/Screenshot_20240603-151403.png)
3. `show_entries.dart`
[Entries](readme_images/Screenshot_20240603-151414.png)
4. `show_chart.dart`
[Chart](readme_images/Screenshot_20240603-151424.png)
[Chart](readme_images/Screenshot_20240603-151421.png)
5. `show_trainings.dart`
[Trainings](readme_images/Screenshot_20240603-151439.png)
6. `edit_training.dart`
[Edit Training](readme_images/Screenshot_20240603-151501.png)
7. `add_training_entries.dart`
[Add Entry](readme_images/Screenshot_20240603-151444.png)
[Add Entry](readme_images/Screenshot_20240603-151430.png)
[Add Entry](readme_images/Screenshot_20240603-151530.png)
[Add Entry](readme_images/Screenshot_20240603-151540.png)
8. `show_notifications.dart`
[Notifications](readme_images/Screenshot_20240603-151508.png)
[Notifications](readme_images/reminder.png)

## Future Development

- Implementation of a Java Spring Boot API service with a PostgreSQL database and an Angular frontend to enable multi-device usage and user comparisons.
- Addition of body measurement entries and editing, and an in-app stopwatch for logging workout entries.
- Language selection options and the choice between imperial and metric units for displaying results.

## Critical Analysis of Results

- Many features intended for the final version are still pending.
- Some screens (e.g., `main.dart`) could be designed more aesthetically.
- Consideration of using ORM for database operations, which was not implemented but could speed up project development.

---

This README layout for GitHub focuses on clarity and organization, presenting key information about the project in a structured format suitable for developers and potential users exploring the repository. Adjustments and expansions can be made based on further project development and specific needs.
