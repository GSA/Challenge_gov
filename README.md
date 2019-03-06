# IdeaPortal

[![Build Status](https://travis-ci.org/BaltimoreCity/IdeaPortal.svg?branch=master)](https://travis-ci.org/BaltimoreCity/IdeaPortal)

Welcome to the IdeaPortal for [HackBaltimore.io](https://hackbaltimore.io/)

## Requirements

- [PostgreSQL 10](https://www.postgresql.org/) - database
- [Elixir 1.8](https://elixir-lang.org) - server language
- [Erlang 21.2](https://www.erlang.org/) - server language
- [node.js 11.13](https://nodejs.org/en/) - front end language

## Install & Setup

### Requirements

Install PostgreSQL according to your OS of choice, for MacOS [Postgres.app](https://postgresapp.com/) is recommended.

To install Elixir, Erlang, and NodeJS it is recommended to use the [asdf version manager](https://asdf-vm.com/#/). Install instructions are copied here for MacOS, for other OSs see [asdf docs](https://asdf-vm.com/#/core-manage-asdf-vm). This also assumes you have [HomeBrew](https://brew.sh/) installed.

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.0
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bash_profile
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bash_profile

brew install \
  coreutils automake autoconf openssl \
  libyaml readline libxslt libtool unixodbc
```

Once asdf is set up, install each language. NodeJS may require setting up keys, and should display help to guide you.

```bash
asdf plugin-add erlang
asdf install erlang 21.2.5

asdf plugin-add elixir
asdf install elixir 1.8.0

asdf plugin-add nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
asdf install nodejs 11.13.0
```

### IdeaPortal Setup

Start with cloning the application. Once cloned, in your terminal run the following commands inside the cloned folder.

```bash
mix local.hex --force
mix local.rebar --force
mix deps.get
mix compile
```

This sets up your basic elixir environment. Next setup the database. The following commands will create and migrate locally.

```bash
mix ecto.create
mix ecto.migrate
```

If required, you can create the file `config/dev.local.exs` and include local PostgreSQL connection information. It will look like (replacing with your local configuration):

```elixir
use Mix.Config

config :idea_portal, IdeaPortal.Repo,
  username: "postgres",
  password: "postgres",
  database: "idea_portal_dev",
  hostname: "localhost",
  pool_size: 10
```

Once the database is setup, you can run the server.

```bash
mix phx.server
```

## Testing

The IdeaPortal runs each pull request (and every commit on the `master` branch) through CI. Make sure to add tests as you extend the application. We also run [Credo](https://github.com/rrrene/credo) and the built in formatter in CI to ensure code quality. 

## Learn more about Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Source: https://github.com/phoenixframework/phoenix
