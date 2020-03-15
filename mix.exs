defmodule ChallengeGov.MixProject do
  use Mix.Project

  def project do
    [
      app: :challenge_gov,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ChallengeGov.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, git: "https://github.com/thoughtbot/bamboo.git"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.3"},
      {:ecto_sql, "~> 3.0"},
      {:elixir_uuid, "~> 1.2"},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.0"},
      {:joken, "~> 2.0"},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:porcelain, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:stein, "~> 0.5"},
      {:stein_storage, "~> 0.1"},
      {:timex, "~> 3.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.deploy": ["ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.migrate.reset": ["ecto.drop", "ecto.create", "ecto.migrate"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      validate: [
        "deps.get",
        "ecto.create --quiet",
        "ecto.migrate",
        "cmd mix compile --force --warnings-as-errors",
        "format",
        "format --check-formatted",
        "credo",
        "cmd mix test"
        # "cmd cd assets && yarn install",
        # "cmd cd assets/client && yarn jest --watchAll=false"
      ]
    ]
  end
end
