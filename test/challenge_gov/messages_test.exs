defmodule ChallengeGov.MessagesTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Repo

  alias ChallengeGov.Messages
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  @challenge_owner_params %{
    email: "challenge_owner@example.com",
    role: "challenge_owner"
  }

  @solver_params %{
    email: "solver_1@example.com",
    role: "solver"
  }

  defp create_message_context_status() do
    user_challenge_owner = AccountHelpers.create_user(@challenge_owner_params)
    user_solver = AccountHelpers.create_user(@solver_params)

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user_challenge_owner, %{
        user_id: user_challenge_owner.id
      })

    {:ok, message_context} =
      MessageContexts.create(%{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      })

    message_context = Repo.preload(message_context, [:statuses])

    assert length(message_context.statuses) == 1

    _submission = SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)

    {:ok, message_context_status} = MessageContextStatuses.create(user_solver, message_context)

    message_context = Repo.preload(message_context, [:statuses], force: true)

    assert length(message_context.statuses) == 2

    %{
      user_challenge_owner: user_challenge_owner,
      user_solver: user_solver,
      message_context: message_context,
      message_context_status: message_context_status
    }
  end

  describe "creating a sent message" do
    test "success" do
      %{
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_owner_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      refute solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      assert message_context.last_message_id == message.id
    end
  end

  describe "creating a draft message" do
    test "success: new draft" do
      %{
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_owner_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
    end

    test "success: update draft" do
      %{
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_owner_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      initial_message_id = message.id

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
      assert message.id == initial_message_id

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "id" => message.id,
          "content" => "Test updated",
          "content_delta" => "Test updated",
          "status" => "draft"
        })

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test updated"
      assert message.content_delta == "Test updated"
      refute message_context.last_message_id
      assert message.id == initial_message_id
    end
  end

  describe "sending a draft message" do
    test "success" do
      %{
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_owner_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
      assert message.status == "draft"

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "id" => message.id,
          "content" => "Test sent",
          "content_delta" => "Test sent",
          "status" => "sent"
        })

      {:ok, challenge_owner_context} =
        MessageContextStatuses.get(user_challenge_owner, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_owner_context.read
      refute solver_context.read

      assert message.author_id == user_challenge_owner.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test sent"
      assert message.content_delta == "Test sent"
      assert message_context.last_message_id == message.id
      assert message.status == "sent"
    end
  end

  describe "fetching a draft message" do
    test "success: with ID" do
      %{
        user_challenge_owner: user_challenge_owner,
        message_context: message_context
      } = create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, fetched_message} = Messages.get_draft(message.id)

      assert message.id == fetched_message.id
      assert fetched_message.status == "draft"
    end

    test "failure: no draft message with given ID" do
      %{
        user_challenge_owner: user_challenge_owner,
        message_context: message_context
      } = create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_owner, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      assert {:error, :not_found} == Messages.get_draft(message.id)
    end
  end
end
