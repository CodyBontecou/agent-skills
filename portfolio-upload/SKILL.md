---
name: portfolio-upload
description: Upload and deploy a creator portfolio to ugc.community from any working directory using the same backend pipeline as the admin drag-and-drop UI.
---

# Global UGC Portfolio Upload

This is a **global** skill. It works from any directory by running the upload CLI in the ugc-community repo.

## Repo Path

```bash
/Users/codybontecou/dev/ugc-community
```

## Run Upload

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload <args>
```

## Common Commands

### Upload using subdomain

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --subdomain <subdomain> <file-or-dir>
```

### Upload using user id

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --user <userId> <file-or-dir>
```

### Use config inside portfolio folder

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload <portfolio-dir>
```

### Append instead of replace

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --no-replace <portfolio-dir>
```

## Notes

- This command uses the same shared pipeline as the admin UI upload route.
- Supports zip extraction, extension filtering, index.html validation, and site enabling.
- CLI flags override config values.
