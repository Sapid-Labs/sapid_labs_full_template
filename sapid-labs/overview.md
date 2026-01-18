Sapid Labs is my personal software development lab. I am primarily a Flutter developer and I work on apps, websites, and backend services.

To maximize productivity, I have created a system for sharing updates across projects. All of my Flutter apps, including this sapid_labs_flutter_template, live in a `work` folder. 

The template is what all Sapid Labs apps are made from and it is essential that any improvements I make to the base app functionality make their way back to the template. 

Likewise, it is crucial that any updates made to the template are communicated to the child apps in some way.

Changes only need to be communicated in text (ex. a description of the change and why it was made. For instance, added a shared PhoneNumberValidator so that users cannot use invalid phone numbers at sign in). Then, when I open an app to work on it, I can refer these changes and have my AI agent implement them quickly before I start on anything new.

Changes are communicated to and from the template in a `sapid-todos.md` file. Each change includes the description of the change and an optional reason that will help the AI agent understand what needs to be done. The change can also refer to specific files.

When a change is implemented, the `sapid-todos.md` file for the implementing app should be updated so the change is deleted.

## Implementation Status

✅ **Complete** - The sapid-todos sync system has been implemented with the following components:

### Components Created

1. **Bash Script Library** - `.claude/plugins/sapid-labs/scripts/sync-todos.sh`
   - Core functions for project detection, file management, and todo operations
   - Validates Flutter projects via pubspec.yaml
   - Auto-detects work directory and finds all Flutter projects
   - Handles duplicate detection and error cases gracefully

2. **`/add-todo` Command** - `.claude/plugins/sapid-labs/commands/add-todo.md`
   - Interactive prompts for description, reason, and files
   - Creates todos in all other Flutter projects (excludes current project)
   - Auto-creates sapid-todos.md with proper header if missing
   - Skips duplicate todos automatically
   - Leaves changes unstaged for manual review

3. **`/sync-todos` Command** - `.claude/plugins/sapid-labs/commands/sync-todos.md`
   - Displays all pending todos with formatted preview
   - Multi-select checkbox interface for choosing which to implement
   - AI implements selected todos
   - Removes completed todos from sapid-todos.md

### Usage

**From Template (to propagate changes to child apps):**
```bash
/add-todo
# Follow prompts to add todo
# All child apps receive the update
```

**From Child App (to implement template updates):**
```bash
/sync-todos
# Select which updates to implement
# Todos are implemented and removed from file
```

**From Child App (to propagate improvements back to template):**
```bash
/add-todo
# Follow prompts to add todo
# Template receives the update
```