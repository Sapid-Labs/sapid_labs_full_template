# Sapid Todos Sync System

## Overview
A system for propagating code changes and improvements between the Sapid Labs Flutter template and its child applications through a synchronized todo management system.

## Purpose
- Enable template improvements to flow to all child apps
- Allow child app enhancements to flow back to the template
- Maintain consistency across the Sapid Labs Flutter project ecosystem
- Provide AI-assisted implementation of shared improvements

## Architecture

### Components
1. **Bash Script Library**: `.claude/plugins/sapid-labs/scripts/sync-todos.sh`
   - Shared library with reusable functions
   - Sourced by command files

2. **Commands**:
   - `/add-todo` - Add a new todo to other projects
   - `/sync-todos` - View and implement pending todos

3. **Todo Files**: `sapid-todos.md` in each project root
   - Markdown file containing pending changes
   - Auto-created when needed

## Project Detection

### Discovery Algorithm
1. Find current project root using `git rev-parse --show-toplevel`
   - Fallback to `pwd` if git command fails
2. Validate current directory has `pubspec.yaml`
3. Detect work directory as parent of current project (`cd ..`)
4. Scan immediate children of work directory (top-level only, no recursion)
5. Identify Flutter projects by presence of `pubspec.yaml`
6. Exclude current project from target list

