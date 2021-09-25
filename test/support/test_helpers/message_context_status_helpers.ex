defmodule ChallengeGov.TestHelpers.MessageContextStatusHelpers do
  @moduledoc """
  Helper factory functions for message context statuses
  """

  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.Repo

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  @super_admin_params %{
    email: "super_admin@example.com",
    role: "super_admin"
  }

  @admin_params %{
    email: "admin@example.com",
    role: "admin"
  }

  @challenge_manager_params %{
    email: "challenge_manager@example.com",
    role: "challenge_manager"
  }

  @challenge_manager_2_params %{
    email: "challenge_manager_2@example.com",
    role: "challenge_manager"
  }

  @solver_params %{
    email: "solver_1@example.com",
    role: "solver"
  }

  def create_message_context_status() do
    user_super_admin = AccountHelpers.create_user(@super_admin_params)
    user_admin = AccountHelpers.create_user(@admin_params)
    user_challenge_manager = AccountHelpers.create_user(@challenge_manager_params)
    user_challenge_manager_2 = AccountHelpers.create_user(@challenge_manager_2_params)
    user_solver = AccountHelpers.create_user(@solver_params)

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
        user_id: user_challenge_manager.id
      })

    submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

    %ChallengeManager{}
    |> ChallengeManager.changeset(%{
      "challenge_id" => challenge.id,
      "user_id" => user_challenge_manager_2.id
    })
    |> Repo.insert()

    {:ok, message_context} =
      MessageContexts.create(%{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      })

    message_context = Repo.preload(message_context, [:statuses])

    {:ok, challenge_manager_message_context_status} =
      MessageContextStatuses.get(user_challenge_manager, message_context)

    {:ok, challenge_manager_2_message_context_status} =
      MessageContextStatuses.get(user_challenge_manager_2, message_context)

    {:ok, solver_message_context_status} =
      MessageContextStatuses.get(user_solver, message_context)

    message_context = Repo.preload(message_context, [:statuses], force: true)

    %{
      challenge: challenge,
      submission: submission,
      message_context: message_context,
      challenge_manager_message_context_status: challenge_manager_message_context_status,
      challenge_manager_2_message_context_status: challenge_manager_2_message_context_status,
      solver_message_context_status: solver_message_context_status,
      user_super_admin: user_super_admin,
      user_admin: user_admin,
      user_challenge_manager: user_challenge_manager,
      user_challenge_manager_2: user_challenge_manager_2,
      user_solver: user_solver
    }
  end
end
