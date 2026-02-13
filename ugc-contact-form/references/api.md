# ugc.community Contact Form API Reference

## Endpoint

```
POST https://ugc.community/api/portfolio/contact
```

## Request Body

```json
{
  "name": "string (required, max 100)",
  "email": "string (required, valid email)",
  "company": "string (required, max 100)",
  "message": "string (required, max 5000)",
  "creatorSubdomain": "string (required, e.g. 'daniela')"
}
```

## Responses

**200 OK:**
```json
{ "success": true, "message": "Message sent successfully" }
```

**400 Bad Request** (validation error):
```json
{ "error": "Name is required" }
```

**404 Not Found** (subdomain doesn't match a user):
```json
{ "error": "Creator not found" }
```

**500 Internal Server Error:**
```json
{ "error": "Something went wrong. Please try again." }
```

## CORS

Allowed origins:
- `https://*.ugc.community`
- `http://localhost:*` (development)

## What Happens on Submit

1. The creator receives an email notification with the inquiry details
2. The sender receives a confirmation email
3. The submission is recorded in the database

## Platform Injection Details

The ugc.community platform automatically injects a contact form handler at serve-time. This happens in the portfolio serving route:

- **HTML files**: A tracking pixel and community badge are injected before `</body>`
- **`script.js` files**: A contact form handler IIFE is appended to the end of the file

The injected handler:
1. Finds `document.getElementById('contact-form')`
2. Attaches a `submit` event listener
3. Reads values from inputs with `name="name"`, `name="email"`, `name="company"`, `name="message"`
4. POSTs to `https://ugc.community/api/portfolio/contact` with `creatorSubdomain` set to the portfolio's subdomain
5. Shows "Sending..." → "Message Sent!" (success) or "Error - Try Again" (failure) on the submit button

This means portfolio sites do NOT need any custom JavaScript for the contact form — they only need the correct HTML structure.
