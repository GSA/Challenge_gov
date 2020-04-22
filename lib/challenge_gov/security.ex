defmodule ChallengeGov.Security do
  @moduledoc """
  Application env parsing for security related data
  """

  def log_retention_days do
    var = Application.get_env(:challenge_gov, :log_retention_in_days)

    case parse_env(var) do
      nil ->
        180

      val ->
        val
    end
  end

  def deactivate_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_in_days)

    case parse_env(var) do
      nil ->
        90

      val ->
        val
    end
  end

  def decertify_days do
    var = Application.get_env(:challenge_gov, :account_decertify_in_days)

    case parse_env(var) do
      nil ->
        365

      val ->
        val
    end
  end

  def timeout_interval do
    var = Application.get_env(:challenge_gov, :session_timeout_in_minutes)

    case parse_env(var) do
      nil ->
        15

      val ->
        val
    end
  end

  def deactivate_warning_one_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_warning_one_in_days)

    case parse_env(var) do
      nil ->
        10

      val ->
        val
    end
  end

  def deactivate_warning_two_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_warning_two_in_days)

    case parse_env(var) do
      nil ->
        5

      val ->
        val
    end
  end

  def extract_remote_ip(%{remote_ip: remote_ip}) do
    case is_nil(remote_ip) do
      true ->
        nil
      false
        to_string(:inet_parse.ntoa(remote_ip))
    end
  end

  defp parse_env(nil), do: nil
  defp parse_env(""), do: nil
  defp parse_env(var) when is_integer(var), do: var

  defp parse_env(var) do
    {val, ""} = Integer.parse(var)
    val
  end
end
