#!/bin/bash

# TCA Template - Project Rename Script
# This script renames the entire project to a new name

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <NewProjectName>"
    echo ""
    echo "Example: $0 MyAwesomeApp"
    echo "This will rename the project from 'tca-template' to 'MyAwesomeApp'"
    echo ""
    echo "The project name should be in PascalCase without spaces"
}

# Check if project name is provided
if [ $# -eq 0 ]; then
    print_color $RED "Error: New project name is required"
    show_usage
    exit 1
fi

NEW_PROJECT_NAME=$1

# Validate project name
if [[ ! $NEW_PROJECT_NAME =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    print_color $RED "Error: Project name should be in PascalCase without spaces (e.g., MyAwesomeApp)"
    exit 1
fi

# Define current names
OLD_PROJECT_NAME="tca-template"
OLD_APP_NAME="TcaTemplateApp"
OLD_BUNDLE_ID="com.example.tca-template"

# Define new names
NEW_APP_NAME="${NEW_PROJECT_NAME}App"
NEW_BUNDLE_ID="com.example.${NEW_PROJECT_NAME,,}" # Convert to lowercase

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_color $BLUE "Renaming project from '$OLD_PROJECT_NAME' to '$NEW_PROJECT_NAME'"
print_color $YELLOW "Project root: $PROJECT_ROOT"

# Confirm with user
print_color $YELLOW "This will make the following changes:"
print_color $NC "  - Project name: $OLD_PROJECT_NAME → $NEW_PROJECT_NAME"
print_color $NC "  - App name: $OLD_APP_NAME → $NEW_APP_NAME"
print_color $NC "  - Bundle ID: $OLD_BUNDLE_ID → $NEW_BUNDLE_ID"
print_color $NC ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_color $YELLOW "Operation cancelled"
    exit 0
fi

cd "$PROJECT_ROOT"

# 1. Rename directories
print_color $YELLOW "Renaming directories..."
if [ -d "$OLD_PROJECT_NAME" ]; then
    mv "$OLD_PROJECT_NAME" "$NEW_PROJECT_NAME"
    print_color $GREEN "✅ Renamed directory: $OLD_PROJECT_NAME → $NEW_PROJECT_NAME"
fi

if [ -d "${OLD_PROJECT_NAME}.xcodeproj" ]; then
    mv "${OLD_PROJECT_NAME}.xcodeproj" "${NEW_PROJECT_NAME}.xcodeproj"
    print_color $GREEN "✅ Renamed Xcode project: ${OLD_PROJECT_NAME}.xcodeproj → ${NEW_PROJECT_NAME}.xcodeproj"
fi

# 2. Update Package.swift
print_color $YELLOW "Updating Package.swift..."
if [ -f "$NEW_PROJECT_NAME/Package.swift" ]; then
    sed -i '' "s/name: \"$OLD_PROJECT_NAME\"/name: \"$NEW_PROJECT_NAME\"/g" "$NEW_PROJECT_NAME/Package.swift"
    print_color $GREEN "✅ Updated Package.swift"
fi

# 3. Update App files
print_color $YELLOW "Updating App files..."

# Update TcaTemplateApp.swift
if [ -f "App/TcaTemplateApp.swift" ]; then
    sed -i '' "s/TcaTemplateApp/$NEW_APP_NAME/g" "App/TcaTemplateApp.swift"
    mv "App/TcaTemplateApp.swift" "App/${NEW_APP_NAME}.swift"
    print_color $GREEN "✅ Updated and renamed App file"
fi

# 4. Update Xcode project file
print_color $YELLOW "Updating Xcode project configuration..."
if [ -f "${NEW_PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    # Update project name references
    sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" "${NEW_PROJECT_NAME}.xcodeproj/project.pbxproj"
    sed -i '' "s/$OLD_APP_NAME/$NEW_APP_NAME/g" "${NEW_PROJECT_NAME}.xcodeproj/project.pbxproj"
    sed -i '' "s/$OLD_BUNDLE_ID/$NEW_BUNDLE_ID/g" "${NEW_PROJECT_NAME}.xcodeproj/project.pbxproj"
    print_color $GREEN "✅ Updated Xcode project configuration"
fi

# 5. Update workspace settings
if [ -d "${NEW_PROJECT_NAME}.xcodeproj/project.xcworkspace" ]; then
    if [ -f "${NEW_PROJECT_NAME}.xcodeproj/project.xcworkspace/contents.xcworkspacedata" ]; then
        sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" "${NEW_PROJECT_NAME}.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
        print_color $GREEN "✅ Updated workspace settings"
    fi
fi

# 6. Update README.md
print_color $YELLOW "Updating README.md..."
if [ -f "README.md" ]; then
    sed -i '' "s/tca-template/$NEW_PROJECT_NAME/g" "README.md"
    sed -i '' "s/TcaTemplateApp/$NEW_APP_NAME/g" "README.md"
    sed -i '' "s/TCA Template/$NEW_PROJECT_NAME/g" "README.md"
    print_color $GREEN "✅ Updated README.md"
fi

# 7. Update RootView.swift
print_color $YELLOW "Updating RootView.swift..."
if [ -f "App/RootView.swift" ]; then
    sed -i '' "s/TCA Template/$NEW_PROJECT_NAME/g" "App/RootView.swift"
    sed -i '' "s/tca-template/$NEW_PROJECT_NAME/g" "App/RootView.swift"
    print_color $GREEN "✅ Updated RootView.swift"
fi

# 8. Update any other Swift files that might reference the old name
print_color $YELLOW "Updating other Swift files..."
find . -name "*.swift" -not -path "./Scripts/*" -exec sed -i '' "s/tca-template/$NEW_PROJECT_NAME/g" {} \;
print_color $GREEN "✅ Updated Swift files"

# 9. Update documentation files
print_color $YELLOW "Updating documentation..."
if [ -d "docs" ]; then
    find docs -name "*.md" -exec sed -i '' "s/tca-template/$NEW_PROJECT_NAME/g" {} \;
    find docs -name "*.md" -exec sed -i '' "s/TCA Template/$NEW_PROJECT_NAME/g" {} \;
    print_color $GREEN "✅ Updated documentation"
fi

# 10. Clean up any build artifacts
print_color $YELLOW "Cleaning up build artifacts..."
if [ -d "$NEW_PROJECT_NAME/.build" ]; then
    rm -rf "$NEW_PROJECT_NAME/.build"
    print_color $GREEN "✅ Cleaned build artifacts"
fi

if [ -d "DerivedData" ]; then
    rm -rf "DerivedData"
    print_color $GREEN "✅ Cleaned DerivedData"
fi

print_color $GREEN ""
print_color $GREEN "🎉 Project successfully renamed to '$NEW_PROJECT_NAME'!"
print_color $BLUE ""
print_color $BLUE "Summary of changes:"
print_color $NC "  ✅ Project directory renamed"
print_color $NC "  ✅ Xcode project renamed"
print_color $NC "  ✅ Package.swift updated"
print_color $NC "  ✅ App files updated"
print_color $NC "  ✅ Bundle identifier updated"
print_color $NC "  ✅ Documentation updated"
print_color $NC ""
print_color $YELLOW "Next steps:"
print_color $NC "1. Open ${NEW_PROJECT_NAME}.xcodeproj in Xcode"
print_color $NC "2. Clean build folder (Cmd+Shift+K)"
print_color $NC "3. Build and run your renamed project"
print_color $NC "4. Update any additional configuration as needed"
print_color $NC ""
print_color $BLUE "Your new project structure:"
print_color $NC "  📁 ${NEW_PROJECT_NAME}/"
print_color $NC "  📁 ${NEW_PROJECT_NAME}.xcodeproj/"
print_color $NC "  📄 App/${NEW_APP_NAME}.swift"
print_color $NC "  📄 Bundle ID: $NEW_BUNDLE_ID"
