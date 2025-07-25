#!/bin/bash

# TCA Template - Development Environment Setup Script
# This script sets up the development environment for the TCA template

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Xcode version
check_xcode() {
    if command_exists xcodebuild; then
        local xcode_version=$(xcodebuild -version | head -n 1 | awk '{print $2}')
        print_color $GREEN "✅ Xcode $xcode_version found"
        
        # Check if Xcode version is 15.0 or later (required for Swift 6.0)
        local major_version=$(echo $xcode_version | cut -d. -f1)
        if [ "$major_version" -ge 15 ]; then
            print_color $GREEN "✅ Xcode version supports Swift 6.0"
        else
            print_color $YELLOW "⚠️  Xcode 15.0+ recommended for Swift 6.0 support"
        fi
    else
        print_color $RED "❌ Xcode not found. Please install Xcode from the App Store."
        exit 1
    fi
}

# Function to check Swift version
check_swift() {
    if command_exists swift; then
        local swift_version=$(swift --version | head -n 1 | awk '{print $4}')
        print_color $GREEN "✅ Swift $swift_version found"
    else
        print_color $RED "❌ Swift not found. Please install Xcode Command Line Tools."
        exit 1
    fi
}

# Function to setup git hooks
setup_git_hooks() {
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local hooks_dir="$project_root/.git/hooks"
    
    if [ -d "$project_root/.git" ]; then
        print_color $YELLOW "Setting up Git hooks..."
        
        # Create pre-commit hook for running tests
        cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook to run tests

echo "Running tests before commit..."
cd "$(git rev-parse --show-toplevel)"

# Run Swift tests
if [ -d "tca-template" ]; then
    cd tca-template
    swift test
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed. Commit aborted."
        exit 1
    fi
    cd ..
fi

echo "✅ All tests passed!"
EOF
        
        chmod +x "$hooks_dir/pre-commit"
        print_color $GREEN "✅ Git pre-commit hook installed"
        
        # Create pre-push hook for additional checks
        cat > "$hooks_dir/pre-push" << 'EOF'
#!/bin/bash
# Pre-push hook for additional checks

echo "Running pre-push checks..."
cd "$(git rev-parse --show-toplevel)"

# Check for TODO/FIXME comments in main branch
if git diff --name-only origin/main...HEAD | grep -E '\.(swift|md)$' | xargs grep -l "TODO\|FIXME" > /dev/null 2>&1; then
    echo "⚠️  Found TODO/FIXME comments in changed files. Consider addressing them before pushing."
fi

echo "✅ Pre-push checks completed!"
EOF
        
        chmod +x "$hooks_dir/pre-push"
        print_color $GREEN "✅ Git pre-push hook installed"
    else
        print_color $YELLOW "⚠️  Not a Git repository. Skipping Git hooks setup."
    fi
}

# Function to create development configuration
create_dev_config() {
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    # Create .swiftformat configuration
    cat > "$project_root/.swiftformat" << 'EOF'
# SwiftFormat configuration for TCA Template

# Indentation
--indent 2
--tabwidth 2
--smarttabs enabled

# Spacing
--trimwhitespace always
--insertlines enabled
--removelines enabled

# Wrapping
--maxwidth 100
--wraparguments before-first
--wrapparameters before-first
--wrapcollections before-first

# Organization
--importgrouping testable-bottom
--commas always

# Rules
--enable isEmpty
--enable sortedImports
--enable redundantSelf
--enable trailingCommas

# Disable problematic rules for TCA
--disable hoistPatternLet
--disable redundantPattern
EOF
    
    print_color $GREEN "✅ SwiftFormat configuration created"
    
    # Create .swiftlint.yml configuration
    cat > "$project_root/.swiftlint.yml" << 'EOF'
# SwiftLint configuration for TCA Template

# Included and excluded paths
included:
  - tca-template/Sources
  - tca-template/Tests
  - App

excluded:
  - tca-template/.build
  - Scripts

# Rules
disabled_rules:
  - trailing_whitespace
  - line_length # Handled by SwiftFormat

opt_in_rules:
  - empty_count
  - empty_string
  - first_where
  - sorted_imports
  - vertical_parameter_alignment_on_call

# Rule configurations
identifier_name:
  min_length: 1
  max_length: 50

type_name:
  min_length: 3
  max_length: 50

function_body_length:
  warning: 50
  error: 100

file_length:
  warning: 500
  error: 1000

cyclomatic_complexity:
  warning: 10
  error: 20
EOF
    
    print_color $GREEN "✅ SwiftLint configuration created"
}

