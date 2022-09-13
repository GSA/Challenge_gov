defmodule ChallengeGov.Users do
  @moduledoc false
  alias ChallengeGov.Accounts
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Repo

  def maybe_decertify_user_manually(_user, status, status), do: :noop

  def maybe_decertify_user_manually(user, "decertified", _previous_status) do
    with {:ok, user} <-
           Accounts.update(user, %{terms_of_use: nil, privacy_guidelines: nil}) do
      Accounts.revoke_challenge_managership(user)
    end
  end

  def maybe_decertify_user_manually(_user, _status, _previous_status), do: :noop

  def get_recertify_update_params(user) do
    case user.renewal_request == "certification" do
      true ->
        %{
          "terms_of_use" => nil,
          "privacy_guidelines" => nil,
          "renewal_request" => nil
        }

      false ->
        %{"terms_of_use" => nil, "privacy_guidelines" => nil}
    end
  end

  def admin_recertify_user(user, approver, approver_remote_ip) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:user, fn _repo, _changes ->
        Accounts.activate(user, approver, approver_remote_ip)
      end)
      |> Ecto.Multi.run(:renew_terms, fn _repo, _changes ->
        Accounts.update(user, get_recertify_update_params(user))
      end)
      |> Ecto.Multi.run(:certification_record, fn _repo, _changes ->
        CertificationLogs.certify_user_with_approver(user, approver, approver_remote_ip)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        send_email(user)
        {:ok, user}

      :error ->
        {:error, :not_recertified}
    end
  end

  def send_email(user = %{status: "deactivated"}),
    do: user |> Emails.account_reactivation() |> Mailer.deliver_later()

  def send_email(user = %{status: "suspended"}),
    do: user |> Emails.account_reactivation() |> Mailer.deliver_later()

  def send_email(user = %{status: "revoked"}),
    do: user |> Emails.account_reactivation() |> Mailer.deliver_later()

  def send_email(user = %{status: "pending"}),
    do: user |> Emails.account_activation() |> Mailer.deliver_later()

  def send_email(user = %{status: "decertified"}),
    do: user |> Emails.account_activation() |> Mailer.deliver_later()

  def send_email(user = %{status: "active", renewal_request: renewal_request})
      when renewal_request == "certification",
      do: user |> Emails.recertification_email() |> Mailer.deliver_later()

  def send_email(_user), do: nil
end
