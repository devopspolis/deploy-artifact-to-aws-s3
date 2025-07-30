#!/bin/bash

# Test script for validating action logic without AWS dependencies
# This can be run locally or in CI environments

set -e

echo "🧪 Starting validation tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -e "\n${YELLOW}Running: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if $test_function; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test bucket name validation
test_bucket_validation() {
    test_bucket_name() {
        local bucket="$1"
        local expected="$2"
        
        # Simulate the validation logic from action.yml
        if [[ "$bucket" =~ ^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$ ]]; then
            result="valid"
        else
            result="invalid"
        fi
        
        if [[ "$result" == "$expected" ]]; then
            return 0
        else
            echo "    Expected: $expected, Got: $result for bucket: $bucket"
            return 1
        fi
    }
    
    # Valid bucket names
    test_bucket_name "my-test-bucket" "valid" || return 1
    test_bucket_name "test123" "valid" || return 1
    test_bucket_name "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6" "valid" || return 1
    
    # Invalid bucket names
    test_bucket_name "My-Bucket" "invalid" || return 1
    test_bucket_name "a" "invalid" || return 1
    test_bucket_name "bucket_with_underscores" "invalid" || return 1
    test_bucket_name "bucket-" "invalid" || return 1
    test_bucket_name "-bucket" "invalid" || return 1
    test_bucket_name "" "invalid" || return 1
    
    return 0
}

# Test IAM role ARN validation
test_role_validation() {
    test_role_arn() {
        local role="$1"
        local expected="$2"
        
        # Simulate the validation logic from action.yml
        if [[ -n "$role" ]] && [[ "$role" == arn:aws:iam::* ]]; then
            if [[ "$role" =~ ^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@_-]+$ ]]; then
                result="valid"
            else
                result="invalid"
            fi
        else
            result="short_name_or_empty"
        fi
        
        if [[ "$result" == "$expected" ]]; then
            return 0
        else
            echo "    Expected: $expected, Got: $result for role: $role"
            return 1
        fi
    }
    
    # Valid ARNs
    test_role_arn "arn:aws:iam::123456789012:role/MyRole" "valid" || return 1
    test_role_arn "arn:aws:iam::123456789012:role/Role-With-Dashes" "valid" || return 1
    test_role_arn "arn:aws:iam::123456789012:role/Role_With_Underscores" "valid" || return 1
    
    # Invalid ARNs
    test_role_arn "arn:aws:iam::invalid:role/MyRole" "invalid" || return 1
    test_role_arn "arn:aws:iam::123456789012:role/" "invalid" || return 1
    
    # Short names (should be handled differently)
    test_role_arn "MyRole" "short_name_or_empty" || return 1
    test_role_arn "" "short_name_or_empty" || return 1
    
    return 0
}

# Test tag format validation
test_tag_validation() {
    test_tags() {
        local tags="$1"
        local expected="$2"
        
        # Simulate the validation logic from action.yml
        if [[ -n "$tags" ]]; then
            IFS=',' read -ra PAIRS <<< "$tags"
            for pair in "${PAIRS[@]}"; do
                if [[ ! "$pair" =~ ^[^=]+=[^=]+$ ]]; then
                    result="invalid"
                    return 0
                fi
            done
            result="valid"
        else
            result="empty"
        fi
        
        if [[ "$result" == "$expected" ]]; then
            return 0
        else
            echo "    Expected: $expected, Got: $result for tags: $tags"
            return 1  
        fi
    }
    
    # Valid tags
    test_tags "env=prod" "valid" || return 1
    test_tags "env=prod,version=1.2.3" "valid" || return 1
    test_tags "environment=production,team=devops,version=1.0.0" "valid" || return 1
    
    # Invalid tags
    test_tags "env" "invalid" || return 1
    test_tags "env=prod,invalid" "invalid" || return 1
    test_tags "=value" "invalid" || return 1
    test_tags "key=" "invalid" || return 1
    
    # Empty tags
    test_tags "" "empty" || return 1
    
    return 0
}

# Test archive format detection
test_format_detection() {
    test_format() {
        local filename="$1"
        local expected="$2"
        
        # Simulate the format detection logic from action.yml
        filename_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
        case "$filename_lower" in
            *.zip)
                format="zip"
                ;;
            *.tar.gz|*.tgz)
                format="tar.gz"
                ;;
            *.tar.bz2|*.tbz2)
                format="tar.bz2"
                ;;
            *.tar.xz|*.txz)
                format="tar.xz"
                ;;
            *.tar)
                format="tar"
                ;;
            *)
                format="unsupported"
                ;;
        esac
        
        if [[ "$format" == "$expected" ]]; then
            return 0
        else
            echo "    Expected: $expected, Got: $format for file: $filename"
            return 1
        fi
    }
    
    # Supported formats
    test_format "test.zip" "zip" || return 1
    test_format "TEST.ZIP" "zip" || return 1
    test_format "archive.tar" "tar" || return 1
    test_format "archive.tar.gz" "tar.gz" || return 1
    test_format "archive.tgz" "tar.gz" || return 1
    test_format "archive.tar.bz2" "tar.bz2" || return 1
    test_format "archive.tbz2" "tar.bz2" || return 1
    test_format "archive.tar.xz" "tar.xz" || return 1
    test_format "archive.txz" "tar.xz" || return 1
    
    # Unsupported formats
    test_format "file.txt" "unsupported" || return 1
    test_format "file.rar" "unsupported" || return 1
    test_format "file.7z" "unsupported" || return 1
    
    return 0
}

# Test bucket prefix parsing
test_bucket_parsing() {
    test_parsing() {
        local input_bucket="$1"
        local expected_name="$2"  
        local expected_prefix="$3"
        
        # Simulate the bucket parsing logic from action.yml
        bucket_name=$(echo "$input_bucket" | cut -d'/' -f1)
        bucket_prefix=$(echo "$input_bucket" | cut -s -d'/' -f2-)
        if [ -n "$bucket_prefix" ]; then
            bucket_prefix="${bucket_prefix%/}/"
        fi
        
        if [[ "$bucket_name" == "$expected_name" ]] && [[ "$bucket_prefix" == "$expected_prefix" ]]; then
            return 0
        else
            echo "    Input: $input_bucket"
            echo "    Expected name: $expected_name, Got: $bucket_name"
            echo "    Expected prefix: $expected_prefix, Got: $bucket_prefix"
            return 1
        fi
    }
    
    # Test various bucket formats
    test_parsing "my-bucket" "my-bucket" "" || return 1
    test_parsing "my-bucket/path" "my-bucket" "path/" || return 1
    test_parsing "my-bucket/path/to/files" "my-bucket" "path/to/files/" || return 1
    test_parsing "my-bucket/path/" "my-bucket" "path/" || return 1
    
    return 0
}

# Run all tests
echo "🚀 Starting Action Validation Tests"
echo "=================================="

run_test "Bucket Name Validation" "test_bucket_validation"
run_test "IAM Role ARN Validation" "test_role_validation"  
run_test "Tag Format Validation" "test_tag_validation"
run_test "Archive Format Detection" "test_format_detection"
run_test "Bucket Prefix Parsing" "test_bucket_parsing"

# Print summary
echo ""
echo "=================================="
echo "🧪 Test Summary"
echo "=================================="
echo "Tests Run: $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed.${NC}"
    exit 1
fi