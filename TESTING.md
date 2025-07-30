# Testing Guide

This document describes the testing strategy and available tests for the Deploy Artifact to AWS S3 GitHub Action.

## 🧪 Testing Strategy

### Test Levels

1. **Unit Tests** - Test individual validation functions and logic
2. **Integration Tests** - Test the complete action workflow without AWS 
3. **End-to-End Tests** - Test with real AWS resources (optional)
4. **Format Tests** - Test different archive format handling

### Test Execution

Tests are automatically run on:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

## 🚀 Available Tests

### 1. Automated GitHub Workflow (`.github/workflows/test-action.yml`)

**Test Jobs:**
- `lint-and-validate` - Validates action.yml syntax and structure
- `test-input-validation` - Tests input validation logic
- `test-action-validation-only` - Tests action without AWS credentials
- `test-different-formats` - Tests all supported archive formats
- `test-with-mocked-aws` - Integration tests with mock AWS (disabled by default)

**Run Tests:**
```bash
# Tests run automatically on push/PR
# Or trigger manually in GitHub Actions tab
```

### 2. Local Validation Tests (`tests/test-validation.sh`)

Unit tests for validation logic that can be run locally:

```bash
# Run locally
./tests/test-validation.sh

# Expected output:
# 🧪 Starting validation tests...
# ✅ PASSED: Bucket Name Validation
# ✅ PASSED: IAM Role ARN Validation
# ✅ PASSED: Tag Format Validation
# ✅ PASSED: Archive Format Detection
# ✅ PASSED: Bucket Prefix Parsing
# 🎉 All tests passed!
```

**Tests Include:**
- Bucket name validation (AWS naming rules)
- IAM role ARN format validation
- Tag format validation
- Archive format detection
- Bucket prefix parsing

### 3. Mock AWS Tests (`tests/mock-aws.sh`)

Mock AWS CLI for testing without real resources:

```bash
# Source the mock
source tests/mock-aws.sh

# Test mock AWS commands
aws s3 ls s3://test-bucket/
aws s3 sync ./local-dir s3://test-bucket/
aws s3api put-bucket-tagging --bucket test-bucket --tagging TagSet='[{Key=env,Value=test}]'
```

## 🔧 Local Testing Setup

### Prerequisites
- Bash shell
- Basic Unix tools (tar, zip, unzip)
- Python 3 (for YAML validation)

### Running Tests Locally

1. **Run validation tests:**
   ```bash
   ./tests/test-validation.sh
   ```

2. **Test with mock AWS:**
   ```bash
   source tests/mock-aws.sh
   # Now 'aws' commands will use mocks
   ```

3. **Validate action.yml syntax:**
   ```bash
   python3 -c "
   with open('action.yml', 'r') as f:
       content = f.read()
   required = ['name:', 'description:', 'inputs:', 'outputs:', 'runs:']
   for section in required:
       assert section in content, f'Missing: {section}'
   print('✅ action.yml syntax valid')
   "
   ```

## 🌐 Integration Testing with Real AWS

### Setup (Optional)

For full integration testing with real AWS resources:

1. **Enable integration tests:**
   ```yaml
   # In .github/workflows/test-action.yml
   test-with-mocked-aws:
     if: true  # Change from 'false' to 'true'
   ```

2. **Add AWS credentials to repository secrets:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

3. **Configure test bucket:**
   ```yaml
   env:
     TEST_BUCKET: your-test-bucket-name
   ```

### Integration Test Flow

1. Creates temporary S3 bucket
2. Uploads test artifacts
3. Runs the action with various configurations
4. Verifies files uploaded correctly
5. Cleans up test resources

## 📊 Test Coverage

### Covered Scenarios

✅ **Input Validation:**
- Bucket name format validation
- IAM role ARN validation  
- Tag format validation
- Required input checking

✅ **Archive Handling:**
- ZIP, TAR, TAR.GZ, TAR.BZ2, TAR.XZ formats
- Case-insensitive extension detection
- Extraction validation

✅ **Logic Testing:**
- Bucket prefix parsing
- Format detection algorithms
- Error message validation

✅ **Workflow Testing:**
- Action execution without AWS
- Expected failure scenarios
- Output validation

### Not Covered (Require Real AWS)

⚠️ **AWS Integration:**
- Actual S3 upload/sync operations
- IAM role assumption
- S3 bucket tagging
- Error handling with real AWS errors

## 🐛 Debugging Tests

### GitHub Actions Debugging

Enable debug logging:
1. Go to repository Settings → Secrets
2. Add secret: `ACTIONS_STEP_DEBUG` = `true`
3. Re-run workflow for verbose logs

### Local Test Debugging

```bash
# Run with verbose output
bash -x ./tests/test-validation.sh

# Test specific functions
source ./tests/test-validation.sh
test_bucket_validation
```

### Common Issues

1. **Permission Denied:**
   ```bash
   chmod +x tests/*.sh
   ```

2. **AWS CLI Not Found (in mocks):**
   ```bash
   # Make sure mock is sourced
   source tests/mock-aws.sh
   ```

3. **YAML Validation Errors:**
   ```bash
   # Check action.yml formatting
   python3 -c "import yaml; yaml.safe_load(open('action.yml'))"
   ```

## 📈 Adding New Tests

### Adding Unit Tests

1. **Add test function to `tests/test-validation.sh`:**
   ```bash
   test_new_feature() {
       # Your test logic here
       return 0  # success
   }
   ```

2. **Register test in main section:**
   ```bash
   run_test "New Feature Test" "test_new_feature"
   ```

### Adding GitHub Workflow Tests

1. **Add new job to `.github/workflows/test-action.yml`:**
   ```yaml
   test-new-feature:
     name: Test New Feature
     runs-on: ubuntu-latest
     steps:
       - name: Test step
         run: echo "Test logic here"
   ```

2. **Update summary job dependencies:**
   ```yaml
   needs: [existing-jobs, test-new-feature]
   ```

## 🎯 Best Practices

1. **Test Early and Often** - Run tests before committing
2. **Mock External Dependencies** - Use mocks for AWS to avoid costs
3. **Test Edge Cases** - Invalid inputs, empty values, malformed data
4. **Validate Outputs** - Check that outputs match expected formats
5. **Clean Up Resources** - Always clean up test resources in integration tests

## 📋 Test Checklist

Before releasing:

- [ ] All unit tests pass locally
- [ ] GitHub workflow tests pass
- [ ] Format detection works for all supported types
- [ ] Input validation catches invalid inputs
- [ ] Action fails gracefully without AWS credentials
- [ ] Documentation is updated for new features