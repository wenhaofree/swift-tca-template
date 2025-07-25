#!/bin/bash

# TCA Template - Test Runner Script
# This script runs comprehensive tests for the TCA template

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
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --verbose       Run tests with verbose output"
    echo "  -c, --coverage      Generate code coverage report"
    echo "  -f, --filter <name> Run only tests matching the filter"
    echo "  --parallel          Run tests in parallel"
    echo "  --clean             Clean build before running tests"
    echo ""
    echo "Examples:"
    echo "  $0                  Run all tests"
    echo "  $0 --verbose        Run tests with detailed output"
    echo "  $0 --filter Login   Run only LoginCore tests"
    echo "  $0 --coverage       Run tests and generate coverage report"
}

# Default options
VERBOSE=false
COVERAGE=false
FILTER=""
PARALLEL=false
CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -f|--filter)
            FILTER="$2"
            shift 2
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        *)
            print_color $RED "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGE_DIR="$PROJECT_ROOT/tca-template"

print_color $BLUE "🧪 Running TCA Template Tests"
print_color $BLUE "============================="

# Check if package directory exists
if [ ! -d "$PACKAGE_DIR" ]; then
    print_color $RED "❌ Package directory not found: $PACKAGE_DIR"
    exit 1
fi

cd "$PACKAGE_DIR"

# Clean build if requested
if [ "$CLEAN" = true ]; then
    print_color $YELLOW "🧹 Cleaning build artifacts..."
    swift package clean
    print_color $GREEN "✅ Build cleaned"
fi

# Build test command
TEST_CMD="swift test"

# Add verbose flag if requested
if [ "$VERBOSE" = true ]; then
    TEST_CMD="$TEST_CMD --verbose"
fi

# Add parallel flag if requested
if [ "$PARALLEL" = true ]; then
    TEST_CMD="$TEST_CMD --parallel"
fi

# Add filter if specified
if [ -n "$FILTER" ]; then
    TEST_CMD="$TEST_CMD --filter $FILTER"
    print_color $YELLOW "🔍 Running tests matching filter: $FILTER"
fi

# Add coverage if requested
if [ "$COVERAGE" = true ]; then
    TEST_CMD="$TEST_CMD --enable-code-coverage"
    print_color $YELLOW "📊 Code coverage enabled"
fi

print_color $YELLOW "🚀 Running tests..."
print_color $BLUE "Command: $TEST_CMD"
print_color $NC ""

# Run tests and capture exit code
set +e
eval $TEST_CMD
TEST_EXIT_CODE=$?
set -e

# Check test results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    print_color $GREEN ""
    print_color $GREEN "🎉 All tests passed!"
    
    # Generate coverage report if requested
    if [ "$COVERAGE" = true ]; then
        print_color $YELLOW ""
        print_color $YELLOW "📊 Generating coverage report..."
        
        # Check if xcov is available for better coverage reports
        if command -v xcov >/dev/null 2>&1; then
            xcov --scheme tca-template --output_directory coverage_report
            print_color $GREEN "✅ Coverage report generated in coverage_report/"
        else
            print_color $YELLOW "⚠️  xcov not found. Install with: gem install xcov"
            print_color $YELLOW "📊 Basic coverage info available in Xcode"
        fi
    fi
    
    # Show test summary
    print_color $BLUE ""
    print_color $BLUE "📋 Test Summary:"
    print_color $NC "  ✅ All test modules passed"
    print_color $NC "  📦 Package: tca-template"
    
    if [ -n "$FILTER" ]; then
        print_color $NC "  🔍 Filter: $FILTER"
    fi
    
    if [ "$COVERAGE" = true ]; then
        print_color $NC "  📊 Coverage: Enabled"
    fi
    
else
    print_color $RED ""
    print_color $RED "❌ Tests failed with exit code: $TEST_EXIT_CODE"
    
    print_color $YELLOW ""
    print_color $YELLOW "🔧 Troubleshooting tips:"
    print_color $NC "  1. Check the test output above for specific failures"
    print_color $NC "  2. Run with --verbose for more detailed output"
    print_color $NC "  3. Run specific test modules with --filter"
    print_color $NC "  4. Clean build with --clean and try again"
    print_color $NC ""
    print_color $YELLOW "📚 Common issues:"
    print_color $NC "  • Missing dependencies: swift package resolve"
    print_color $NC "  • Outdated packages: swift package update"
    print_color $NC "  • Build cache issues: swift package clean"
    
    exit $TEST_EXIT_CODE
fi

# Show available test modules
print_color $BLUE ""
print_color $BLUE "📚 Available test modules:"
find Tests -name "*Tests" -type d | while read -r test_dir; do
    module_name=$(basename "$test_dir")
    print_color $NC "  • $module_name"
done

print_color $BLUE ""
print_color $BLUE "🛠  Development commands:"
print_color $NC "  • Run specific module: $0 --filter ModuleName"
print_color $NC "  • Verbose output: $0 --verbose"
print_color $NC "  • Coverage report: $0 --coverage"
print_color $NC "  • Clean build: $0 --clean"
print_color $NC "  • Parallel execution: $0 --parallel"

print_color $GREEN ""
print_color $GREEN "✨ Happy testing!"