# Function to install development tools
install_dev_tools() {
    print_color $YELLOW "Checking development tools..."
    
    # Check for Homebrew
    if command_exists brew; then
        print_color $GREEN "✅ Homebrew found"
        
        # Install SwiftFormat if not present
        if ! command_exists swiftformat; then
            print_color $YELLOW "Installing SwiftFormat..."
            brew install swiftformat
            print_color $GREEN "✅ SwiftFormat installed"
        else
            print_color $GREEN "✅ SwiftFormat already installed"
        fi
        
        # Install SwiftLint if not present
        if ! command_exists swiftlint; then
            print_color $YELLOW "Installing SwiftLint..."
            brew install swiftlint
            print_color $GREEN "✅ SwiftLint installed"
        else
            print_color $GREEN "✅ SwiftLint already installed"
        fi
    else
        print_color $YELLOW "⚠️  Homebrew not found. Install it from https://brew.sh for additional development tools."
    fi
}

# Function to resolve Swift packages
resolve_packages() {
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    if [ -d "$project_root/tca-template" ]; then
        print_color $YELLOW "Resolving Swift packages..."
        cd "$project_root/tca-template"
        swift package resolve
        print_color $GREEN "✅ Swift packages resolved"
        cd "$project_root"
    fi
}

# Function to run initial tests
run_initial_tests() {
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    if [ -d "$project_root/tca-template" ]; then
        print_color $YELLOW "Running initial tests..."
        cd "$project_root/tca-template"
        swift test
        if [ $? -eq 0 ]; then
            print_color $GREEN "✅ All tests passed"
        else
            print_color $YELLOW "⚠️  Some tests failed. This might be expected for a new setup."
        fi
        cd "$project_root"
    fi
}

# Main setup function
main() {
    print_color $BLUE "🚀 Setting up TCA Template development environment..."
    print_color $BLUE "=================================================="
    
    # Check prerequisites
    print_color $YELLOW "Checking prerequisites..."
    check_xcode
    check_swift
    
    # Install development tools
    install_dev_tools
    
    # Create development configuration
    create_dev_config
    
    # Setup Git hooks
    setup_git_hooks
    
    # Resolve packages
    resolve_packages
    
    # Run initial tests
    run_initial_tests
    
    print_color $GREEN ""
    print_color $GREEN "🎉 Development environment setup complete!"
    print_color $BLUE ""
    print_color $BLUE "What was set up:"
    print_color $NC "  ✅ Verified Xcode and Swift installation"
    print_color $NC "  ✅ Installed/verified SwiftFormat and SwiftLint"
    print_color $NC "  ✅ Created development configuration files"
    print_color $NC "  ✅ Set up Git hooks for quality assurance"
    print_color $NC "  ✅ Resolved Swift package dependencies"
    print_color $NC "  ✅ Ran initial test suite"
    print_color $NC ""
    print_color $YELLOW "Next steps:"
    print_color $NC "1. Open the project in Xcode: open tca-template.xcodeproj"
    print_color $NC "2. Build and run the project (Cmd+R)"
    print_color $NC "3. Start developing your features!"
    print_color $NC ""
    print_color $BLUE "Development commands:"
    print_color $NC "  • Format code: swiftformat ."
    print_color $NC "  • Lint code: swiftlint"
    print_color $NC "  • Run tests: swift test"
    print_color $NC "  • Generate feature: ./Scripts/generate-feature.sh FeatureName"
}

# Run main function
main "$@"
