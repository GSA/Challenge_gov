defmodule ChallengeGov.Security do
  @moduledoc """
  Application env parsing for security related data
  """

  alias ChallengeGov.SecurityLogs

  def challenge_manager_assumed_tlds do
    var = Application.get_env(:challenge_gov, :challenge_manager_assumed_tlds)

    case parse_list_env(var) do
      nil ->
        [".mil"]

      val ->
        val
    end
  end

  def default_challenge_manager?(email) do
    escaped_gov_tld = Regex.escape(".gov")
    matching_gov_string = ".*#{escaped_gov_tld}$"
    gov_regex = Regex.compile!(matching_gov_string)
    Regex.match?(gov_regex, email) or assume_challenge_manager?(email)
  end

  def assume_challenge_manager?(email) do
    tlds = challenge_manager_assumed_tlds()

    regexs =
      Enum.map(tlds, fn tld ->
        escaped_tld = Regex.escape(tld)
        matching_string = ".*#{escaped_tld}$"
        Regex.compile!(matching_string)
      end)

    Enum.any?(regexs, fn regex ->
      Regex.match?(regex, email)
    end)
  end

  def log_retention_days do
    var = Application.get_env(:challenge_gov, :log_retention_in_days)

    case parse_integer_env(var) do
      nil ->
        180

      val ->
        val
    end
  end

  def deactivate_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_in_days)

    case parse_integer_env(var) do
      nil ->
        90

      val ->
        val
    end
  end

  def decertify_days do
    var = Application.get_env(:challenge_gov, :account_decertify_in_days)

    case parse_integer_env(var) do
      nil ->
        365

      val ->
        val
    end
  end

  def timeout_interval do
    var = Application.get_env(:challenge_gov, :session_timeout_in_minutes)

    case parse_integer_env(var) do
      nil ->
        15

      val ->
        val
    end
  end

  def deactivate_warning_one_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_warning_one_in_days)

    case parse_integer_env(var) do
      nil ->
        10

      val ->
        val
    end
  end

  def deactivate_warning_two_days do
    var = Application.get_env(:challenge_gov, :account_deactivation_warning_two_in_days)

    case parse_integer_env(var) do
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

      false ->
        to_string(:inet_parse.ntoa(remote_ip))
    end
  end

  def track_role_change_in_security_log(_remote_ip, _current_user, _user, new_role, new_role) do
    # NO-OP, the roles are the same
  end

  def track_role_change_in_security_log(_remote_ip, _current_user, _user, nil, _previous_role) do
    # NO-OP, role is not a param being updated
  end

  def track_role_change_in_security_log(remote_ip, current_user, user, new_role, previous_role) do
    SecurityLogs.track(%{
      originator_id: current_user.id,
      originator_role: current_user.role,
      originator_identifier: current_user.email,
      originator_remote_ip: remote_ip,
      target_id: user.id,
      target_type: new_role,
      target_identifier: user.email,
      action: "role_change",
      details: %{previous_role: previous_role, new_role: new_role}
    })
  end

  def track_status_update_in_security_log(
        _remote_ip,
        _current_user,
        _user,
        new_status,
        new_status
      ) do
    # NO-OP, the statuses are the same
  end

  def track_status_update_in_security_log(_remote_ip, _current_user, _user, nil, _previous_status) do
    # NO-_OP, status is not a param being updated
  end

  def track_status_update_in_security_log(
        remote_ip,
        current_user,
        user,
        new_status,
        previous_status
      ) do
    SecurityLogs.track(%{
      originator_id: current_user.id,
      originator_role: current_user.role,
      originator_identifier: current_user.email,
      originator_remote_ip: remote_ip,
      target_id: user.id,
      target_type: user.role,
      target_identifier: user.email,
      action: "status_change",
      details: %{previous_status: previous_status, new_status: new_status}
    })
  end

  defp parse_integer_env(nil), do: nil
  defp parse_integer_env(""), do: nil
  defp parse_integer_env(var) when is_integer(var), do: var

  defp parse_integer_env(var) do
    {val, ""} = Integer.parse(var)
    val
  end

  defp parse_list_env(nil), do: nil
  defp parse_list_env(""), do: nil
  defp parse_list_env(var) when is_list(var), do: var

  defp parse_list_env(var) do
    var
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end
end
