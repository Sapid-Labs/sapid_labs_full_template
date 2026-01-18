---
type: command
name: sync-todos
description: View and implement pending todos from sapid-todos.md in the current project
---

# Sync Todos - Implement Pending Changes

I'll help you implement pending todos from your sapid-todos.md file.

## Process

1. **Read Todos**: Parse sapid-todos.md in the current project
2. **Show Preview**: Display all pending todos with details
3. **Select Todos**: Let you choose which ones to implement
4. **Implement**: AI implements each selected todo
5. **Update File**: Remove implemented todos from sapid-todos.md

## Instructions for Claude

When this command is invoked:

### Step 1: Check for sapid-todos.md
Use the Read tool to check if sapid-todos.md exists in the current project root:

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/sync-todos.sh"
PROJECT_ROOT=$(get_project_root)
validate_flutter_project "$PROJECT_ROOT" || exit 1
TODO_FILE="$PROJECT_ROOT/sapid-todos.md"

if [ ! -f "$TODO_FILE" ]; then
    echo "No sapid-todos.md file found in this project."
    echo "There are no pending todos to implement."
    exit 0
fi

# Count todos
TODO_COUNT=$(count_todos "$TODO_FILE")
if [ "$TODO_COUNT" -eq 0 ]; then
    echo "No pending todos found in sapid-todos.md"
    exit 0
fi

echo "Found $TODO_COUNT pending todo(s) in sapid-todos.md"
```

If the file doesn't exist or has no todos, inform the user and stop.

### Step 2: Parse and Display Todos
Read the sapid-todos.md file and parse all todos. Display them in a numbered, formatted list:

```
Pending todos in sapid-todos.md:

1. Add PhoneNumberValidator to prevent invalid phone numbers
   Reason: improve data quality and reduce errors
   Files: lib/validators/phone.dart, lib/screens/auth/sign_in.dart
   Added: 2026-01-18, From: sapid_labs_flutter_template

2. Update error handling to use CustomException
   Files: lib/services/api_service.dart
   Added: 2026-01-17, From: sapid_labs_flutter_template
```

### Step 3: Let User Select Todos
Use the AskUserQuestion tool with multiSelect=true to let the user choose which todos to implement:

```json
{
  "questions": [{
    "question": "Which todos would you like to implement?",
    "header": "Select Todos",
    "multiSelect": true,
    "options": [
      {
        "label": "Todo 1: Add PhoneNumberValidator",
        "description": "Reason: improve data quality and reduce errors | Files: lib/validators/phone.dart, lib/screens/auth/sign_in.dart"
      },
      {
        "label": "Todo 2: Update error handling",
        "description": "Files: lib/services/api_service.dart"
      }
    ]
  }]
}
```

**Important**: Create one option for each todo. Use a shortened version of the description for the label (max ~50 chars), and include reason/files in the description field.

### Step 4: Implement Selected Todos
For each selected todo:

1. **Read Context**: If the todo references specific files, read those files first
2. **Understand the Change**: Based on the description and reason, understand what needs to be done
3. **Implement**: Make the necessary code changes using Edit or Write tools
4. **Verify**: Trust that the implementation was successful (no additional verification needed)

### Step 5: Update sapid-todos.md
After implementing each todo, remove it from sapid-todos.md:

For each implemented todo, extract its full description (the part after "- " and before any parentheses or brackets), then use the bash script to remove it:

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/sync-todos.sh"
PROJECT_ROOT=$(get_project_root)
TODO_FILE="$PROJECT_ROOT/sapid-todos.md"

# For each implemented todo
DESCRIPTION="Add PhoneNumberValidator to prevent invalid phone numbers"
remove_todo_from_file "$TODO_FILE" "$DESCRIPTION"
```

### Step 6: Report Results
After all implementations are complete, summarize:

```
Todos implemented: 2
File modified: sapid-todos.md

Summary:
  ✓ Add PhoneNumberValidator
  ✓ Update error handling
```

## Example Workflow

**User runs:** `/sync-todos`

**Claude:**
1. Reads sapid-todos.md
2. Shows: "Found 3 pending todo(s)"
3. Displays formatted list of todos
4. Shows AskUserQuestion with checkboxes for each todo
5. User selects todos 1 and 3
6. Claude implements todo 1, removes from file
7. Claude implements todo 3, removes from file
8. Claude shows completion summary

## Important Notes

- **Trust AI Execution**: Don't run tests or additional verification after implementation
- **Remove on Success**: Remove todos from sapid-todos.md immediately after implementing
- **Provide Context**: When implementing, use the reason and file references to understand the change
- **Handle Errors**: If implementation fails (Claude reports an error), keep the todo in the file and inform the user
