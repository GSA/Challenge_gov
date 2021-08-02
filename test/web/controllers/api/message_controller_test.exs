defmodule Web.Api.MessageControllerTest do
  use Web.ConnCase
  use Web, :view

  alias ChallengeGov.Repo

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.Messages
  alias Web.AccountView
  alias Web.MessageContextView

  alias ChallengeGov.TestHelpers.MessageContextStatusHelpers

  defp prep_conn(conn, user) do
    assign(conn, :current_user, user)
  end

  describe "creating" do
    test "success: non solver on challenge context", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      conn =
        post(conn, Routes.api_message_path(conn, :create, message_context),
          message: message_params
        )

      message_context = Repo.preload(message_context, [:messages], force: true)
      message = Repo.preload(Enum.at(message_context.messages, 0), [:author])

      assert json_response(conn, 200) === expected_show_json(user_challenge_owner, message)
    end

    test "success: non solver draft on challenge context", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "draft"
      }

      conn =
        post(conn, Routes.api_message_path(conn, :create, message_context),
          message: message_params
        )

      message_context = Repo.preload(message_context, [:messages], force: true)
      message = Repo.preload(Enum.at(message_context.messages, 0), [:author])

      assert json_response(conn, 200) === expected_show_json(user_challenge_owner, message)
    end

    test "success: non solver update draft on challenge context", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "draft"
      }

      {:ok, message} = Messages.create(user_challenge_owner, message_context, message_params)

      conn = prep_conn(conn, user_challenge_owner)

      message_params = %{
        "id" => message.id,
        "content" => "Test updated",
        "content_delta" => "Test updated",
        "status" => "draft"
      }

      conn =
        put(conn, Routes.api_message_path(conn, :create, message_context), message: message_params)

      message_id = json_response(conn, 200)["id"]

      {:ok, message} = Messages.get_draft(message_id)
      message = Repo.preload(message, [:author])

      assert json_response(conn, 200) === expected_show_json(user_challenge_owner, message)
    end

    test "success: solver on challenge context", %{conn: conn} do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_solver)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      conn =
        post(conn, Routes.api_message_path(conn, :create, message_context),
          message: message_params
        )

      message_id = json_response(conn, 200)["id"]
      {:ok, message} = Messages.get(message_id)

      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      message = Repo.preload(message, [:author])

      assert json_response(conn, 200) === expected_show_json(user_solver, message)
      assert message.author_id === user_solver.id
      assert message.message_context_id === message_context_solver.id
    end

    test "success: solver on solver context", %{conn: conn} do
      %{
        message_context: message_context,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_solver)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      {:ok, _message} = Messages.create(user_solver, message_context, message_params)
      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      conn =
        post(conn, Routes.api_message_path(conn, :create, message_context_solver),
          message: message_params
        )

      message_id = json_response(conn, 200)["id"]
      {:ok, message} = Messages.get(message_id)

      message = Repo.preload(message, [:author])

      assert json_response(conn, 200) === expected_show_json(user_solver, message)
      assert message.author_id === user_solver.id
      assert message.message_context_id === message_context_solver.id
    end

    test "success: challenge owner on solver context", %{conn: conn} do
      %{
        message_context: message_context,
        user_challenge_owner: user_challenge_owner,
        user_solver: user_solver
      } = MessageContextStatusHelpers.create_message_context_status()

      conn = prep_conn(conn, user_challenge_owner)

      message_params = %{
        "content" => "Test",
        "content_delta" => "Test",
        "status" => "sent"
      }

      {:ok, _message} = Messages.create(user_solver, message_context, message_params)
      {:ok, message_context_solver} = MessageContexts.get("solver", user_solver.id, "all")

      conn =
        post(conn, Routes.api_message_path(conn, :create, message_context_solver),
          message: message_params
        )

      message_id = json_response(conn, 200)["id"]
      {:ok, message} = Messages.get(message_id)

      message = Repo.preload(message, [:author])

      assert json_response(conn, 200) === expected_show_json(user_challenge_owner, message)
      assert message.author_id === user_challenge_owner.id
      assert message.message_context_id === message_context_solver.id
    end
  end

  defp expected_show_json(user, message) do
    %{
      "id" => message.id,
      "author_id" => message.author_id,
      "author_name" => AccountView.full_name(message.author),
      "content" => message.content,
      "status" => message.status,
      "class" => MessageContextView.message_class(user, message)
    }
  end
end
