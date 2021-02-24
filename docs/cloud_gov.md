# Challenge.Gov Portal cloud.gov Guide

The cloud.gov account should be set up by the PMO.

Learn more generally about [cloud.gov](https://cloud.gov/), and specifically understand their [deployment guide](https://cloud.gov/docs/deployment/deployment/) before proceeding.

## Setup

1. The organization is the top level of the cloud.gov structure.
1. Within the organization, spaces are created. The organization admin should set these up. One space per environment needed (dev, staging, production)
1. Within each space, only 1 application is needed. Create them as an empty shell of an application, no template. See below for details.

## Application configuration

1. Name the application based on the environment, for example: challenge-portal-dev
1. Bind the default route using the cloud.gov domain
1. Bind a PostgreSQL database of the right size for the environment
1. Bind a S3 bucket for file storage
1. Setup the [Variables](./configuration_variables.md)
1. Create a service account for deployment
    $ cf create-service cloud-gov-service-account space-deployer challenge-gov-service-account
    $ cf create-service-key challenge-gov-service-account challenge-gov-service-key
    $ cf service-key challenge-gov-service-account challenge-gov-service-key
1. Put the service account and key as the CF username and password for the CirlceCI project configuration
  1. Set `CF_PASSWORD_DEV` and `CF_USERNAME_DEV` for dev
  1. Set `CF_PASSWORD_STAGING` and `CF_USERNAME_STAGING` for staging
1. [CircleCI](../.cirlceci/config.yml) will deploy the main branch to dev and the staging branch after approval to staging

## Running

The app will run database migrations and seeds when booting. Background tasks are processed with Quantum and do not require any additional running processes

## SSH

Disable SSH for any sensitive environment when not in use. This can be done through the cloud.gov web interface.

To access the running node, run, for example:
```
cf ssh challenge-portal-dev
```

To run IEx commands or others, you'll need elixir and erlang on the path, just run:
`export PATH=/home/vcap/app/.platform_tools/elixir/bin:/home/vcap/app/.platform_tools/erlang/bin:/bin:/usr/bin` when connected via SSH

You can then work from the `app` directory and should be able to perform the mix and iex tasks you need to perform.

## PSQL

You can SSH tunnel through the running container to the PostgreSQL RDS instance so that you can use your local psql and related tools to work with the running database.

You'll need the RDS Host, Database, Username, and Password which you can get from the ENV of the running app in Cloud.gov or via the Cloud.gov administration panel for the application.

```
cf ssh challenge-portal-dev -L 5433:RDS_HOST:5432
```

This forwards on port 5433 so that you can still run postgres locally on 5432 without conflict.

Now in a separate terminal window, you can run, with the right username and database name filled in, using localhost on the 5433 port to leverage the tunnel via SSH.

```
psql -h localhost -p 5433 -U RDS_USERNAME RDS_DB
```

It will prompt for the RDS user password and then you'll have a connected psql session to the database.

Be sure to close the SSH connection when you are finished.

