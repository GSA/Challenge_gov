defmodule ChallengeGov.Scheduler do
  @moduledoc """
  Schedules quantum recurring background tasks for the application
  """
  use Quantum, otp_app: :challenge_gov
end