### Update Flow
- **From Template**: Template's `/add-todo` → Updates all child apps' `sapid-todos.md` (NOT template's own file)
- **From Child**: Child's `/add-todo` → Updates template's `sapid-todos.md` (NOT child's own file)
- **Independent Tracking**: Each project manages its own todo implementations separately

## sapid-todos.md Format

### File Header
```markdown
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

```

### Todo Entry Format
```markdown
- Add PhoneNumberValidator to prevent invalid phone numbers at sign in (Reason: improve data quality and reduce errors) [Files: lib/validators/phone.dart, lib/screens/auth/sign_in.dart]
<!-- Added: 2026-01-18, From: sapid_labs_flutter_template -->
```

**Format Breakdown**:
- **Description**: Clear statement of what changed
- **Reason** (optional): Why the change was made (in parentheses)
- **Files** (optional): Affected file paths in square brackets
- **Metadata**: HTML comment with date added (YYYY-MM-DD) and origin project name

### Todo Ordering
- New todos appended to end of file
- No sorting or reorganization
- Simple chronological order

## /add-todo Command

### User Interface
Interactive prompts using `AskUserQuestion`:
1. **Description**: "What change should be shared?" (required)
2. **Reason**: "Why was this change made?" (optional)
3. **Files**: "Which files are affected?" (optional, comma-separated)

### Processing Logic
1. Validate current directory has `pubspec.yaml`
2. Determine project root (git or pwd fallback)
3. Get current project name (directory basename)
4. Detect work directory (parent directory)
5. Scan for Flutter projects in work directory
6. For each target project:
   - Create `sapid-todos.md` if it doesn't exist (with header)
   - Read existing todos
   - Check for identical todo (exact match)
   - If not duplicate: append new todo with metadata
   - Skip project on file errors, continue with others
7. Output summary:
   - Projects scanned: X found
   - Files modified: project1/sapid-todos.md, project2/sapid-todos.md
   - Todo added: [description preview]

### Error Handling
- **No pubspec.yaml**: Error message, exit
- **No other projects found**: Warning message, exit gracefully
- **File permission errors**: Skip that project, log error, continue
- **Git command fails**: Fall back to pwd for project root

### Git Integration
- Leave all changes unstaged for manual review
- No automatic commits

## /sync-todos Command

### User Interface
1. **Read** current project's `sapid-todos.md`
2. **Display** preview of all pending todos with indices
3. **Select** todos to implement using `AskUserQuestion` with checkboxes
4. **Implement** selected todos via AI agent
5. **Remove** implemented todos from file
6. **Report** completion summary

### Processing Logic
1. Validate current directory has `pubspec.yaml`
2. Determine project root
3. Check if `sapid-todos.md` exists
   - If not: "No pending todos found"
4. Parse all todos from file
5. Display numbered list to user
6. Use `AskUserQuestion` with `multiSelect: true` to select todos
7. For each selected todo:
   - AI implements the change
   - On success: remove from `sapid-todos.md`
   - Trust AI execution (no additional verification)
8. Save updated `sapid-todos.md`
9. Output summary:
   - Todos implemented: X
   - File modified: sapid-todos.md

### Implementation Details
- **AI Agent**: Use Claude's existing code editing capabilities
- **Context**: Provide todo description, reason, and file references
- **Verification**: Trust AI execution, no automated tests
- **Failure Handling**: If AI reports error, keep todo in file

## Script Functions

### Core Functions in `sync-todos.sh`

```bash
# Get project root directory (git or pwd fallback)
get_project_root()

# Get current project name
get_project_name()

# Detect work directory (parent of current project)
get_work_directory()

# Find all Flutter projects in work directory
find_flutter_projects()

# Check if todo already exists in file
todo_exists(file, description)

# Create sapid-todos.md with header
create_todos_file(project_path)

# Add todo to file
add_todo_to_file(file, description, reason, files, date, origin)

# Parse todos from file
parse_todos(file)

# Remove todo from file
remove_todo_from_file(file, todo_index)

# Validate current directory is Flutter project
validate_flutter_project()
```

## Validation Rules

### Pre-execution Validation
- Current directory must contain `pubspec.yaml`
- Work directory must exist
- Script must be executable

### Todo Validation
- Description is required (non-empty)
- Reason and files are optional
- Duplicate detection: exact description match

### File Operations
- Create missing `sapid-todos.md` automatically
- Skip projects with permission errors
- Continue processing other projects on individual failures

## Output Format

### /add-todo Success
```
Projects scanned: 3 Flutter projects found
Files modified:
  - ../my_app/sapid-todos.md
  - ../other_app/sapid-todos.md
Todo added: Add PhoneNumberValidator to prevent invalid phone numbers
```

### /add-todo Warning (No Projects)
```
Warning: No other Flutter projects found in work directory
Checked: /Users/josephmuller/Dev/sapid/work
```

### /sync-todos Preview
```
Pending todos in sapid-todos.md:

1. Add PhoneNumberValidator to prevent invalid phone numbers
   Reason: improve data quality and reduce errors
   Files: lib/validators/phone.dart, lib/screens/auth/sign_in.dart
   Added: 2026-01-18, From: sapid_labs_flutter_template

2. Update error handling to use CustomException
   Files: lib/services/api_service.dart
   Added: 2026-01-17, From: sapid_labs_flutter_template

[AskUserQuestion with checkboxes to select which to implement]
```

### /sync-todos Success
```
Todos implemented: 2
File modified: sapid-todos.md

Summary:
  ✓ Add PhoneNumberValidator
  ✓ Update error handling
```

## Edge Cases

### Empty sapid-todos.md
- Display: "No pending todos found"
- Don't offer to implement

### All Todos Identical
- Skip all additions
- Output: "No new todos added (all duplicates)"

### Work Directory is Current Directory
- Detect this scenario
- Output: "Cannot sync with parent directory (current project is in work root)"

### Non-Git Repository
- Fall back to `pwd` for project root
- Continue normal operation

### Mixed Project Types
- Only process directories with `pubspec.yaml`
- Ignore non-Flutter projects silently

## Implementation Sequence

### Phase 1: Script Foundation
1. Create `.claude/plugins/sapid-labs/scripts/` directory
2. Implement `sync-todos.sh` with core functions
3. Add validation and error handling
4. Test project detection logic

### Phase 2: /add-todo Command
1. Create `.claude/plugins/sapid-labs/commands/add-todo.md`
2. Implement interactive prompts
3. Integrate with script functions
4. Test duplicate detection
5. Test file creation

### Phase 3: /sync-todos Command
1. Create `.claude/plugins/sapid-labs/commands/sync-todos.md`
2. Implement todo parsing and display
3. Implement selection UI
4. Integrate with AI implementation
5. Test todo removal

### Phase 4: Testing & Refinement
1. Test with multiple projects
2. Test error scenarios
3. Verify output formatting
4. Test edge cases
5. Update documentation

## Files to Create/Modify

### New Files
- `.claude/plugins/sapid-labs/scripts/sync-todos.sh`
- `.claude/plugins/sapid-labs/commands/add-todo.md`
- `.claude/plugins/sapid-labs/commands/sync-todos.md`

### Modified Files
- None (all new functionality)

## Success Criteria
- [ ] `/add-todo` successfully creates todos in all child projects
- [ ] `/add-todo` from child project updates template
- [ ] Duplicate todos are correctly detected and skipped
- [ ] `sapid-todos.md` files auto-created with proper header
- [ ] `/sync-todos` displays all pending todos
- [ ] Selected todos are implemented and removed from file
- [ ] Error handling gracefully skips problematic projects
- [ ] All output is clear and informative

## Future Enhancements (Out of Scope)
- Git auto-commit functionality
- Manual todo removal command
- Priority/tagging system
- Cross-project completion tracking
- Recursive project discovery
- Configuration file for work directory path
