#!/bin/bash

# Your app's package name
PACKAGE_NAME="fitjo"
TEMPLATE_PACKAGE="slapp"

echo "Fetching template updates..."
git fetch template

# Store the current branch
CURRENT_BRANCH=$(git branch --show-current)

echo "Merging template changes..."
# Use squash merge to combine all template commits into one
git merge template/main --squash --no-commit

# If there are conflicts, resolve them
if [ $? -ne 0 ]; then
    echo "Resolving conflicts..."
    git checkout --theirs .
    git add .
fi

# Update package names in all Dart files
find . -type f -name "*.dart" -exec sed -i '' "s/package:$TEMPLATE_PACKAGE/package:$PACKAGE_NAME/g" {} +

# Update pubspec.yaml name
sed -i '' "s/name: $TEMPLATE_PACKAGE/name: $PACKAGE_NAME/g" pubspec.yaml

# Stage all changes
git add .

# Create a single commit
git commit -m "Update from template ($(date +%Y-%m-%d))"
echo "✅ Successfully merged template updates in a single commit"