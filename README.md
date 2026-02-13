# Agent Skills

A collection of [pi coding agent](https://github.com/nicholasgasior/pi-coding-agent) skills for automating iOS/macOS development, App Store submissions, Instagram content creation, web design, and more.

## Skills

| Skill | Description |
|-------|-------------|
| [app-icon-generator](./app-icon-generator) | Generate AI-powered app icons using Replicate SDXL for iOS and web |
| [app-landing-page](./app-landing-page) | Generate minimal, aesthetic app landing pages inspired by Teenage Engineering |
| [appstore-screenshots](./appstore-screenshots) | Generate App Store marketing screenshots with device mockups and headlines |
| [appstore-submit](./appstore-submit) | End-to-end App Store submission pipeline via Fastlane |
| [frontend-design](./frontend-design) | Create distinctive, production-grade frontend interfaces |
| [ig-carousel](./ig-carousel) | Generate designed Instagram carousel slides from portfolio sites |
| [ig-content](./ig-content) | Generate Instagram-ready promotional content from any project |
| [ios-device-build](./ios-device-build) | Build, install, and launch iOS/macOS apps on devices |
| [ios-simulator-screenshots](./ios-simulator-screenshots) | Capture screenshots from every screen of an iOS app via Simulator |
| [next-steps](./next-steps) | Generate handoff prompts for continuing work in fresh sessions |
| [pdf](./pdf) | Read, merge, split, watermark, OCR, and manipulate PDF files |
| [portfolio-upload](./portfolio-upload) | Deploy creator portfolios to ugc.community |
| [portfolio-upload-config](./portfolio-upload-config) | Generate upload config files for ugc.community portfolios |
| [ugc-contact-form](./ugc-contact-form) | Integrate working contact forms into ugc.community portfolio sites |
| [ugc-screenshots](./ugc-screenshots) | Take Instagram-ready mobile screenshots of any live website |

## Installation

These skills are designed to live in `~/.pi/agent/skills/` and are automatically discovered by the pi coding agent.

```bash
git clone https://github.com/CodyBontecou/agent-skills.git ~/.pi/agent/skills
```

Some skills have Node.js dependencies — run `npm install` inside their `scripts/` directory before first use. Check each skill's README for setup instructions.

## License

See individual skill directories for licensing details.
