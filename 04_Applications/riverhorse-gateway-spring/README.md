/* Path: 04_Applications/riverhorse-gateway-spring/README.md */
# Riverhorse Gateway BFF (Spring Boot 4.0.1)

## Running with Real Google OAuth (Production Handshake)

This application is configured to use a production OAuth 2.0 Client ID. To maintain security doctrine, credentials are never stored in the repository.

### Prerequisites
- Google Cloud Console Project with OAuth 2.0 Web Application credentials.
- Authorized Redirect URI: http://localhost:8080/login/oauth2/code/google

### Environment Variable Setup
Before running, you must set your credentials in your local terminal session.

**PowerShell:**
$env:GOOGLE_OAUTH_CLIENT_ID = "your-client-id"
$env:GOOGLE_OAUTH_CLIENT_SECRET = "your-client-secret"

**Bash:**
export GOOGLE_OAUTH_CLIENT_ID="your-client-id"
export GOOGLE_OAUTH_CLIENT_SECRET="your-client-secret"

### Run Sequence
1. Clean and build the project:
   mvn clean compile
2. Start the application:
   mvn spring-boot:run

### Verify Steps
1. Navigate to http://localhost:8080/
2. If unauthenticated, you will be prompted to login.
3. Select 'Login with Google'.
4. Upon successful handshake, you should see a welcome message displaying your Name and Email as registered with Google.

### Troubleshooting
- **Whitelabel 404:** Ensure HomeController is present and mapped to the root (/) path.
- **Redirect URI Mismatch:** Confirm the URI in Google Cloud Console exactly matches http://localhost:8080/login/oauth2/code/google.
- **Null Credentials:** Ensure environment variables are set in the SAME terminal window used to run Maven.

### Stopping
- Use Ctrl + C in the terminal to terminate the Spring Boot process.