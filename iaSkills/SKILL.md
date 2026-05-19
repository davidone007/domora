---
name: flutter-clean-architecture-review
description: Expertise in reviewing Flutter code following Clean Architecture principles. Trigger this when analyzing folder structures or code quality.
---

# Flutter Clean Architecture Review

## Purpose

Review Flutter/Dart projects and validate whether the codebase follows Clean Architecture principles correctly.

The review must analyze:

- Folder structure
- Layer separation
- Dependency direction
- Feature modularization
- State management placement
- Repository pattern implementation
- Use case responsibilities
- Entity purity
- Data source responsibilities
- Dependency injection structure
- Scalability
- Testability
- Maintainability

---

## Clean Architecture Rules

### Layer Structure

The project should follow this structure or an equivalent feature-first structure:

```text
lib/
├── core/
├── features/
│   └── feature_name/
│       ├── presentation/
│       ├── domain/
│       └── data/
```

---

## Layer Responsibilities

### Presentation Layer

Contains:

- Widgets
- Screens
- Pages
- Controllers
- Bloc/Cubit/GetX/ViewModels
- UI state handling

Rules:

- Must NOT contain business logic
- Must NOT access APIs directly
- Must NOT access databases directly
- Should only communicate with Use Cases
- Can depend on Domain layer
- Must NOT depend on Data layer implementations

Check for violations such as:

- HTTP calls inside widgets
- RepositoryImpl usage inside UI
- JSON parsing inside presentation
- Business rules inside Bloc/ViewModel

---

### Domain Layer

Contains:

- Entities
- Repository contracts
- Use Cases
- Business rules

Rules:

- Must be pure Dart
- Must NOT import Flutter packages
- Must NOT depend on external frameworks
- Must NOT know about APIs or databases
- Must NOT contain implementation details

Entities:

- Should be immutable when possible
- Should contain only business data
- Should not extend framework classes unnecessarily

Use Cases:

- Must contain a single business responsibility
- Must communicate through repository abstractions
- Must NOT depend on concrete repositories

Repository Contracts:

- Must be abstract
- Defined inside domain layer
- Implemented inside data layer

Check for violations such as:

- Flutter imports in domain
- Dio/http imports in domain
- Repository implementations inside domain
- UI logic inside use cases

---

### Data Layer

Contains:

- Models
- Repository implementations
- Remote data sources
- Local data sources
- DTOs
- API services

Rules:

- Implements repository contracts from domain
- Handles serialization/deserialization
- Handles API/database logic
- Converts Models ↔ Entities
- Must NOT contain UI logic

Models:

- Can extend entities if desired
- Should contain fromJson/toJson methods

Repository Implementations:

- Must implement domain repository contracts
- Must orchestrate data sources
- Must return entities to domain

Data Sources:

- Responsible only for raw data retrieval/storage
- Must NOT contain business rules

Check for violations such as:

- Business rules inside repositories
- UI imports inside data layer
- Widgets inside data layer

---

## Dependency Rules

Allowed dependency direction:

```text
Presentation → Domain
Data → Domain
```

Forbidden dependencies:

```text
Domain → Presentation
Domain → Data
Presentation → Data
```

The domain layer must be the central independent layer.

---

## Feature First Architecture

Prefer feature-first organization instead of layer-first.

Preferred:

```text
features/
├── authentication/
├── users/
├── dashboard/
```

Avoid overly global structures like:

```text
lib/
├── screens/
├── widgets/
├── repositories/
├── models/
```

unless the project is very small.

---

## Dependency Injection

Check whether dependency injection is centralized and scalable.

Preferred tools:

- get_it
- injectable
- riverpod providers
- modular dependency containers

Check for violations:

- Manual dependency creation everywhere
- Tight coupling
- Direct instantiation of repositories inside UI

---

## State Management Validation

Validate correct placement of state management.

Bloc/Cubit/ViewModels should:

- Call Use Cases only
- Never call APIs directly
- Never parse JSON
- Never instantiate repositories manually

---

## Code Smells To Detect

Detect and report:

- God classes
- Massive widgets
- Business logic inside UI
- Duplicate repository logic
- Tight coupling
- Circular dependencies
- Feature leakage
- Shared mutable state
- Missing abstractions
- Overengineering
- Improper dependency inversion

---

## Review Output Format

The review must contain:

1. Architecture Score (0-100)
2. Folder Structure Analysis
3. Layer Dependency Analysis
4. Violations Found
5. Clean Architecture Compliance
6. Scalability Analysis
7. Maintainability Analysis
8. Testing Readiness
9. Refactoring Suggestions
10. Priority Fixes

---

## Severity Levels

Use these severity levels:

- Critical
- High
- Medium
- Low
- Suggestion

---

## Expected Behavior

When reviewing a project:

- Analyze imports between layers
- Inspect folder organization
- Detect architectural violations
- Explain WHY each issue is problematic
- Suggest proper Clean Architecture alternatives
- Prefer pragmatic architecture over dogmatic architecture
- Consider project size and complexity before criticizing

---

## Additional Flutter Best Practices

Validate:

- Proper usage of const widgets
- Separation of reusable widgets
- Avoidance of unnecessary rebuilds
- Correct async handling
- Proper error handling
- Repository abstraction usage
- Immutable state management
- Correct DTO/entity separation
- Feature modularization

---

## Ignore Minor Issues

Do not over-report:

- Small utility classes
- Shared theme/configuration files
- Small apps with intentionally simplified architecture

Focus on meaningful architectural problems.