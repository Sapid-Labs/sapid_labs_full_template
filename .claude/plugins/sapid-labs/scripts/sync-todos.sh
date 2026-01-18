#!/bin/bash

# Sapid Todos Sync Library
# Shared functions for managing sapid-todos.md across Flutter projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project root directory (git or pwd fallback)
get_project_root() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ $? -ne 0 ]; then
        # Git command failed, fall back to pwd
        root=$(pwd)
    fi
    echo "$root"
}

# Get current project name
get_project_name() {
    local project_root="$1"
    basename "$project_root"
}

# Detect work directory (parent of current project)
get_work_directory() {
    local project_root="$1"
    dirname "$project_root"
}

# Validate current directory is Flutter project
validate_flutter_project() {
    local project_root="$1"
    if [ ! -f "$project_root/pubspec.yaml" ]; then
        echo -e "${RED}Error: Current directory is not a Flutter project (no pubspec.yaml found)${NC}" >&2
        return 1
    fi
    return 0
}

# Find all Flutter projects in work directory
find_flutter_projects() {
    local work_dir="$1"
    local current_project="$2"
    local projects=()

    # Check if work directory exists
    if [ ! -d "$work_dir" ]; then
        echo -e "${YELLOW}Warning: Work directory not found: $work_dir${NC}" >&2
        return 1
    fi

    # Scan immediate children only (no recursion)
    for dir in "$work_dir"/*; do
        if [ -d "$dir" ] && [ -f "$dir/pubspec.yaml" ]; then
            # Exclude current project
            local dir_name=$(basename "$dir")
            if [ "$dir" != "$current_project" ]; then
                projects+=("$dir")
            fi
        fi
    done

    # Return projects as newline-separated list
    printf '%s\n' "${projects[@]}"
}

# Check if todo already exists in file
todo_exists() {
    local file="$1"
    local description="$2"

    if [ ! -f "$file" ]; then
        return 1
    fi

    # Check if any line starts with "- $description"
    # Use -- to prevent grep from treating the pattern as an option
    if grep -F -- "- $description" "$file" 2>/dev/null > /dev/null; then
        return 0
    fi

    return 1
}

# Create sapid-todos.md with header
create_todos_file() {
    local project_path="$1"
    local file="$project_path/sapid-todos.md"

    cat > "$file" << 'EOF'
# Sapid Labs Shared Updates

This file contains updates from other Sapid Labs Flutter projects that should be implemented in this project.

## Format
Each todo follows this format:
- Description of the change (Reason: why this change was made) [Files: affected/file.dart, other/file.dart]
<!-- Added: YYYY-MM-DD, From: project_name -->

## Commands
- `/add-todo` - Add a new todo to all other Sapid Labs projects
- `/sync-todos` - View and implement pending todos from this file

---

EOF
}

# Add todo to file
add_todo_to_file() {
    local file="$1"
    local description="$2"
    local reason="$3"
    local files="$4"
    local date="$5"
    local origin="$6"

    # Build the todo line
    local todo_line="- $description"

    if [ -n "$reason" ] && [ -n "$files" ]; then
        todo_line="$todo_line (Reason: $reason) [Files: $files]"
    elif [ -n "$reason" ]; then
        todo_line="$todo_line (Reason: $reason)"
    elif [ -n "$files" ]; then
        todo_line="$todo_line [Files: $files]"
    fi

    # Build metadata comment
    local metadata="<!-- Added: $date, From: $origin -->"

    # Append to file
    echo "$todo_line" >> "$file"
    echo "$metadata" >> "$file"
}

# Parse todos from file
parse_todos() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "[]"
        return
    fi

    # Extract todos (lines starting with "- ")
    # Skip header section (everything before "---")
    local in_todos=false
    local todos=()
    local current_todo=""
    local line_num=0

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            in_todos=true
            continue
        fi

        if [ "$in_todos" = true ]; then
            if [[ "$line" =~ ^-\  ]]; then
                if [ -n "$current_todo" ]; then
                    todos+=("$line_num|$current_todo")
                fi
                current_todo="$line"
                ((line_num++))
            elif [[ "$line" =~ ^\<\!-- ]]; then
                # Metadata line
                current_todo="$current_todo"$'\n'"$line"
            fi
        fi
    done < "$file"

    # Add last todo
    if [ -n "$current_todo" ]; then
        todos+=("$line_num|$current_todo")
    fi

    # Output todos as newline-separated list
    printf '%s\n' "${todos[@]}"
}

# Get todo count from file
count_todos() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi

    # Count lines starting with "- " after "---"
    local in_todos=false
    local count=0

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            in_todos=true
            continue
        fi

        if [ "$in_todos" = true ] && [[ "$line" =~ ^-\  ]]; then
            ((count++))
        fi
    done < "$file"

    echo "$count"
}

# Remove todo from file by line content
remove_todo_from_file() {
    local file="$1"
    local todo_description="$2"

    if [ ! -f "$file" ]; then
        return 1
    fi

    # Create temp file
    local temp_file="${file}.tmp"

    # Read file and skip the todo and its metadata
    local skip_next=false
    while IFS= read -r line; do
        if [ "$skip_next" = true ]; then
            # Skip metadata line (HTML comment)
            if [[ "$line" =~ ^\<\!-- ]]; then
                skip_next=false
                continue
            fi
        fi

        if [[ "$line" == "- $todo_description"* ]]; then
            skip_next=true
            continue
        fi

        echo "$line" >> "$temp_file"
    done < "$file"

    # Replace original file
    mv "$temp_file" "$file"
}

# Extract description from todo line
extract_description() {
    local todo_line="$1"

    # Remove leading "- "
    local desc="${todo_line#- }"

    # Extract just the description (before any parentheses or brackets)
    desc=$(echo "$desc" | sed -E 's/ \(Reason:.*$//' | sed -E 's/ \[Files:.*$//')

    echo "$desc"
}

# Extract metadata from todo
extract_metadata() {
    local todo_block="$1"
    local field="$2"

    # Extract from HTML comment
    if [[ "$todo_block" =~ Added:\ ([0-9-]+) ]]; then
        local date="${BASH_REMATCH[1]}"
    fi

    if [[ "$todo_block" =~ From:\ ([^\ ]+) ]]; then
        local origin="${BASH_REMATCH[1]}"
    fi

    case "$field" in
        "date")
            echo "$date"
            ;;
        "origin")
            echo "$origin"
            ;;
    esac
}
