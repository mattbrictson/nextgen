# Deployment

## Environment variables

These environment variables affect how the app functions when deployed in production.

- `SIDEKIQ_CONCURRENCY` - Number of threads used per Sidekiq process (default: 5)
- `RAILS_HOSTNAME` - Redirect all requests to the specified canonical hostname
- `BASIC_AUTH_USERNAME` - If this and `BASIC_AUTH_PASSWORD` are present, visitors must use these credentials to access the app
- `BASIC_AUTH_PASSWORD`
- `RAILS_DISABLE_SSL` - Disable HSTS and secure cookies
- `RAILS_ENV` **REQUIRED** - "production" or "staging"
- `RAILS_MAX_THREADS` - Number of threads per Puma process (default: 3)
- `SECRET_KEY_BASE` **REQUIRED** - Unique, secret key used to encrypt and sign cookies and other sensitive data
- `WEB_CONCURRENCY` - Number of Puma processes (default: 1)
