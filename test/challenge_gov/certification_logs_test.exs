defmodule ChallengeGov.CertificationLogsTest do
  @moduledoc false
  use Web.ConnCase
  import ExUnit.CaptureLog

  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.CertificationLogs.CertificationLog
  alias ChallengeGov.Repo
  alias ChallengeGov.TestHelpers.AccountHelpers

  describe "send email" do
    setup [:setup_user]

    @tag expires_at: DateTime.add(DateTime.utc_now(), 2_592_000)
    test "send message at 30 days", %{user: user} do
      assert capture_log(fn ->
               CertificationLogs.email_upcoming_expired_certifications()
             end) =~ "Decertify 30 day notice [user_id: #{user.id}]"
    end

    @tag expires_at: DateTime.add(DateTime.utc_now(), 1_296_000)
    test "send message at 15 days", %{user: user} do
      assert capture_log(fn ->
               CertificationLogs.email_upcoming_expired_certifications()
             end) =~ "Decertify 15 day notice [user_id: #{user.id}]"
    end

    @tag expires_at: DateTime.add(DateTime.utc_now(), 432_000)
    test "send message at 5 days", %{user: user} do
      assert capture_log(fn ->
               CertificationLogs.email_upcoming_expired_certifications()
             end) =~ "Decertify 5 day notice [user_id: #{user.id}]"
    end

    @tag expires_at: DateTime.add(DateTime.utc_now(), 86_400)
    test "send message at 1 days", %{user: user} do
      assert capture_log(fn ->
               CertificationLogs.email_upcoming_expired_certifications()
             end) =~ "Decertify 1 day notice [user_id: #{user.id}]"
    end
  end

  def setup_user(ctx) do
    user = AccountHelpers.create_user(%{role: "challenge_manager"})

    %CertificationLog{}
    |> CertificationLog.changeset(%{
      user_id: user.id,
      expires_at: ctx.expires_at
    })
    |> Repo.insert()

    [user: user]
  end
end
