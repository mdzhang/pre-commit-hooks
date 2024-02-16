# pre-commit-hooks

just some useful ones.


### Usage

Add this to your `.pre-commit-config.yaml`

```yaml
-   repo: https://github.com/mdzhang/pre-commit-hooks
    rev: v0.0.1  # Use the ref you want to point at
    hooks:
    -   id: check-all-codeowners-globs-used
```

### Hooks available

#### `check-all-codeowners-globs-used`

Lints a GitHub CODEOWNERS file so that there are no globs that don't actually refer to files. Useful for catching drift as files as reorganized, etc.
