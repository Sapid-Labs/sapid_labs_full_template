---
description: 'Implements pending todos from sapid-todos.md shared by other Sapid Labs projects'
tools: []
---

# Todo Implementation Agent

This agent implements pending todos from [sapid-todos.md](../../sapid-todos.md) that have been shared by other Sapid Labs Flutter projects. It reads the todos, implements them one by one, and removes them from the file once complete.

## Purpose

When updates are made in other Sapid Labs projects (using `/add-todo`), they get added to this project's sapid-todos.md file. This agent:
1. Reads all pending todos from sapid-todos.md
2. Shows them to the user for review
3. Implements each todo's changes
4. Removes the todo from sapid-todos.md once successfully implemented

## When to Use

- Run this agent periodically to stay in sync with other projects
- When you see new entries in sapid-todos.md
- After running `/add-todo` in another project
- As part of regular maintenance

## Workflow

### Step 1: Read Pending Todos
Read [sapid-todos.md](../../sapid-todos.md) and parse all pending todos. Each todo has:
- Description: What needs to change
- Reason: Why the change was made (optional)
- Files: Which files are affected (optional)
- Added date: When the todo was created
- From: Which project shared this todo

### Step 2: Display Todos
Show the user all pending todos in a clear format:
```
Found N pending todo(s) from other projects:

1. [Description]
   Reason: [Reason if provided]
   Files: [Files if provided]
   From: [project_name] on [date]

2. [Next todo...]
```

Ask the user if they want to proceed with implementation.

### Step 3: Implement Each Todo
For each todo:
1. Read the affected files (if specified) or search for relevant files
2. Understand the change from the description and reason
3. Implement the change following project patterns (Signals, auto_route, get_it, etc.)
4. Test that the implementation works
5. Once confirmed, remove that specific todo from sapid-todos.md

### Step 4: Remove Completed Todos
After successfully implementing a todo, remove it from sapid-todos.md by:
- Reading the current file
- Finding the exact todo entry (including the comment line)
- Removing both the todo line and its comment
- Writing the updated file back

## Implementation Details

### Reading Todos
Parse sapid-todos.md looking for lines that match:
```
- Description (Reason: ...) [Files: ...]
<!-- Added: YYYY-MM-DD, From: project_name -->
```

### Removing Todos
When removing a todo, delete both lines:
1. The todo line (starts with `- `)
2. The following comment line (starts with `<!-- Added:`)

Keep the file header and separator line intact.

## Example

Given this sapid-todos.md:
```markdown
# Sapid Labs Shared Updates
...
---
- Update phone validator to support international formats (Reason: Better international support) [Files: lib/validators/phone.dart]
<!-- Added: 2026-01-15, From: other_project -->
```

The agent will:
1. Show this todo to the user
2. Read lib/validators/phone.dart
3. Implement the international format support
4. Remove both lines from sapid-todos.md, leaving just the header

## Boundaries

This agent will:
- Only implement changes described in sapid-todos.md
- Follow existing project patterns and conventions
- Ask for clarification if a todo is unclear
- Test changes before removing the todo

This agent will NOT:
- Add new todos to other projects (use `/add-todo` instead)
- Make changes outside the scope of the todo description
- Remove todos without implementing them first
- Modify the sapid-todos.md format or header