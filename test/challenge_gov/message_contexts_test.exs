defmodule ChallengeGov.MessageContextsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "creating a message context" do
    test "success: challenge manager creating broadcast context around a challenge" do
      user_challenge_manager =
        AccountHelpers.create_user(%{
          email: "challenge_manager@example.com",
          role: "challenge_manager"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
          user_id: user_challenge_manager.id
        })

      _submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      _prepped_message_context = MessageContexts.new("all")

      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      user_context_status =
        Enum.at(MessageContextStatuses.all_for_user(user_challenge_manager), 0)

      user_solver_context_status = Enum.at(MessageContextStatuses.all_for_user(user_solver), 0)

      assert user_context_status.message_context_id == message_context.id
      assert user_solver_context_status.message_context_id == message_context.id
    end

    test "success: admin creating a context with a challenge manager audience around a challenge" do
      user_admin =
        AccountHelpers.create_user(%{
          email: "admin@example.com",
          role: "admin"
        })

      user_challenge_manager =
        AccountHelpers.create_user(%{
          email: "challenge_manager@example.com",
          role: "challenge_manager"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
          user_id: user_challenge_manager.id
        })

      _submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      _prepped_message_context = MessageContexts.new("all")

      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "challenge_managers"
        })

      user_admin_context_status = Enum.at(MessageContextStatuses.all_for_user(user_admin), 0)

      user_challenge_manager_context_status =
        Enum.at(MessageContextStatuses.all_for_user(user_challenge_manager), 0)

      user_solver_context_status = Enum.at(MessageContextStatuses.all_for_user(user_solver), 0)

      assert user_admin_context_status.message_context_id == message_context.id
      assert user_challenge_manager_context_status.message_context_id == message_context.id
      refute user_solver_context_status
    end

    # Parent contexts might not exist for submission contexts
    @tag :skip
    test "success: creating a submission context with an already existing parent challenge message context" do
      user_challenge_manager =
        AccountHelpers.create_user(%{
          email: "challenge_manager@example.com",
          role: "challenge_manager"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
          user_id: user_challenge_manager.id
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      _prepped_message_context = MessageContexts.new("all")

      # Create parent challenge context
      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_manager)
      user_context_status = Enum.at(user_context_statuses, 0)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)
      user_solver_context_status = Enum.at(user_solver_context_statuses, 0)

      # Both challenge manager and solver will have a context status pointing to the initial broadcast context
      assert user_context_status.message_context_id == message_context.id
      assert length(user_context_statuses) == 1
      assert user_solver_context_status.message_context_id == message_context.id
      assert length(user_solver_context_statuses) == 1

      # Create submission context
      {:ok, submission_message_context} =
        MessageContexts.create(%{
          "parent_id" => message_context.id,
          "context" => "submission",
          "context_id" => submission.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_manager)
      user_context_status = Enum.at(user_context_statuses, 0)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)
      user_solver_context_status = Enum.at(user_solver_context_statuses, 0)

      # Make sure the solver's message context status was moved to the new isolated message context
      assert user_context_status.message_context_id == message_context.id
      assert length(user_context_statuses) == 2
      assert user_solver_context_status.message_context_id == submission_message_context.id
      assert length(user_solver_context_statuses) == 1
    end

    # Parent contexts might not exist for submission contexts
    @tag :skip
    test "success: creating a submission context without an existing parent challenge message context" do
      user_challenge_manager =
        AccountHelpers.create_user(%{
          email: "challenge_manager@example.com",
          role: "challenge_manager"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
          user_id: user_challenge_manager.id
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      # Create submission context
      {:ok, submission_message_context} =
        MessageContexts.create(%{
          "context" => "submission",
          "context_id" => submission.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_manager)
      user_context_status = Enum.at(user_context_statuses, 0)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)
      user_solver_context_status = Enum.at(user_solver_context_statuses, 0)

      refute submission_message_context.parent_id
      assert user_context_status.message_context_id == submission_message_context.id
      assert length(user_context_statuses) == 1
      assert user_solver_context_status.message_context_id == submission_message_context.id
      assert length(user_solver_context_statuses) == 1
    end

    # Parent contexts might not exist for submission contexts
    @tag :skip
    test "success: creating a challenge broadcast context and attaching related existing submission message contexts to it" do
      user_challenge_manager =
        AccountHelpers.create_user(%{
          email: "challenge_manager@example.com",
          role: "challenge_manager"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
          user_id: user_challenge_manager.id
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      # Create submission context
      {:ok, submission_message_context} =
        MessageContexts.create(%{
          "context" => "submission",
          "context_id" => submission.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_manager)
      user_context_status_context_ids = Enum.map(user_context_statuses, & &1.message_context_id)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)

      user_solver_context_status_context_ids =
        Enum.map(user_solver_context_statuses, & &1.message_context_id)

      # Both challenge manager and solver will have a context status pointing to the initial broadcast context
      assert user_context_status_context_ids == [submission_message_context.id]
      assert length(user_context_statuses) == 1
      assert user_solver_context_status_context_ids == [submission_message_context.id]
      assert length(user_solver_context_statuses) == 1

      # Create parent challenge context
      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      message_context = Repo.preload(message_context, [:contexts])
      {:ok, submission_message_context} = MessageContexts.get(submission_message_context.id)

      assert length(message_context.contexts) == 1
      assert submission_message_context.parent_id == message_context.id

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_manager)
      user_context_status_context_ids = Enum.map(user_context_statuses, & &1.message_context_id)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)

      user_solver_context_status_context_ids =
        Enum.map(user_solver_context_statuses, & &1.message_context_id)

      # Make sure the solver's message context status was moved to the new isolated message context
      assert Enum.sort(user_context_status_context_ids) ==
               Enum.sort([message_context.id, submission_message_context.id])

      assert length(user_context_statuses) == 2
      assert user_solver_context_status_context_ids == [submission_message_context.id]
      assert length(user_solver_context_statuses) == 1
    end
  end

  describe "finding or creating multiple solver message contexts" do
    test "success: with no existing parent challenge context" do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, solver_1, challenge)

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, solver_2, challenge)

      solver_ids = [submission_1.submitter_id, submission_2.submitter_id]

      message_content = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      MessageContexts.multi_submission_message(
        challenge_manager,
        challenge.id,
        solver_ids,
        message_content
      )

      {:ok, challenge_message_context} = MessageContexts.get("challenge", challenge.id, "all")
      challenge_message_context = Repo.preload(challenge_message_context, [:messages])
      assert Enum.empty?(challenge_message_context.messages)

      {:ok, solver_message_context_1} =
        MessageContexts.get("solver", solver_1.id, "all", challenge_message_context.id)

      solver_message_context_1 = Repo.preload(solver_message_context_1, [:messages])
      assert length(solver_message_context_1.messages) == 1
      assert Enum.at(solver_message_context_1.messages, 0).content == "Test"

      {:ok, solver_message_context_2} =
        MessageContexts.get("solver", solver_2.id, "all", challenge_message_context.id)

      solver_message_context_2 = Repo.preload(solver_message_context_2, [:messages])
      assert length(solver_message_context_2.messages) == 1
      assert Enum.at(solver_message_context_2.messages, 0).content == "Test"
    end

    test "success: with existing parent challenge context" do
      challenge_manager =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "co@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_manager, %{
          user_id: challenge_manager.id
        })

      solver_1 = AccountHelpers.create_user(%{role: "solver", email: "s1@example.com"})
      submission_1 = SubmissionHelpers.create_submitted_submission(%{}, solver_1, challenge)

      solver_2 = AccountHelpers.create_user(%{role: "solver", email: "s2@example.com"})
      submission_2 = SubmissionHelpers.create_submitted_submission(%{}, solver_2, challenge)

      {:ok, challenge_message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      {:ok, _solver_message_context_1} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => submission_1.submitter_id,
          "audience" => "all",
          "parent_id" => challenge_message_context.id
        })

      solver_ids = [submission_1.submitter_id, submission_2.submitter_id]

      message_content = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      MessageContexts.multi_submission_message(
        challenge_manager,
        challenge.id,
        solver_ids,
        message_content
      )

      {:ok, challenge_message_context} = MessageContexts.get("challenge", challenge.id, "all")
      challenge_message_context = Repo.preload(challenge_message_context, [:messages])
      assert Enum.empty?(challenge_message_context.messages)

      {:ok, solver_message_context_1} =
        MessageContexts.get("solver", solver_1.id, "all", challenge_message_context.id)

      solver_message_context_1 = Repo.preload(solver_message_context_1, [:messages])
      assert length(solver_message_context_1.messages) == 1
      assert Enum.at(solver_message_context_1.messages, 0).content == "Test"

      {:ok, solver_message_context_2} =
        MessageContexts.get("solver", solver_2.id, "all", challenge_message_context.id)

      solver_message_context_2 = Repo.preload(solver_message_context_2, [:messages])
      assert length(solver_message_context_2.messages) == 1
      assert Enum.at(solver_message_context_2.messages, 0).content == "Test"
    end
  end

  describe "finding existing message context" do
    test "success: with existing context, context_id, and audience combination" do
      user = AccountHelpers.create_user()
      user_solver = AccountHelpers.create_user(%{email: "solver@example.com"})

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      _prepped_message_context = MessageContexts.new("all")

      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      {:ok, message_context_2} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      assert message_context.id == message_context_2.id
    end
  end

  describe "retrieving the last author" do
    test "success" do
      %{
        message_context: message_context,
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author == nil

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author.id == user_challenge_manager.id

      # A solver creating a message on a "challenge" context will get their own context
      # This means the last author will not change on the parent and instead be on their own context
      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, solver_isolated_context} = MessageContexts.get("solver", user_solver.id, "all")

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author.id == user_challenge_manager.id

      {:ok, last_author_solver_context} = MessageContexts.get_last_author(solver_isolated_context)
      assert last_author_solver_context.id == user_solver.id

      {:ok, _message} =
        Messages.create(user_challenge_manager, solver_isolated_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, last_author_solver_context} = MessageContexts.get_last_author(solver_isolated_context)
      assert last_author_solver_context.id == user_challenge_manager.id
    end
  end

  describe "sync message contexts" do
    test "success: for admin" do
      MessageContextStatusHelpers.create_message_context_status()

      user_admin = AccountHelpers.create_user(%{role: "admin", email: "new_admin@example.com"})

      MessageContexts.sync_for_user(user_admin)

      user_admin = Repo.preload(user_admin, [:message_context_statuses])

      assert length(user_admin.message_context_statuses) == 1
    end

    test "success: for challenge_manager" do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      user_challenge_manager_new =
        AccountHelpers.create_user(%{
          role: "challenge_manager",
          email: "challenge_manager_new@example.com"
        })

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      challenge = MessageContexts.get_context_record(message_context)

      {:ok, challenge_manager} =
        %ChallengeManager{}
        |> ChallengeManager.changeset(%{
          "challenge_id" => challenge.id,
          "user_id" => user_challenge_manager_new.id
        })
        |> Repo.insert()

      MessageContexts.sync_for_user(user_challenge_manager_new)

      user_challenge_manager_new =
        Repo.preload(user_challenge_manager_new, [:message_context_statuses])

      assert length(user_challenge_manager_new.message_context_statuses) == 2

      Repo.delete(challenge_manager)

      MessageContexts.sync_for_user(user_challenge_manager_new)

      user_challenge_manager_new =
        Repo.preload(user_challenge_manager_new, [:message_context_statuses], force: true)

      assert Enum.empty?(user_challenge_manager_new.message_context_statuses)
    end

    test "success: for solver" do
      %{
        challenge: challenge,
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      MessageContexts.create(%{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "challenge_managers"
      })

      MessageContexts.sync_for_user(user_solver)

      user_solver = Repo.preload(user_solver, [:message_context_statuses])
      assert length(user_solver.message_context_statuses) == 1

      user_solver_new =
        AccountHelpers.create_user(%{role: "solver", email: "solver_new@example.com"})

      _submission_new =
        SubmissionHelpers.create_submitted_submission(%{}, user_solver_new, challenge)

      MessageContexts.sync_for_user(user_solver_new)

      user_solver_new = Repo.preload(user_solver_new, [:message_context_statuses])
      assert length(user_solver_new.message_context_statuses) == 1
    end
  end

  describe "permission checks: create" do
    test "success: super_admin" do
      user = AccountHelpers.create_user(%{role: "super_admin"})
      assert MessageContexts.user_can_create?(user)
    end

    test "success: admin" do
      user = AccountHelpers.create_user(%{role: "admin"})
      assert MessageContexts.user_can_create?(user)
    end

    test "success: challenge_manager" do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      assert MessageContexts.user_can_create?(user)
    end

    test "success: solver" do
      user = AccountHelpers.create_user(%{role: "solver"})
      refute MessageContexts.user_can_create?(user)
    end
  end

  describe "permission checks: view" do
    test "success: super_admin" do
      %{
        user_super_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_can_view?(user, context)
    end

    test "success: admin" do
      %{
        user_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_can_view?(user, context)
    end

    test "success: challenge_manager" do
      %{
        user_challenge_manager: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      new_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      assert MessageContexts.user_can_view?(user, context)
      refute MessageContexts.user_can_view?(new_user, context)
    end

    test "success: solver" do
      %{
        user_solver: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      new_user = AccountHelpers.create_user(%{role: "solver", email: "new_user@example.com"})

      assert MessageContexts.user_can_view?(user, context)
      refute MessageContexts.user_can_view?(new_user, context)
    end
  end

  describe "permission checks: message" do
    test "success: super_admin" do
      %{
        user_super_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_can_message?(user, context)
    end

    test "success: admin" do
      %{
        user_admin: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_can_message?(user, context)
    end

    test "success: challenge_manager" do
      %{
        user_challenge_manager: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      new_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "new_user@example.com"})

      assert MessageContexts.user_can_message?(user, context)
      refute MessageContexts.user_can_message?(new_user, context)
    end

    test "success: solver" do
      %{
        user_solver: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_can_message?(user, context)
    end

    test "failure: unrelated solver" do
      %{
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      user = AccountHelpers.create_user(%{role: "solver", email: "new_user@example.com"})

      refute MessageContexts.user_can_message?(user, context)
    end
  end

  describe "permission checks: user related" do
    test "success: challenge manager related to challenge context" do
      %{
        user_challenge_manager: user,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContexts.user_related_to_context?(user, context)
    end

    test "success: challenge manager related to solver context" do
      %{
        user_challenge_manager: user,
        user_solver: user_solver,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, solver_context} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => user_solver.id,
          "audience" => "all",
          "parent_id" => context.id
        })

      assert MessageContexts.user_related_to_context?(user, solver_context)
    end

    test "failure: challenge manager not related to challenge context" do
      %{
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      user = AccountHelpers.create_user(%{role: "challenge_manager"})

      refute MessageContexts.user_related_to_context?(user, context)
    end

    test "failure: challenge manager not related to solver context" do
      %{
        user_solver: user_solver,
        message_context: context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, solver_context} =
        MessageContexts.create(%{
          "context" => "solver",
          "context_id" => user_solver.id,
          "audience" => "all",
          "parent_id" => context.id
        })

      user = AccountHelpers.create_user(%{role: "challenge_manager"})

      refute MessageContexts.user_related_to_context?(user, solver_context)
    end
  end
end
