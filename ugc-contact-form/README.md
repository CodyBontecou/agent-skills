# UGC Contact Form

Integrate a working contact form into a static portfolio site hosted on ugc.community. Ensures the HTML structure matches the platform's serve-time injection requirements so form submissions are routed through ugc.community's email service.

**No custom JavaScript needed** — the platform automatically injects a form handler at serve-time.

## Requirements

1. A `script.js` file loaded in the HTML
2. A form with `id="contact-form"`
3. Four inputs with exact `name` attributes: `name`, `email`, `company`, `message`
4. A submit button with `type="submit"`

## Validation

```bash
bash scripts/validate.sh <portfolio-directory>
```

## Minimal Example

```html
<form id="contact-form">
  <input type="text" name="name" placeholder="Your Name" required />
  <input type="email" name="email" placeholder="Email Address" required />
  <input type="text" name="company" placeholder="Brand / Company" required />
  <textarea name="message" placeholder="Tell me about your project..." rows="5" required></textarea>
  <button type="submit">Send Message</button>
</form>
```

The platform handler automatically prevents default submission, shows loading states, POSTs to the ugc.community API, and resets the form on success.

See [SKILL.md](./SKILL.md) for the full integration workflow, common mistakes, and complete HTML example.
