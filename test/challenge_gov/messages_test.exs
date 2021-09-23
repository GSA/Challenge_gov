defmodule ChallengeGov.MessagesTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Repo

  alias ChallengeGov.Messages
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

  @solver_params_2 %{
    email: "solver_2@example.com",
    role: "solver"
  }

  defp create_message_context_status() do
    user_challenge_manager = AccountHelpers.create_user(@challenge_manager_params)
    user_solver = AccountHelpers.create_user(@solver_params)
    user_solver_2 = AccountHelpers.create_user(@solver_params_2)

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user_challenge_manager, %{
        user_id: user_challenge_manager.id
      })

    SubmissionHelpers.create_submitted_submission(%{}, user_solver, challenge)
    SubmissionHelpers.create_submitted_submission(%{}, user_solver_2, challenge)

    {:ok, message_context} =
      MessageContexts.create(%{
        "context" => "challenge",
        "context_id" => challenge.id,
        "audience" => "all"
      })

    message_context = Repo.preload(message_context, [:statuses])

    {:ok, message_context_status_challenge_manager} =
      MessageContextStatuses.get(user_challenge_manager, message_context)

    {:ok, message_context_status_solver} =
      MessageContextStatuses.get(user_solver, message_context)

    {:ok, message_context_status_solver_2} =
      MessageContextStatuses.get(user_solver_2, message_context)

    assert length(message_context.statuses) == 3

    %{
      user_challenge_manager: user_challenge_manager,
      user_solver: user_solver,
      user_solver_2: user_solver_2,
      message_context: message_context,
      # Placeholder for existing tests
      message_context_status: message_context_status_solver,
      message_context_status_challenge_manager: message_context_status_challenge_manager,
      message_context_status_solver: message_context_status_solver,
      message_context_status_solver_2: message_context_status_solver_2
    }
  end

  describe "creating a sent message" do
    test "success" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_manager_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test"
        })

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      refute solver_context.read

      assert message.author_id == user_challenge_manager.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      assert message_context.last_message_id == message.id
    end
  end

  describe "creating a draft message" do
    test "success: new draft" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_manager_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_manager.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
    end

    test "success: update draft" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_manager_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      initial_message_id = message.id

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_manager.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
      assert message.id == initial_message_id

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "id" => message.id,
          "content" => "Test updated",
          "content_delta" => "Test updated",
          "status" => "draft"
        })

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_manager.id
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
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, solver_context} = MessageContextStatuses.toggle_read(solver_context)

      refute challenge_manager_context.read
      assert solver_context.read

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      assert solver_context.read

      assert message.author_id == user_challenge_manager.id
      assert message.message_context_id == message_context.id
      assert message.content == "Test"
      assert message.content_delta == "Test"
      refute message_context.last_message_id
      assert message.status == "draft"

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "id" => message.id,
          "content" => "Test sent",
          "content_delta" => "Test sent",
          "status" => "sent"
        })

      {:ok, challenge_manager_context} =
        MessageContextStatuses.get(user_challenge_manager, message_context)

      {:ok, solver_context} = MessageContextStatuses.get(user_solver, message_context)

      {:ok, message_context} = MessageContexts.get(message_context.id)

      assert challenge_manager_context.read
      refute solver_context.read

      assert message.author_id == user_challenge_manager.id
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
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
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
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      assert {:error, :not_found} == Messages.get_draft(message.id)
    end
  end

  describe "can view draft" do
    test "success: author" do
      %{
        user_challenge_manager: user,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, fetched_message} = Messages.get_draft(message.id)

      assert {:ok, _message} = Messages.can_view_draft?(user, fetched_message)
    end

    test "success: related challenge manager" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_challenge_manager_2: user,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, fetched_message} = Messages.get_draft(message.id)

      assert {:ok, _message} = Messages.can_view_draft?(user, fetched_message)
    end

    test "failure: unrelated user" do
      %{
        user_solver: user,
        user_challenge_manager: user_challenge_manager,
        message_context: message_context
      } = MessageContextStatusHelpers.create_message_context_status()

      {:ok, message} =
        Messages.create(user_challenge_manager, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      {:ok, fetched_message} = Messages.get_draft(message.id)

      assert Messages.can_view_draft?(user, fetched_message) == {:error, :cant_view_draft}
    end
  end

  describe "creating a sent message as a solver on a challenge context" do
    test "success: creates solver context and attaches message to it" do
      %{
        user_solver: user_solver,
        user_solver_2: user_solver_2,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver_2, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 1
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver_2} = MessageContexts.get("solver", user_solver_2.id, "all")

      message_context_solver_2 =
        Repo.preload(message_context_solver_2, [:statuses, :messages], force: true)

      assert length(message_context_solver_2.statuses) == 2
      assert length(message_context_solver_2.messages) == 1
    end

    test "success: finds solver context and attaches message to it" do
      %{
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end
  end

  describe "creating a draft message as a solver on a challenge context" do
    test "success: creates solver context and attaches message to it" do
      %{
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end

    test "success: finds solver context and attaches message to it" do
      %{
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end
  end

  describe "creating a message as a solver on a solver context" do
    test "success: attach sent message to solver context" do
      %{
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver, message_context_solver, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end

    test "success: attach draft message to solver context" do
      %{
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_solver, message_context_solver, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end
  end

  describe "creating a message as a non solver on a solver context" do
    test "success: attach sent message to solver context" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context_solver, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end

    test "success: attach draft message to solver context" do
      %{
        user_challenge_manager: user_challenge_manager,
        user_solver: user_solver,
        message_context: message_context
      } = create_message_context_status()

      {:ok, _message} =
        Messages.create(user_solver, message_context, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "sent"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 1

      {:ok, _message} =
        Messages.create(user_challenge_manager, message_context_solver, %{
          "content" => "Test",
          "content_delta" => "Test",
          "status" => "draft"
        })

      message_context = Repo.preload(message_context, [:statuses, :messages], force: true)

      assert length(message_context.statuses) == 2
      assert Enum.empty?(message_context.messages)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message_context_solver =
        Repo.preload(message_context_solver, [:statuses, :messages], force: true)

      assert length(message_context_solver.statuses) == 2
      assert length(message_context_solver.messages) == 2
    end
  end
end
