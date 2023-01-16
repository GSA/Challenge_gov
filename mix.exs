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
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ChallengeGov.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :jason, :logger_json]
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
      {:bamboo_smtp, "~> 2.1.0"},
      {:browser, "~> 0.4.4"},
      {:cors_plug, "~> 3.0"},
      {:excoveralls, "~> 0.10", only: :test},
      {:color_stream, "~> 0.0.1"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo_contrib, "~> 0.2", only: [:dev, :test], runtime: false},
      {:credo_envvar, "~> 0.1", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 2.0", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4.3"},
      {:ecto_sql, "~> 3.4"},
      {:elixir_uuid, "~> 1.2"},
      {:ex_check, "~> 0.12", only: [:dev, :test], runtime: true},
      {:export, "~> 0.1.1"},
      {:finch, "~> 0.2"},
      {:gettext, "~> 0.11"},
      {:hackney, "~> 1.16.0"},
      {:httpoison, "~> 1.7"},
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:jason, "~> 1.0"},
      {:joken, "~> 2.0"},
      {:logger_json, "~> 4.0"},
      {:mint, "~> 1.4"},
      {:mix_audit, "~> 0.1", only: [:dev, :test], runtime: false},
      {:money, "~> 1.8.0"},
      {:nimble_csv, "~> 0.6"},
      {:oban, "~> 2.3"},
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.14.3"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_view, "~> 0.15.4", override: true},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.0"},
      {:porcelain, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:quantum, "~> 3.0-rc"},
      {:remote_ip, "~> 0.2.0"},
      {:sobelow, "~> 0.11"},
      {:stein, "~> 0.5"},
      {:stein_storage, "~> 0.1"},
      {:sweet_xml, "~> 0.6.6"},
      {:text_delta, "~> 1.1.0"},
      {:timex, "~> 3.5"},
      {:waffle, "~> 1.1.5"},
      {:waffle_ecto, "~> 0.0.11"},
      {:wallaby, "~> 0.28.0", runtime: false, only: :test},
      {:xml_builder, "~> 2.1.1", override: true}
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
      "ecto.deploy": ["ecto.migrate", "run priv/repo/deploy_seeds.exs"],
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
