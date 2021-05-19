defmodule Web.ChallengeControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.AgencyHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index for challenges" do
    test "successfully retrieve all challenges", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com", role: "challenge_owner"})

      _challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      _challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      _challenge_3 = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "archived"})
      _challenge_4 = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})
      _challenge_5 = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "gsa_review"})

      conn = get(conn, Routes.challenge_path(conn, :index))

      %{
        user: user_in_assigns,
        pending_challenges: pending_challenges,
        pending_pagination: pending_pagination,
        challenges: challenges,
        pagination: pagination,
        filter: filter,
        sort: sort
      } = conn.assigns

      assert user === user_in_assigns

      assert length(challenges) === 5
      assert pagination.empty? === false
      assert pagination.current === 1
      assert pagination.total === 1
      assert pagination.total_count === 5

      assert length(pending_challenges) === 1
      assert pending_pagination.empty? === false
      assert pending_pagination.current === 1
      assert pending_pagination.total === 1
      assert pending_pagination.total_count === 1

      assert filter === %{}
      assert sort === %{}

      assert html_response(conn, 200) =~ "Challenges"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      conn = get(conn, Routes.challenge_path(conn, :index))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "failure: access list of challenges as a solver", %{conn: conn} do
      conn = prep_conn_solver(conn)
      %{current_user: user} = conn.assigns

      conn = get(conn, Routes.challenge_path(conn, :index))

      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not authorized"
      assert conn.halted
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end
  end

  describe "show for challenges" do
    test "successfully retrieve a challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      %{
        user: user_in_assigns,
        challenge: challenge_in_assigns,
        events: events,
        supporting_documents: supporting_documents
      } = conn.assigns

      assert user === user_in_assigns

      assert challenge.id === challenge_in_assigns.id
      assert Enum.empty?(events)
      assert Enum.empty?(supporting_documents)

      assert html_response(conn, 200) =~ "Challenge"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user(%{email: "user@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "new for challenges" do
    test "successfully open wizard form", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      conn = get(conn, Routes.challenge_path(conn, :new))

      %{
        user: user_in_assigns,
        changeset: changeset,
        path: path,
        section: section,
        challenge: challenge
      } = conn.assigns

      assert user === user_in_assigns
      assert changeset === Challenges.new(user)
      assert section === "general"
      assert path === Routes.challenge_path(conn, :create)
      assert challenge === nil

      assert html_response(conn, 200) =~ "Create a new challenge"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      conn = get(conn, Routes.challenge_path(conn, :new))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "create an announcement" do
    test "successfully", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "pending"
        })

      conn =
        post(conn, Routes.challenge_path(conn, :create_announcement, challenge.id),
          announcement: "Test announcement"
        )

      assert get_flash(conn, :info) === "Challenge announcement posted"
      assert redirected_to(conn) === Routes.challenge_path(conn, :show, challenge.id)
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user(%{email: "user@example.com"})
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "pending"
        })

      conn =
        post(conn, Routes.challenge_path(conn, :create_announcement, challenge.id),
          announcement: "Test announcement"
        )

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  defp prep_conn(conn) do
    user = AccountHelpers.create_user(%{role: "admin"})
    assign(conn, :current_user, user)
  end

  defp prep_conn_solver(conn) do
    user = AccountHelpers.create_user(%{role: "solver"})
    assign(conn, :current_user, user)
  end
end
