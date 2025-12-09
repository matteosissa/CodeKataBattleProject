# GitHub OAuth Configuration

## Create Your GitHub OAuth App

1. **Go to GitHub Developer Settings**:
   - Visit: https://github.com/settings/developers
   - Click "OAuth Apps" → "New OAuth App"

2. **Application Details**:
   ```
   Application name: CodeKataBattle
   Homepage URL: http://localhost:8087
   Authorization callback URL: http://localhost:8087/login/oauth2/code/github
   Application description: Code Kata Battle - Competitive programming platform
   ```

3. **After creation**:
   - Copy the **Client ID**
   - Click "Generate a new client secret" and copy the **Client Secret**

## Configuration Options

### Option 1: Using Environment Variables (Recommended for Production)

Set environment variables before running:
```bash
export GITHUB_CLIENT_ID="your-client-id"
export GITHUB_CLIENT_SECRET="your-client-secret"
./delivery-ckb/bin/runCKB.sh
```

### Option 2: Update application.yml Directly (Easier for Development)

Edit `codekatabattle-source/gateway_microservice/src/main/resources/application.yml`:

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          github:
            clientId: your-actual-client-id
            clientSecret: your-actual-client-secret
```

Then rebuild:
```bash
./build-delivery.sh
```

### Option 3: Create a Local Configuration Override

Create `codekatabattle-source/gateway_microservice/src/main/resources/application-local.yml`:

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          github:
            clientId: your-actual-client-id
            clientSecret: your-actual-client-secret
```

Run with profile:
```bash
java -jar gateway_microservice.jar --spring.profiles.active=local
```

## ⚠️ Security Notes

- **Never commit** Client ID and Secret to Git
- Use environment variables for production deployments
- Regenerate secrets if accidentally exposed
- Add `application-local.yml` to `.gitignore`

## Testing

After configuration, test the GitHub login:
1. Start the application
2. Go to http://localhost:8087
3. Click "Login with GitHub"
4. You should see your application name "CodeKataBattle"
5. Authorize the application
