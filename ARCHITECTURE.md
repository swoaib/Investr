# Flutter Architecture Guidelines

These guidelines are based on the official [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture). They serve as a standard for creating new projects, implementing features, and writing code.

## 1. Core Principles

### Separation of Concerns (Layered Architecture)
The application is divided into distinct layers. Each layer has specific responsibilities and only communicates with adjacent layers.
- **UI Layer**: Displays data and handles user interactions.
- **Data Layer**: Manages application data and business logic.
- **Domain Layer (Optional)**: encapsulating complex business logic.

### Single Source of Truth (SSOT)
- Every data type should have a single source of truth (usually a Repository).
- Only the SSOT can modify the data.
- UI components listen to the SSOT.

### Unidirectional Data Flow (UDF)
1. User interaction acts on the **UI**.
2. UI calls a method in the **Logic (ViewModel)**.
3. Logic calls the **Data (Repository)**.
4. Data updates and flows back to Logic -> UI.

## 2. Project Structure & Layers

We follow a feature-first or layer-first structure, but logically, the code must adhere to these components:

### UI Layer
Composed of **Views** and **View Models** (MVVM).
*   **Views (Widgets)**:
    *   Describe *how* to present data.
    *   **Rule**: Contain NO business logic. Only simple UI logic (if/else for visibility, animations).
    *   **Rule**: One View usually pairs with one View Model.
*   **View Models (Logic)**:
    *   Convert app data (from Repository) into UI State.
    *   Handle user events (Commands).
    *   **Rule**: Should not import UI libraries (Flutter material/cupertino) if possible, to remain testable.
    *   **Rule**: Expose data as Streams, ValueNotifiers, or other observable state.

### Data Layer
Composed of **Repositories** and **Services**.
*   **Services**:
    *   Low-level data access (API clients, Database wrappers).
    *   **Rule**: One service per data source (e.g., `ApiClient`, `LocalStorageService`).
    *   **Rule**: uniform inputs/outputs (Futures/Streams). No state management here.
*   **Repositories**:
    *   The Single Source of Truth.
    *   Combine data from multiple services if needed.
    *   Handle caching, error handling, and conversion to Domain Models.
    *   **Rule**: Expose domain models (Dart objects), not raw JSON/DTOs.

### Domain Layer (Optional)
Composed of **UseCases** (Interactors).
*   Use only if logic is shared across multiple ViewModels or is complex.
*   Sit between ViewModel and Repository.

## 3. Implementation Checklists

### Creating a New Feature
When asked to creating a new feature (e.g., "User Profile"), follow this order:

1.  **Define the Domain Model**: What does the data look like? (e.g., `User` class).
2.  **Create Service (if needed)**: Methods to fetch raw data (e.g., `UserApi`).
3.  **Create Repository**:
    *   Inject Service.
    *   Implement `getUser()` returning `Future<User>`.
    *   Handle exceptions.
4.  **Create View Model**:
    *   Inject Repository.
    *   Define UI State class (e.g., `UserProfileState` with `loading`, `data`, `error`).
    *   Implement methods to load data and update state.
5.  **Create View**:
    *   Inject/Provide View Model.
    *   Build UI based on View Model state.

### Writing Code
*   **Naming**:
    *   Classes: `UserProfileScreen` (View), `UserProfileViewModel`, `UserRepository`.
    *   Files: `user_profile_screen.dart`, `user_profile_view_model.dart`, `user_repository.dart`.
*   **State Management**: Use the existing project's state management solution (Riverpod, Provider, Bloc, etc.) to bind these layers.
    *   *If Riverpod*: Use `Provider`/`StateNotifierProvider` for ViewModels and Repositories.
*   **Testing**:
    *   Write specific tests for the **Repository** (mocking Service).
    *   Write specific tests for the **ViewModel** (mocking Repository).

## 4. Verification
*   **Testability**: By separating Logic (ViewModel) from UI (Widgets), we can unit test the logic without a simplified emulator.
*   **Extensibility**: Any layer implementation can be swapped without affecting layers above it.
