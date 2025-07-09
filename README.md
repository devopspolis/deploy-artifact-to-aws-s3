# 🚀 Deploy Artifact to AWS S3

![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Deploy%20Artifact%20to%20AWS%20S3-blue?logo=github)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This GitHub Action uploads GitHub Actions artifacts to AWS S3 with support for automatic extraction, pre-processing scripts, tagging, and S3 prefixes. It supports ZIP, TAR, and TAR.GZ formats with intelligent format detection.

---

## ✨ Features

- 📦 **Smart Archive Handling**: Automatically detects and extracts ZIP, TAR, and TAR.GZ files
- 🔧 **Pre-upload Processing**: Run custom shell scripts before uploading to S3
- 🏷️ **S3 Bucket Tagging**: Apply tags to your S3 bucket for better organization
- 📍 **Prefix Support**: Upload to specific paths within your S3 bucket
- 🔒 **IAM Role Support**: Assume IAM roles for secure deployment
- 🛡️ **Integrity Verification**: Generate MD5 hashes for upload verification
- 🗑️ **Sync Mode**: Optionally delete files not present in source

---

## 📥 Inputs

| Name                | Description                                                                      | Required  | Default   |
|---------------------|----------------------------------------------------------------------------------|-----------|-----------|
| `artifact`          | Name of the GitHub Actions artifact to deploy                                    | ✅ Yes    | —         |
| `path`              | File path to the artifact within the download directory                          | ✅ Yes    | —         |
| `bucket`            | S3 bucket name (optionally with prefix, e.g. `my-bucket/docs/`)                  | ✅ Yes    | —         |
| `aws-region`        | AWS region for S3 operations                                                     | ❌ No     | `$AWS_REGION` \| `$AWS_DEFAULT_REGION` \| `us-east-1` |
| `extract-artifact`  | Whether to extract the artifact before uploading                                 | ❌ No     | `false`   |
| `delete`            | Delete files in S3 not present in source (sync mode)                             | ❌ No     | `false`   |
| `tags`              | Comma-separated bucket tags (e.g. `version=v1.2.0,environment=qa`)               | ❌ No     | —         |
| `script`            | Optional shell script to execute before uploading to S3                          | ❌ No     | —         |
| `working-directory` | Directory to execute the script in                                               | ❌ No     | `.`       |
| `role`              | IAM role ARN or short name to assume (requires `AWS_ACCOUNT_ID` for short names) | ❌ No     | —         |

---

## 📤 Outputs

| Name            | Description                               |
|------------------|-------------------------------------------|
| `bucket_arn`     | ARN of the target S3 bucket               |
| `uploaded_uri`   | Full S3 URI to the uploaded file/folder   |
| `integrity_hash` | MD5 hash of uploaded contents             |

---

## 📦 Example Usage

### Basic Usage - Extract and Upload ZIP Contents

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Upload website
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact: build-output
          path: website.zip
          bucket: my-website-bucket
          aws-region: us-west-2
```

### Upload to S3 with Prefix

```yaml
- name: Deploy to staging
  uses: devopspolis/deploy-artifact-to-aws-s3@main
  with:
    artifact: build-output
    path: dist.zip
    bucket: my-bucket/staging/v1.2.0/
    aws-region: us-east-1
    tags: environment=staging,version=v1.2.0
```

### Upload Raw Archive Without Extraction

```yaml
- name: Upload backup archive
  uses: devopspolis/deploy-artifact-to-aws-s3@main
  with:
    artifact: backup
    path: backup.tar.gz
    bucket: backup-bucket
    extract-artifact: false
    delete: false
```

### Advanced Usage with Pre-upload Script

```yaml
- name: Deploy with processing
  uses: devopspolis/deploy-artifact-to-aws-s3@main
  with:
    artifact: app-build
    path: app-build.zip
    bucket: production-bucket/releases/
    script: ./scripts/prepare-deploy.sh
    working-directory: .
    aws-region: us-west-2
    tags: environment=production,deployed-by=github-actions
```

### Using IAM Role Assumption

```yaml
- name: Deploy with assumed role
  uses: devopspolis/deploy-artifact-to-aws-s3@main
  with:
    artifact: webapp
    path: webapp.zip
    bucket: secure-bucket
    role: arn:aws:iam::123456789012:role/DeploymentRole
    aws-region: us-east-1
```

### Using Short Role Name

```yaml
- name: Deploy with short role name
  uses: devopspolis/deploy-artifact-to-aws-s3@main
  with:
    artifact: webapp
    path: webapp.zip
    bucket: secure-bucket
    role: DeploymentRole  # Will be expanded to full ARN
  env:
    AWS_ACCOUNT_ID: 123456789012  # Required for short role names
    AWS_REGION: us-east-1
```

---

## 🔧 Supported Archive Formats

The action automatically detects archive formats based on file extensions:

- **ZIP**: `.zip`
- **TAR**: `.tar`
- **TAR.GZ**: `.tar.gz`, `.tgz`

When `extract-artifact` is `true` (default), the action will extract the archive and upload its contents. When `false`, the archive file is uploaded as-is.

---

## 🏷️ S3 Bucket Tagging

You can apply tags to your S3 bucket using the `tags` input:

```yaml
tags: environment=production,version=v1.2.0,team=frontend
```

Tags should be formatted as comma-separated key=value pairs.

---

## 🔒 IAM Permissions

Your AWS credentials or IAM role must have the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:PutBucketTagging"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }
  ]
}
```

---

## 🛠️ Troubleshooting

### Common Issues

1. **Unsupported file format**: Ensure your artifact uses supported extensions (`.zip`, `.tar`, `.tar.gz`, `.tgz`)
2. **Script not executable**: Make sure your pre-upload script has execute permissions
3. **Missing AWS credentials**: Verify AWS credentials are configured or IAM role is properly assumed
4. **Short role name failure**: When using short role names, ensure `AWS_ACCOUNT_ID` environment variable is set

### Debug Mode

Enable debug logging by setting the `ACTIONS_STEP_DEBUG` secret to `true` in your repository settings.

---

## 📋 Full Workflow Example

```yaml
name: Deploy to S3

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build application
        run: |
          # Your build commands here
          npm install
          npm run build

      - name: Create artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to S3
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact: build-output
          path: build-output.zip
          bucket: my-website-bucket/production/
          aws-region: us-west-2
          tags: environment=production,deployed-at=${{ github.run_number }}
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.