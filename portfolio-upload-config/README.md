# Portfolio Upload Config

Generate a portfolio-upload config file for ugc.community from any working directory. Use before `portfolio-upload` to manage upload flags in-file.

## Usage

```bash
# Basic config by subdomain
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain>

# Include explicit files array
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain> --include-files

# Hidden config filename
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:config:init --dir <portfolioDir> --subdomain <subdomain> --output .portfolio-upload.json
```

After generating the config, deploy with:

```bash
cd /Users/codybontecou/dev/ugc-community && pnpm portfolio:upload <portfolioDir>
```

See [SKILL.md](./SKILL.md) for full details.
