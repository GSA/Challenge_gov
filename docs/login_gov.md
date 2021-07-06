# Challenge.Gov Login.Gov Setup

## Login.gov Configuration

1. Go to the Login.gov dashboard:

```
# For Sandbox acccess in dev/test/staging
https://dashboard.int.identitysandbox.gov/
```

1. Login, Access is granted by the login[dot]gov team.

1. Under Apps section (nav top right), click “Create a new test app”

1. Register the app environment

```
Friendly name - "Challenge Portal <environment>"
Description - <blank>
Agency - GSA
Team - Challenge.gov
Identity protocol - openid_connect
Identity verification level (IAL) - IAL1
Issuer - `urn:gov:gsa:openidconnect.profiles:sp:sso:gsa:challenge_gov_portal_<environment>`
Logo - Upload the Challenge.gov Logo
Public certificate - see additional steps below
Return to App URL - <blank>
Failure to Proof URL - <blank>
Push Notification URL - <blank>
Redirect URIs - use the following replacing the app name
`https://your-app-name.app.cloud.gov/auth/result`
Attribute bundle - email, first_name, last_name
```

## Certificate Management

```
# create new keys by running the line below in terminal.
$ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

Paste the cert.pem into the field including the
`-----BEGIN CERTIFICATE-----`
`-----END CERTIFICATE-----`

Then re-encrypt the key for the elixir app, run the following with the correct key names:
`openssl rsa -aes128 -in key.pem -out 128_key.pem`

### For Local Development

The two files (cert and private key) must exist in the root of the app codebase.
In this case the private key should not have a password.

```
private_key_path: "local_key.pem"
public_key_path: "local_cert.pem"
```

### For Deployment Via CircleCI

To create the key and certificate ready for usage in the CircleCI ENV Vars, use the python script in the root of the project.
CircleCI will then create these files just in time of deployment so they are not part of the codebase.
The password used to encrypt the private key will need to be set in the Cloud.gov env for the app, per the [configuration variables](./configuration_variables.md) documentation.

`cat env_cert.pem | python escape-eol.py`

`cat env_key.pem | python escape-eol.py`
