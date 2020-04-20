defmodule Web.Admin.SolutionControllerTests do
  use Web.ConnCase

  alias ChallengeGov.Solutions
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SolutionHelpers

  describe "index under challenge" do
    test "successfully retrieve all solutions for challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge_2)

      conn = get(conn, Routes.admin_challenge_solution_path(conn, :index, challenge.id))

      %{solutions: solutions, pagination: _pagination} = conn.assigns

      assert length(solutions) === 1
    end

    test "successfully retrieve filtered solutions for challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(
        %{
          title: "Filtered title"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(%{}, user, challenge_2)

      SolutionHelpers.create_submitted_solution(
        %{
          title: "Filtered title"
        },
        user,
        challenge_2
      )

      conn =
        get(conn, Routes.admin_challenge_solution_path(conn, :index, challenge.id),
          filter: %{title: "Filtered"}
        )

      %{solutions: solutions, pagination: _pagination, filter: filter} = conn.assigns

      assert length(solutions) === 1
      assert filter["challenge_id"] === Integer.to_string(challenge.id)
      assert filter["title"] === "Filtered"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      conn = get(conn, Routes.admin_challenge_solution_path(conn, :index, challenge.id))

      assert conn.status === 302
      assert conn.halted
    end
  end

  describe "show action" do
    test "successfully viewing a solution", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution =
        SolutionHelpers.create_submitted_solution(
          %{
            title: "Filtered title"
          },
          user,
          challenge
        )

      conn = get(conn, Routes.admin_solution_path(conn, :show, solution.id))
      %{solution: fetched_solution} = conn.assigns

      assert fetched_solution.id === solution.id
    end

    test "not found viewing a deleted solution", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      Solutions.delete(solution, user)

      conn = get(conn, Routes.admin_solution_path(conn, :show, solution.id))

      assert conn.status === 404
    end
  end

  describe "new action" do
    test "viewing the new solution form", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      conn = get(conn, Routes.admin_challenge_solution_path(conn, :new, challenge.id))

      %{changeset: changeset} = conn.assigns

      assert changeset
    end
  end

  describe "create action" do
    test "saving as a draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "action" => "draft",
        "solution" => %{
          "title" => "Test title"
        }
      }

      conn = post(conn, Routes.admin_challenge_solution_path(conn, :create, challenge.id), params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :edit, id)
    end

    test "creating a solution and review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "Test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => "Test external url"
        }
      }

      conn = post(conn, Routes.admin_challenge_solution_path(conn, :create, challenge.id), params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :show, id)
    end

    test "creating a solution and review with missing params", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      params = %{
        "action" => "review",
        "solution" => %{}
      }

      conn = post(conn, Routes.admin_challenge_solution_path(conn, :create, challenge.id), params)

      %{changeset: changeset} = conn.assigns

      assert conn.status === 422
      assert changeset.errors[:title]
      assert changeset.errors[:brief_description]
      assert changeset.errors[:description]
      assert changeset.errors[:external_url]
    end
  end

  describe "edit action" do
    test "viewing the edit solution form for a draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      conn = get(conn, Routes.admin_solution_path(conn, :edit, solution.id))

      %{solution: solution, changeset: changeset} = conn.assigns

      assert changeset
      assert solution.status === "draft"
    end

    test "viewing the edit solution form for a submitted solution", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      conn = get(conn, Routes.admin_solution_path(conn, :edit, solution.id))

      %{solution: solution, changeset: changeset} = conn.assigns

      assert changeset
      assert solution.status === "submitted"
    end

    test "viewing the edit solution form for a solution you don't own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user_2, challenge)

      conn = get(conn, Routes.admin_solution_path(conn, :edit, solution.id))

      assert get_flash(conn, :error) === "You are not allowed to edit this solution"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "viewing the edit solution form for a solution that was deleted", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      {:ok, solution} = Solutions.delete(solution, user)

      conn = get(conn, Routes.admin_solution_path(conn, :edit, solution.id))

      assert get_flash(conn, :error) === "Solution not found"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "viewing the edit solution form for a solution that doesn't exist", %{conn: conn} do
      conn = prep_conn(conn)

      conn = get(conn, Routes.admin_solution_path(conn, :edit, 1))

      assert get_flash(conn, :error) === "Solution not found"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end
  end

  describe "update action" do
    test "updating a draft solution and saving as draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      params = %{
        "action" => "draft",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      {:ok, solution} = Solutions.get(solution.id)

      assert solution.status === "draft"
      assert get_flash(conn, :info) === "Solution saved as draft"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :edit, solution.id)
    end

    test "updating a submitted solution and saving as draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      params = %{
        "action" => "draft",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      {:ok, solution} = Solutions.get(solution.id)

      assert solution.status === "draft"
      assert get_flash(conn, :info) === "Solution saved as draft"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :edit, solution.id)
    end

    test "updating a solution and sending to review with errors", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      %{changeset: changeset} = conn.assigns

      assert changeset.errors[:external_url]
    end

    test "updating a solution and sending to review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      {:ok, solution} = Solutions.get(solution.id)

      assert solution.status === "draft"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :show, solution.id)
    end

    test "attempting to update a solution that you don't own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user_2, challenge)

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      assert get_flash(conn, :error) === "You are not allowed to edit this solution"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "updating a solution to submitted", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      conn = put(conn, Routes.admin_solution_path(conn, :submit, solution.id))

      {:ok, solution} = Solutions.get(solution.id)

      assert solution.status === "submitted"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :show, solution.id)
    end

    test "attempting to update a solution that was deleted", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, solution} = Solutions.delete(solution, user)

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, solution.id), params)

      assert get_flash(conn, :error) === "This solution does not exist"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "attempting to update a solution that doesn't exist", %{conn: conn} do
      conn = prep_conn(conn)

      params = %{
        "action" => "review",
        "solution" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.admin_solution_path(conn, :update, 1), params)

      assert get_flash(conn, :error) === "This solution does not exist"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end
  end

  describe "delete action" do
    test "deleting a draft solution you own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, solution.id))

      assert {:error, :not_found} === Solutions.get(solution.id)
      assert get_flash(conn, :info) === "Solution deleted"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "deleting a submitted solution you own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, solution.id))

      assert {:error, :not_found} === Solutions.get(solution.id)
      assert get_flash(conn, :info) === "Solution deleted"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "deleting a draft solution as an admin", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user()

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user_2, challenge)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, solution.id))

      assert {:error, :not_found} === Solutions.get(solution.id)
      assert get_flash(conn, :info) === "Solution deleted"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "deleting a submitted solution as an admin", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user()

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user_2, challenge)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, solution.id))

      assert {:error, :not_found} === Solutions.get(solution.id)
      assert get_flash(conn, :info) === "Solution deleted"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "deleting a deleted solution", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, solution} = Solutions.delete(solution, user)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, solution.id))

      assert {:error, :not_found} === Solutions.get(solution.id)
      assert get_flash(conn, :error) === "This solution does not exist"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end

    test "deleting a solution that doesn't exist", %{conn: conn} do
      conn = prep_conn(conn)

      conn = delete(conn, Routes.admin_solution_path(conn, :delete, 1))

      assert get_flash(conn, :error) === "This solution does not exist"
      assert redirected_to(conn) === Routes.admin_solution_path(conn, :index)
    end
  end

  defp prep_conn(conn) do
    user = AccountHelpers.create_user()
    assign(conn, :current_user, user)
  end

  defp prep_conn_admin(conn) do
    user = AccountHelpers.create_user(%{email: "admin@example.com", role: "admin"})
    assign(conn, :current_user, user)
  end
end
