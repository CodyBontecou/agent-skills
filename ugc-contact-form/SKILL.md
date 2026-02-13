---
name: ugc-contact-form
description: Integrate a working contact form into a static portfolio site hosted on ugc.community. Use when building or fixing a creator portfolio's contact section. Ensures the HTML structure matches the platform's serve-time injection requirements so form submissions are routed through ugc.community's email service.
---

# UGC Community — Contact Form Integration

This skill integrates a contact form into a static portfolio site (HTML/CSS/JS) so it works with the ugc.community platform's automatic form handler injection.

**You do NOT need to write any submission JavaScript.** The platform appends a contact form handler to `script.js` at serve-time. Your job is to ensure the HTML has the correct structure.

## How It Works

When a portfolio is served from `{subdomain}.ugc.community`, the platform:

1. Injects a tracking pixel and community badge into every `.html` file
2. **Appends a contact form handler IIFE to `script.js`** that captures submissions and POSTs them to the platform API

The injected handler finds `#contact-form`, reads fields by `name` attribute, and submits to `https://ugc.community/api/portfolio/contact`.

See [references/api.md](references/api.md) for full API details.

## Requirements Checklist

The portfolio site MUST have all of the following:

### 1. A `script.js` file at the project root

The platform specifically looks for files named `script.js` (or paths ending in `/script.js`). If your JS file has a different name, rename it or create a `script.js` that the site loads.

```html
<script src="script.js"></script>
```

### 2. A form with `id="contact-form"`

```html
<form id="contact-form">
  <!-- fields go here -->
</form>
```

### 3. Four inputs with exact `name` attributes

| Purpose | Required `name` | Element |
|---------|----------------|---------|
| Sender's name | `name="name"` | `<input>` |
| Email address | `name="email"` | `<input type="email">` |
| Company/Brand | `name="company"` | `<input>` |
| Project details | `name="message"` | `<textarea>` |

### 4. A submit button with `type="submit"`

```html
<button type="submit">Send Message</button>
```

The handler uses this element to show loading states ("Sending..." → "Message Sent!" or "Error - Try Again").

## Workflow

### Step 1 — Validate the current state

Run the validation script to see what's missing:

```bash
bash scripts/validate.sh .
```

(Resolve the path to the skill's `scripts/validate.sh` — it lives alongside this SKILL.md.)

### Step 2 — Fix or add the contact form

Based on validation output, make the minimum changes needed:

**If there's no contact form at all**, add a contact section to `index.html`. Match the existing site's design language — fonts, colors, spacing, tone. A good contact form includes:

```html
<section id="contact">
  <h2>Let's Work Together</h2>
  <p>Have a project in mind? Fill out the form below.</p>
  <form id="contact-form">
    <input type="text" name="name" placeholder="Your Name" required />
    <input type="email" name="email" placeholder="Email Address" required />
    <input type="text" name="company" placeholder="Brand / Company" required />
    <textarea name="message" placeholder="Tell me about your project..." rows="5" required></textarea>
    <button type="submit">Send Message</button>
  </form>
</section>
```

**If a contact form exists but uses wrong attributes**, update the form `id` and input `name` attributes to match the requirements. Do NOT change the visual design — only fix the wiring.

**If there's no `script.js`**, create one (it can be empty or contain existing JS) and add a `<script src="script.js"></script>` tag before `</body>` in `index.html`.

### Step 3 — Style the form to match the site

If you added a new contact section, style it in `styles.css` (or whatever CSS file the site uses). The form should feel native to the site — match the typography, color palette, spacing, and overall aesthetic. Do NOT use generic form styling.

Key styling considerations:
- Input focus states that match the site's accent color
- Consistent border-radius with other site elements
- Responsive layout (stack fields on mobile)
- Adequate spacing between fields (at least 1rem gap)
- The submit button should be visually prominent

### Step 4 — Verify

Run validation again to confirm everything passes:

```bash
bash scripts/validate.sh .
```

### Step 5 — Remove any custom submit handlers

**Critical:** If `script.js` already contains a custom submit handler for the contact form (e.g., `addEventListener('submit', ...)` targeting `#contact-form`), **remove it**. The platform injects its own handler and having two will cause double submissions or conflicts.

The platform handler:
- Prevents default form submission
- Shows "Sending..." on the submit button
- POSTs to the ugc.community API with the correct subdomain
- Shows "Message Sent!" on success
- Shows "Error - Try Again" on failure
- Resets the form after success

You do NOT need to implement any of this — it's injected automatically.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Form uses `id="contactForm"` or `class="contact-form"` | Must be `id="contact-form"` (kebab-case) |
| Input uses `name="fullName"` or `name="sender-name"` | Must be exactly `name="name"` |
| Input uses `name="brand"` or `name="organization"` | Must be exactly `name="company"` |
| Input uses `name="details"` or `name="project"` | Must be exactly `name="message"` |
| JS file is named `main.js` or `app.js` | Must be `script.js` (or rename and update HTML) |
| Custom fetch/submit handler in script.js | Remove it — the platform injects one automatically |
| Form uses `action="/submit"` or `method="POST"` | Remove these — the JS handler prevents default submission |

## Minimal Complete Example

**index.html:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Creator Portfolio</title>
  <link rel="stylesheet" href="styles.css" />
</head>
<body>
  <!-- ... rest of portfolio ... -->

  <section id="contact">
    <h2>Get in Touch</h2>
    <form id="contact-form">
      <input type="text" name="name" placeholder="Your Name" required />
      <input type="email" name="email" placeholder="Email Address" required />
      <input type="text" name="company" placeholder="Brand / Company" required />
      <textarea name="message" placeholder="Tell me about your project..." rows="5" required></textarea>
      <button type="submit">Send Message</button>
    </form>
  </section>

  <script src="script.js"></script>
</body>
</html>
```

**script.js:**
```js
// Site interactions go here.
// Do NOT add a contact form submit handler —
// the ugc.community platform injects one automatically.
```

That's it. The platform handles the rest at serve-time.
