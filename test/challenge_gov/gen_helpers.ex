defmodule ChallengeGov.HelpersTest do
  use ExUnit.Case

  @moduledoc """
  Helper factory functions for accounts
  """
  describe "get_eval_url" do
    test "returns the full URL with the given path" do
      base_url = Application.get_env(:challenge_gov, :public_root_ruby_url)
      path = "test/path"

      assert base_url != nil

      assert String.length(base_url) > 0

      # Call your function with a sample path
      result = ChallengeGov.Helpers.get_eval_url(path)

      # Assert that the result is the full URL
      assert result == "#{base_url}/#{path}"
    end
  end
end
