defmodule ChallengeGov.Security do
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

  defp parse_env(nil), do: nil
  defp parse_env(""), do: nil
  defp parse_env(var) when is_integer(var), do: var

  defp parse_env(var) do
    {val, ""} = Integer.parse(var)
    val
  end
end
