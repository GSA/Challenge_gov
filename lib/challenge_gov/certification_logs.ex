defmodule ChallengeGov.CertificationLogs do
  @moduledoc """
  Context for adding events to certification log
  """

  # import Ecto.Query
  require Logger
  alias ChallenegGov.CertificationLogs.CertificationLog
  alias ChallengeGov.Repo
  alias ChallengeGov.Security

  def track(params) do
    %CertificationLog{}
    |> CertificationLog.changeset(params)
    |> Repo.insert()
  end

  # def check_user_certifications() do
  #   Repo.all(CertificationLog)
  # end

  def calulate_expiry() do
    decertification_interval = Security.decertify_days
    expiry = Timex.shift(DateTime.utc_now(), days: decertification_interval)
    DateTime.truncate(expiry, :second)
  end

end
