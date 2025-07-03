<div style="display: flex; align-items: center;">
  <img src="logo.png" alt="Logo" width="50" height="50" style="margin-right: 10px;"/>
  <span style="font-size: 2.2em;">Deploy Artifact to AWS S3</span>
</div>

![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Deploy%20Artifact%20to%20AWS%20S3-blue?logo=github)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p>
This GitHub Action deploys an artifact from your workflow to an AWS S3 bucket. It supports multiple archive formats, optional extraction, tagging, and nested S3 prefixes.
</p>

See more [GitHub Actions by DevOpspolis](https://github.com/marketplace?query=devopspolis&type=actions)

---

## 📙 Table of Contents
- [✨ Features](#features)
- [📥 Inputs](#inputs)
- [📤 Outputs](#outputs)
- [📦 Usage](#usage)
- [🚦 Requirements](#requirements)
- [🧑‍⚖️ Legal](#legal)

---

## ✨ Features
- Uploads artifacts from GitHub workflows to AWS S3
- Supports `.zip`, `.tar`, `.tar.gz`, or no archive
- Optional artifact extraction before upload
- Support for S3 bucket prefixes (e.g., `my-bucket/docs/2024/`)
- Optional bucket tagging
- Outputs integrity hash for validation

---

## 📥 Inputs

| Name               | Description                                                                 | Required | Default   |
| ------------------ | --------------------------------------------------------------------------- | -------- | --------- |
| `artifact-name`    | The name of the GitHub Actions artifact to deploy (without extension)       | true     | —         |
| `bucket`           | The S3 bucket name (optionally with prefix, e.g. `my-bucket/docs/`)         | true     | —         |
| `bucket_region`    | The AWS region where the bucket resides                                     | true     | —         |
| `delete`           | Whether to delete files in the bucket not found in the source               | false    | `true`    |
| `extract-artifact` | Whether to extract the archive and upload contents                          | false    | `true`    |
| `archive-format`   | Format of the archive (`zip`, `tar`, `tar.gz`, or `none`)                   | false    | `zip`     |
| `tags`             | Comma-separated list of tags to apply to the bucket (e.g. `env=qa,ver=1.0`) | false    | ''        |
| `role`             | IAM role ARN or name to assume for deployment                               | false    | —         |

---

## 📤 Outputs

| Name             | Description                                   |
| ---------------- | --------------------------------------------- |
| `bucket_arn`     | The ARN of the deployed S3 bucket             |
| `integrity_hash` | The MD5 integrity hash of the uploaded files |

---

## 📦 Usage

### Syntax
```yaml
uses: devopspolis/deploy-artifact-to-aws-s3@<version>
with:
  [inputs]
```

### Example 1 - Upload extracted ZIP contents to a nested prefix
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy extracted contents to AWS S3
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: site
          bucket: my-site-bucket/docs/2024/
          bucket_region: us-west-2
          extract-artifact: true
```

### Example 2 - Upload raw TAR.GZ without extracting
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Upload TAR.GZ to S3
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: bundle
          bucket: my-archive-bucket/backups/
          bucket_region: us-east-1
          extract-artifact: false
          archive-format: tar.gz
```

### Example 3 - Add S3 bucket tags
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with tags
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: site
          bucket: my-bucket/releases/2024-07-03
          bucket_region: us-west-2
          extract-artifact: true
          tags: version=1.2.3,environment=production
```

---

## 🚦 Requirements

1. The calling workflow must provide access and permission to upload to the AWS S3 bucket.
2. Best practice is to use OIDC authentication and assume a role with access to S3.

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Set up AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ vars.AWS_ACCOUNT_ID }}:role/deploy-artifact-role
          aws-region: ${{ vars.AWS_REGION }}
        env:
          AWS_ACCOUNT_ID: ${{ vars.AWS_ACCOUNT_ID }}
```

---

## 🧑‍⚖️ Legal
The MIT License (MIT)
