<div style="display: flex; align-items: center;">
  <img src="logo.png" alt="Logo" width="50" height="50" style="margin-right: 10px;"/>
  <span style="font-size: 2.2em;">Deploy artifact to AWS S3</span>
</div>

<p>
This GitHub Action deploys a GitHub artifact to an AWS S3 bucket. It can either extract and upload the contents of the ZIP or upload the ZIP file as-is. It supports deleting files not present in the source and applying tags to the target S3 bucket.
</p>

---

## 📚 Table of Contents

- [📥 Inputs](#inputs)
- [📤 Outputs](#outputs)
- [📦 Usage](#usage)
- [🚦 Requirements](#requirements)

---
<!-- trunk-ignore(markdownlint/MD033) -->
<a id="inputs"></a>
## 📥 Inputs

| Name               | Description                                                                 | Required | Default |
| ------------------ | --------------------------------------------------------------------------- | -------- | ------- |
| `artifact-name`    | The name of the GitHub Actions artifact to deploy (without `.zip`)          | true     | —       |
| `bucket`           | The S3 bucket name (destination)                                            | true     | —       |
| `bucket_region`    | The AWS region where the bucket resides                                     | true     | —       |
| `delete`           | Whether to delete files in the bucket not found in the source               | false    | `true`  |
| `extract-artifact` | Whether to extract the ZIP file and upload its contents                     | false    | `true`  |
| `tags`             | Comma-separated list of tags to apply to the bucket (e.g. `env=qa,ver=1.0`) | false    | ''      |

---
<!-- trunk-ignore(markdownlint/MD033) -->
<a id="outputs"></a>
## 📤 Outputs

| Name             | Description                                   |
| ---------------- | --------------------------------------------- |
| `bucket_arn`     | The ARN of the deployed S3 bucket             |
| `integrity_hash` | The MD5 integrity hash of the bucket contents |

---
<!-- trunk-ignore(markdownlint/MD033) -->
<a id="usage"></a>
## 📦 Usage

Example 1 - Extract and deploy artifact contents.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy extracted contents to AWS S3
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: site
          bucket: my-docs
          bucket_region: us-west-2
          extract-artifact: true
```

Example 2 - Upload artifact ZIP file as-is.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Upload ZIP file to S3
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: bundle
          bucket: my-backups
          bucket_region: us-west-2
          extract-artifact: false
```

Example 3 - Deploy with bucket tagging.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy extracted site with tags
        uses: devopspolis/deploy-artifact-to-aws-s3@main
        with:
          artifact-name: site
          bucket: my-bucket
          bucket_region: us-east-1
          extract-artifact: true
          tags: version=1.2.3,environment=production
```
---
<!-- trunk-ignore(markdownlint/MD033) -->
<a id="requirements"></a>
## 🚦Requirements

1. The calling workflow must have the permissions shown below.
1. The calling workflow must provide access and permission to upload to the AWS S3 bucket. Best practice is to set up OIDC authentication between the GitHub repository and AWS account, and then assume a role with the necessary permissions to access and putObject to the bucket.

   In the example below the `AWS_ACCOUNT_ID` and `AWS_REGION` are retrieved from the GitHub repository environment variables, enabling the workflow to target environment specific AWS accounts.

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
          role-to-assume: arn:aws:iam::${{ vars.AWS_ACCOUNT_ID }}:role/deploy-artifact-to-aws-s3-role
          aws-region: ${{ vars.AWS_REGION }}
```
