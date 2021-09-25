defmodule ChallengeGov.MessageContextStatusesTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Repo

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  @challenge_manager_params %{
    email: "challenge_manager@example.com",
    role: "challenge_manager"
  }

  @solver_params %{
    email: "solver_1@example.com",
    role: "solver"
  }

  defp create_message_context_status() do
    user_challenge_manager = AccountHelpers.create_user(@challenge_manager_params)
    user_solver = AccountHelpers.create_user(@solver_params)

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
        user_id: user_challenge_manager.id
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
      message_context: message_context,
      message_context_status: message_context_status
    }
  end

  describe "creating a message context status" do
    test "success" do
      %{
        message_context: message_context,
        message_context_status: message_context_status
      } = create_message_context_status()

      assert message_context_status.message_context_id == message_context.id
      refute message_context_status.read
      refute message_context_status.starred
    end
  end

  describe "marking context status as read" do
    test "success: set" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.mark_read(message_context_status)

      assert message_context_status.read
    end

    test "success: toggle" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.toggle_read(message_context_status)

      assert message_context_status.read
    end
  end

  describe "marking context status as unread" do
    test "success: set" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.mark_read(message_context_status)
      assert message_context_status.read

      {:ok, message_context_status} = MessageContextStatuses.mark_unread(message_context_status)
      refute message_context_status.read
    end

    test "success: toggle" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.toggle_read(message_context_status)
      assert message_context_status.read

      {:ok, message_context_status} = MessageContextStatuses.toggle_read(message_context_status)
      refute message_context_status.read
    end
  end

  describe "marking context status as starred" do
    test "success" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_starred(message_context_status)

      assert message_context_status.starred
    end
  end

  describe "marking context status as unstarred" do
    test "success" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_starred(message_context_status)

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_starred(message_context_status)

      refute message_context_status.starred
    end
  end

  describe "marking context status as archived" do
    test "success: set" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.archive(message_context_status)

      assert message_context_status.archived
    end

    test "success: toggle" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_archived(message_context_status)

      assert message_context_status.archived
    end
  end

  describe "marking context status as unarchived" do
    test "success: set" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} = MessageContextStatuses.archive(message_context_status)

      {:ok, message_context_status} = MessageContextStatuses.unarchive(message_context_status)

      refute message_context_status.archived
    end

    test "success: toggle" do
      %{
        message_context_status: message_context_status
      } = create_message_context_status()

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_archived(message_context_status)

      {:ok, message_context_status} =
        MessageContextStatuses.toggle_archived(message_context_status)

      refute message_context_status.archived
    end
  end

  describe "checking if a user has message context statuses" do
    test "success: no messages" do
      user = AccountHelpers.create_user()

      refute MessageContextStatuses.has_messages?(user)
    end

    test "success: has messages" do
      %{
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      assert MessageContextStatuses.has_messages?(user_solver)
    end
  end

  describe "fetching all challenge ids from messages for a user" do
    test "success" do
      %{
        challenge: challenge,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      fetched_challenge =
        user_solver
        |> MessageContextStatuses.get_challenges_for_user()
        |> Enum.at(0)

      assert fetched_challenge.id == challenge.id
    end
  end
end
