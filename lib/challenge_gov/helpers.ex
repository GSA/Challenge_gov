defmodule ChallengeGov.Helpers do
  @moduledoc """
  Common module for general use helpers
  """

  def get_eval_url(path) do
    Application.get_env(:challenge_gov, :public_root_ruby_url) <> "/" <> path
  end
end
