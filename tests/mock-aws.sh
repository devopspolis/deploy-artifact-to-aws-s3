#!/bin/bash

# Mock AWS CLI for testing without real AWS resources
# This script simulates AWS CLI behavior for testing purposes

set -e

# Mock AWS S3 operations
mock_aws_s3() {
    local command="$1"
    shift
    
    case "$command" in
        "sync")
            local source="$1"
            local destination="$2"
            echo "Mock: aws s3 sync $source $destination"
            echo "✅ Mock sync completed successfully"
            return 0
            ;;
        "cp")
            local source="$1" 
            local destination="$2"
            echo "Mock: aws s3 cp $source $destination"
            echo "✅ Mock copy completed successfully"
            return 0
            ;;
        "ls")
            local path="$1"
            echo "Mock: aws s3 ls $path"
            echo "2023-01-01 12:00:00      1024 test-file.txt"
            echo "2023-01-01 12:00:00      2048 another-file.txt"
            return 0
            ;;
        "mb")
            local bucket="$1"
            echo "Mock: aws s3 mb $bucket"
            echo "make_bucket: test-bucket"
            return 0
            ;;
        "rb")
            local bucket="$1"
            echo "Mock: aws s3 rb $bucket --force"
            echo "remove_bucket: test-bucket"
            return 0
            ;;
        *)
            echo "Mock AWS S3: Unknown command $command"
            return 1
            ;;
    esac
}

# Mock AWS S3API operations
mock_aws_s3api() {
    local command="$1"
    shift
    
    case "$command" in
        "put-bucket-tagging")
            local bucket=""
            local tagging=""
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --bucket)
                        bucket="$2"
                        shift 2
                        ;;
                    --tagging)
                        tagging="$2"
                        shift 2
                        ;;
                    --region)
                        # Ignore region for mock
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            echo "Mock: aws s3api put-bucket-tagging --bucket $bucket --tagging $tagging"
            echo "✅ Mock bucket tagging completed successfully"
            return 0
            ;;
        *)
            echo "Mock AWS S3API: Unknown command $command"
            return 1
            ;;
    esac
}

# Mock AWS CLI main function
mock_aws() {
    local service="$1"
    shift
    
    case "$service" in
        "--version")
            echo "aws-cli/2.0.0 Python/3.8.0 Linux/5.4.0 botocore/2.0.0"
            return 0
            ;;
        "s3")
            mock_aws_s3 "$@"
            ;;
        "s3api")
            mock_aws_s3api "$@"
            ;;
        *)
            echo "Mock AWS: Unknown service $service"
            return 1
            ;;
    esac
}

# Export mock function to be used as 'aws' command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    mock_aws "$@"
else
    # Script is being sourced
    alias aws='mock_aws'
fi