---
type: command
name: add-todo
description: Add a new todo to all other Sapid Labs Flutter projects in the work directory
---

# Add Todo to Other Projects

I'll help you add a new todo to all other Sapid Labs Flutter projects in the work directory.

## Process

1. **Gather Information**: I'll ask you for the todo details
2. **Find Projects**: Scan the work directory for other Flutter projects
3. **Create/Update Files**: Add the todo to each project's sapid-todos.md
4. **Report Results**: Show which projects were updated

## Instructions for Claude

When this command is invoked:

### Step 1: Gather Todo Information
Use the AskUserQuestion tool with the following questions:

1. **Description** (required text input via "Other" option):
   - Question: "What change should be shared with other projects?"
   - Header: "Todo Description"
   - This is the main description of what changed

2. **Reason** (optional text input via "Other" option):
   - Question: "Why was this change made? (optional - helps provide context)"
   - Header: "Reason"
   - Leave empty if not applicable

3. **Files** (optional text input via "Other" option):
   - Question: "Which files are affected? (optional - comma-separated paths like 'lib/validators/phone.dart, lib/screens/auth/sign_in.dart')"
   - Header: "Files"
   - Leave empty if not applicable

### Step 2: Execute the Sync Script
Once you have the answers, use the Bash tool to run the sync script:

```bash
source "${CLAUDE_PLUGIN_ROOT}/scripts/sync-todos.sh"

# Get project info
PROJECT_ROOT=$(get_project_root)
validate_flutter_project "$PROJECT_ROOT" || exit 1

PROJECT_NAME=$(get_project_name "$PROJECT_ROOT")
WORK_DIR=$(get_work_directory "$PROJECT_ROOT")
CURRENT_DATE=$(date +%Y-%m-%d)

# Set variables from user input
DESCRIPTION="<user's description answer>"
REASON="<user's reason answer or empty>"
FILES="<user's files answer or empty>"

# Find other Flutter projects
mapfile -t PROJECTS < <(find_flutter_projects "$WORK_DIR" "$PROJECT_ROOT")

if [ ${#PROJECTS[@]} -eq 0 ]; then
    echo "Warning: No other Flutter projects found in work directory"
    echo "Checked: $WORK_DIR"
    exit 0
fi

echo "Projects scanned: ${#PROJECTS[@]} Flutter projects found"
echo ""

# Track modified files
declare -a MODIFIED_FILES

# Add todo to each project
for project in "${PROJECTS[@]}"; do
    TODO_FILE="$project/sapid-todos.md"

    # Create file if it doesn't exist
    if [ ! -f "$TODO_FILE" ]; then
        create_todos_file "$project"
    fi

    # Check for duplicates (just check the description part)
    if todo_exists "$TODO_FILE" "$DESCRIPTION"; then
        continue
    fi

    # Add the todo
    add_todo_to_file "$TODO_FILE" "$DESCRIPTION" "$REASON" "$FILES" "$CURRENT_DATE" "$PROJECT_NAME" && MODIFIED_FILES+=("$TODO_FILE") || echo "Warning: Failed to update $TODO_FILE" >&2
done

# Report results
if [ ${#MODIFIED_FILES[@]} -eq 0 ]; then
    echo "No new todos added (all were duplicates or errors occurred)"
else
    echo "Files modified:"
    for file in "${MODIFIED_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "Todo added: $DESCRIPTION"
fi
```

### Step 3: Report to User
After the script completes, summarize:
- How many projects were found
- Which sapid-todos.md files were modified
- The todo that was added
- Any warnings or errors
