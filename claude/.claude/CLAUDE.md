# Global Claude Instructions

- Never add "Co-Authored-By" lines to git commits.
- Never include Claude attribution or "Generated with Claude Code" in PR descriptions or any other output.

## Terraform / Terragrunt (gl-sre-terraform and similar repos)

- Use `aws-terragrunt` instead of the bare `terragrunt` binary for every terragrunt command (`init`, `plan`, `apply`, `state`, `import`, etc.) in repos backed by the `gl-terragrunt-state` S3 backend. It's a bashrc function on this machine:
  ```
  aws-terragrunt () {
      export AWS_PROFILE=gl-exploration
      SOURCE_PROFILE=$(aws configure get source_profile --profile gl-exploration)
      ROLE_ARN=$(aws configure get role_arn --profile gl-exploration)
      CREDS=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "terragrunt-session" --profile "$SOURCE_PROFILE" --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)
      export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | cut -f1)
      export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | cut -f2)
      export AWS_SESSION_TOKEN=$(echo "$CREDS" | cut -f3)
      unset AWS_PROFILE
      terragrunt "$@"
  }
  ```
- Why: the backend's `remote_state` config requires assuming `arn:aws:iam::059793240584:role/role-gdplabs-shared-atlantis-terraform-module`. The default AWS identity/profile cannot assume this role (`AccessDenied` on `sts:AssumeRole`), so plain `terraform`/`terragrunt init` fails. `aws-terragrunt` assumes the correct role first via the `gl-exploration` profile's source profile, then runs `terragrunt` with those temporary credentials.
- Usage: `aws-terragrunt init`, `aws-terragrunt plan`, `aws-terragrunt state list`, `aws-terragrunt import <addr> <id>`, etc. — same arguments as `terragrunt`, just prefixed.
