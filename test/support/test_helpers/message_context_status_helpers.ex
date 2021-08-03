defmodule ChallengeGov.TestHelpers.MessageContextStatusHelpers do
  @moduledoc """
  Helper factory functions for message context statuses
  """

  alias ChallengeGov.Challenges.ChallengeOwner
  alias ChallengeGov.Repo

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  @challenge_owner_params %{
    email: "challenge_owner@example.com",
    role: "challenge_owner"
  }

  @challenge_owner_2_params %{
    email: "challenge_owner_2@example.com",
    role: "challenge_owner"
  }

  @solver_params %{
    email: "solver_1@example.com",
    role: "solver"
  }

  def create_message_context_status() do
    user_challenge_owner = AccountHelpers.create_user(@challenge_owner_params)
    user_challenge_owner_2 = AccountHelpers.create_user(@challenge_owner_2_params)
    user_solver = AccountHelpers.create_user(@solver_params)

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
        user_id: user_challenge_owner.id
      })

    submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

    %ChallengeOwner{}
    |> ChallengeOwner.changeset(%{
      "challenge_id" => challenge.id,
      "user_id" => user_challenge_owner_2.id
    })
    |> Repo.insert()

    {:ok, message_context} =
      MessageContexts.create(%{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      })

    message_context = Repo.preload(message_context, [:statuses])

    {:ok, challenge_owner_message_context_status} =
      MessageContextStatuses.get(user_challenge_owner, message_context)

    {:ok, challenge_owner_2_message_context_status} =
      MessageContextStatuses.get(user_challenge_owner_2, message_context)

    {:ok, solver_message_context_status} =
      MessageContextStatuses.get(user_solver, message_context)

    message_context = Repo.preload(message_context, [:statuses], force: true)

    %{
      challenge: challenge,
      submission: submission,
      message_context: message_context,
      challenge_owner_message_context_status: challenge_owner_message_context_status,
      challenge_owner_2_message_context_status: challenge_owner_2_message_context_status,
      solver_message_context_status: solver_message_context_status,
      user_challenge_owner: user_challenge_owner,
      user_challenge_owner_2: user_challenge_owner_2,
      user_solver: user_solver
    }
  end
end
