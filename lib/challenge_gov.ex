defmodule ChallengeGov do
  @moduledoc """
  ChallengeGov keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Pass-through function to optionally load config from the environment

  iex> ChallengeGov.config({:system, "HOST"})
  "example.com"
  """
  def config({:system, env}), do: System.get_env(env)

  def config(config), do: config
end
