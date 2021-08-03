defmodule ChallengeGov.MessageContextsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges.ChallengeOwner
  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "creating a message context" do
    test "success: challenge owner creating broadcast context around a challenge" do
      user_challenge_owner =
        AccountHelpers.create_user(%{
          email: "challenge_owner@example.com",
          role: "challenge_owner"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
          user_id: user_challenge_owner.id
        })

      _submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      _prepped_message_context = MessageContexts.new("all")

      {:ok, message_context} =
        MessageContexts.create(%{
          "context" => "challenge",
          "context_id" => challenge.id,
          "audience" => "all"
        })

      user_context_status = Enum.at(MessageContextStatuses.all_for_user(user_challenge_owner), 0)
      user_solver_context_status = Enum.at(MessageContextStatuses.all_for_user(user_solver), 0)

      assert user_context_status.message_context_id == message_context.id
      assert user_solver_context_status.message_context_id == message_context.id
    end

    # Parent contexts might not exist for submission contexts
    @tag :skip
    test "success: creating a submission context with an already existing parent challenge message context" do
      user_challenge_owner =
        AccountHelpers.create_user(%{
          email: "challenge_owner@example.com",
          role: "challenge_owner"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
          user_id: user_challenge_owner.id
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

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_owner)
      user_context_status = Enum.at(user_context_statuses, 0)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)
      user_solver_context_status = Enum.at(user_solver_context_statuses, 0)

      # Both challenge owner and solver will have a context status pointing to the initial broadcast context
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

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_owner)
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
      user_challenge_owner =
        AccountHelpers.create_user(%{
          email: "challenge_owner@example.com",
          role: "challenge_owner"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
          user_id: user_challenge_owner.id
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      # Create submission context
      {:ok, submission_message_context} =
        MessageContexts.create(%{
          "context" => "submission",
          "context_id" => submission.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_owner)
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
      user_challenge_owner =
        AccountHelpers.create_user(%{
          email: "challenge_owner@example.com",
          role: "challenge_owner"
        })

      user_solver = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
          user_id: user_challenge_owner.id
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

      # Create submission context
      {:ok, submission_message_context} =
        MessageContexts.create(%{
          "context" => "submission",
          "context_id" => submission.id,
          "audience" => "all"
        })

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_owner)
      user_context_status_context_ids = Enum.map(user_context_statuses, & &1.message_context_id)
      user_solver_context_statuses = MessageContextStatuses.all_for_user(user_solver)

      user_solver_context_status_context_ids =
        Enum.map(user_solver_context_statuses, & &1.message_context_id)

      # Both challenge owner and solver will have a context status pointing to the initial broadcast context
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

      user_context_statuses = MessageContextStatuses.all_for_user(user_challenge_owner)
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

  # TODO: work on these multi context creations
  describe "creating multiple message contexts" do
    @tag :skip
    test "success: creating multiple submission contexts with no existing parent context"

    @tag :skip
    test "success: creating multiple submission contexts with some that already exist"
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
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author == nil

      {:ok, _message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author.id == user_challenge_owner.id

      # A solver creating a message on a "challenge" context will get their own context
      # This means the last author will not change on the parent and instead be on their own context
      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, solver_isolated_context} = MessageContexts.get("solver", user_solver.id, "all")

      {:ok, last_author} = MessageContexts.get_last_author(message_context)
      assert last_author.id == user_challenge_owner.id

      {:ok, last_author_solver_context} = MessageContexts.get_last_author(solver_isolated_context)
      assert last_author_solver_context.id == user_solver.id

      {:ok, _message} =
        Messages.create(user_challenge_owner, solver_isolated_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, last_author_solver_context} = MessageContexts.get_last_author(solver_isolated_context)
      assert last_author_solver_context.id == user_challenge_owner.id
    end
  end

  describe "sync message contexts" do
    test "success: for admin" do
      MessageContextStatusHelpers.create_message_context_status()

      user_admin = AccountHelpers.create_user(%{role: "admin", email: "admin@example.com"})

      MessageContexts.sync_for_user(user_admin)

      user_admin = Repo.preload(user_admin, [:message_context_statuses])

      assert length(user_admin.message_context_statuses) == 1
    end

    test "success: for challenge_owner" do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      user_challenge_owner_new =
        AccountHelpers.create_user(%{
          role: "challenge_owner",
          email: "challenge_owner_new@example.com"
        })

      Messages.create(user_solver, message_context, %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      })

      challenge = MessageContexts.get_context_record(message_context)

      {:ok, challenge_owner} =
        %ChallengeOwner{}
        |> ChallengeOwner.changeset(%{
          "challenge_id" => challenge.id,
          "user_id" => user_challenge_owner_new.id
        })
        |> Repo.insert()

      MessageContexts.sync_for_user(user_challenge_owner_new)

      user_challenge_owner_new =
        Repo.preload(user_challenge_owner_new, [:message_context_statuses])

      assert length(user_challenge_owner_new.message_context_statuses) == 2

      Repo.delete(challenge_owner)

      MessageContexts.sync_for_user(user_challenge_owner_new)

      user_challenge_owner_new =
        Repo.preload(user_challenge_owner_new, [:message_context_statuses], force: true)

      assert Enum.empty?(user_challenge_owner_new.message_context_statuses)
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
end
