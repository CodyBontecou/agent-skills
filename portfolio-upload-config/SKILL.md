---
name: portfolio-upload-config
description: Generate a portfolio-upload config file for ugc.community from any working directory. Use before /skill:portfolio-upload to manage flags in-file.
---

# Global Portfolio Upload Config Generator

This is a **global** skill. It works from any directory by running the config generator CLI in the ugc-community repo.

## Repo Path

```bash
/Users/codybontecou/dev/ugc-community
```

## Generate Config

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> (--user <userId> | --subdomain <subdomain>)
```

## Common Commands

### Basic config by subdomain

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain>
```

### Include explicit files array

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain> --include-files
```

### Hidden config filename

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain> --output .portfolio-upload.json
```

## Next Step

After generating config, run:

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload <portfolioDir>
```
