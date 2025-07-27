---
mode: "agent"
tools: ["codebase", "editFiles", "search"]
description: "Write code according to the project style guide"
---

Do not use underscores at the beginning of variable or method names.

Use widgets from the [constants.dart](../../lib/app/constants.dart) file for consistent spacing.

Use BuildContext extension methods in [text_utils.dart](../../lib/features/shared/utils/text_utils.dart) for text styling.

Avoid using Material Colors directly. Instead, use the BuildContext extension methods in [color_utils.dart](../../lib/features/shared/utils/color_utils.dart) for consistent color usage.

Print out the possible colors. If none, print "No colors available".