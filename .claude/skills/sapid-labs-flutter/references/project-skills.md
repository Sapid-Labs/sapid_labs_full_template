# Per-Project Skills

Each Sapid Labs Flutter app inherits a set of Claude Code skills from the template. These skills live in `.claude/skills/` within each project and handle specific code generation tasks. This global skill complements them — use the per-project skills for generating code, use this global skill for understanding conventions and patterns.

## Available Per-Project Skills

| Skill | Command | Purpose |
|---|---|---|
| `sapid-feature` | `/sapid-feature` | Create a complete feature with models, services, UI, routing, and DI |
| `sapid-model` | `/sapid-model` | Create Dart model classes with json_serializable |
| `sapid-service` | `/sapid-service` | Create service classes with backend integration and DI |
| `sapid-route` | `/sapid-route` | Create routes and connect them to the app router |
| `sapid-deploy` | `/sapid-deploy` | Commands and instructions for deploying to production |
| `sapidify` | `/sapidify` | Update existing files to follow Sapid Labs conventions |

## When to Use Which

**Use `/sapid-feature`** when building something entirely new end-to-end. It runs a comprehensive interview (feature type, models, service needs, UI layout, analytics events) and generates all the files in one go.

**Use `/sapid-model`** when you just need a new data class — e.g., adding a `Message` model to an existing chat feature. It handles `@JsonSerializable`, `copyWith`, equality, and `toJson`/`fromJson`.

**Use `/sapid-service`** when you need a new service for an existing feature. It detects the active backend (Firebase/Supabase), chooses the right DI annotation, generates CRUD methods, creates the exception class, and wires up `services.dart`.

**Use `/sapid-route`** when adding a new screen to the router. It creates the view, ViewModel, route entry, and optionally adds an `AuthGuard`.

**Use `/sapid-deploy`** for deployment commands. It's a quick reference for the Fastlane lanes.

**Use `/sapidify`** when you've written code that doesn't follow conventions — it rewrites files to use signals instead of setState, constants instead of SizedBox, InputDecorator instead of raw Container, etc.

## Sapid-Todos Sync System

The template and child apps stay in sync via `sapid-todos.md` files:

- **`/add-todo`**: When you improve something in one project that other projects should adopt, run this to add a change description to the other projects' `sapid-todos.md` files.
- **`/sync-todos`**: When entering a project, check if `sapid-todos.md` has pending items and implement them.

This system lives in the template and is available in all child apps. It's the mechanism for propagating improvements without forcing git merges.
