# Portfolio Upload

Upload and deploy a creator portfolio to ugc.community from any working directory. Uses the same backend pipeline as the admin drag-and-drop UI.

## Usage

```bash
# Upload by subdomain
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --subdomain <subdomain> <file-or-dir>

# Upload by user ID
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --user <userId> <file-or-dir>

# Use config inside portfolio folder
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload <portfolio-dir>

# Append instead of replace
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload --no-replace <portfolio-dir>
```

Supports zip extraction, extension filtering, index.html validation, and site enabling. CLI flags override config values.

See [SKILL.md](./SKILL.md) for full details.
