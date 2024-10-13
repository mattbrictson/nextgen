# Deployment

## Environment variables

These environment variables affect how the app functions when deployed in production.

- `RAILS_DISABLE_SSL` - Disable HSTS and secure cookies
- `RAILS_ENV` **REQUIRED** - "production"
- `RAILS_MAX_THREADS` - Number of threads per Puma process (default: 3)
- `SECRET_KEY_BASE` **REQUIRED** - Unique, secret key used to encrypt and sign cookies and other sensitive data
- `WEB_CONCURRENCY` - Number of Puma processes (default: 1)
