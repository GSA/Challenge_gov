# Challenge.Gov Login.Gov Setup

1. Go to the Login.gov dashboard:

```
# For Sandbox acccess in dev/test/staging
https://dashboard.int.identitysandbox.gov/
```

1. Login, Access is granted by the login[dot]gov team.

1. Under Apps section (nav top right), click “Create a new test app”

1. Register the app environment

Friendly name - "Challenge Portal <environment>"

Description - <blank>

Agency - GSA

Team - Challenge.gov

Identity protocol - openid_connect

Identity verification level (IAL) - IAL1

Issuer - `urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:challenge_gov_portal_<environment>`

Logo - Upload the Challenge.gov Logo

Public certificate - Generate a paste in the key with the following steps:

```
# create new keys by running the line below in terminal.
$ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

Paste the cert.pem into the field including the
`-----BEGIN CERTIFICATE-----`
`-----END CERTIFICATE-----`

Then re-encrypt the key for the elixir app, run the following with the correct key names:
`openssl rsa -aes128 -in key.pem -out 128_key.pem`

Return to App URL - <blank>

Failure to Proof URL - <blank>

Push Notification URL - <blank>

Redirect URIs - use the following replacing the app name
`https://your-app-name.app.cloud.gov/auth/result`

Attribute bundle - email, first_name, last_name
