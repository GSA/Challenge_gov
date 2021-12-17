defmodule Web.SavedChallengeControllerTest do
  use Web.ConnCase

  alias ChallengeGov.SavedChallenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index for saved challenges" do
    test "successfully retrieve all saved challenges for current user", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user_2.id,
          start_date: Timex.shift(Timex.now(), days: -1),
          end_date: Timex.shift(Timex.now(), days: 1),
          status: "published"
        })

      challenge_2 =
        ChallengeHelpers.create_challenge(%{
          user_id: user_2.id,
          start_date: Timex.shift(Timex.now(), days: -1),
          end_date: Timex.shift(Timex.now(), days: 1),
          status: "published"
        })

      challenge_3 =
        ChallengeHelpers.create_challenge(%{
          user_id: user_2.id,
          start_date: Timex.shift(Timex.now(), days: -2),
          end_date: Timex.shift(Timex.now(), days: -1),
          status: "published",
          sub_status: "archived"
        })

      challenge_4 =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          start_date: Timex.shift(Timex.now(), days: -1),
          end_date: Timex.shift(Timex.now(), days: 1),
          status: "published"
        })

      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)
      {:ok, _saved_challenge_2} = SavedChallenges.create(user, challenge_2)
      {:ok, _saved_challenge_3} = SavedChallenges.create(user, challenge_3)
      {:ok, _saved_challenge_4} = SavedChallenges.create(user_2, challenge_4)

      conn = get(conn, Routes.saved_challenge_path(conn, :index))

      %{
        open_saved_challenges: open_saved_challenges,
        closed_saved_challenges: closed_saved_challenges
      } = conn.assigns

      assert length(open_saved_challenges) === 2
      assert length(closed_saved_challenges) === 1
      assert html_response(conn, 200) =~ "Saved challenges"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      conn = get(conn, Routes.saved_challenge_path(conn, :index))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "new action" do
    test "successfully shows pre-save page", %{conn: conn} do
      conn = prep_conn(conn)

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user_2.id,
          title: "Test challenge",
          status: "published"
        })

      conn = get(conn, Routes.challenge_saved_challenge_path(conn, :new, challenge.id))

      assert html_response(conn, 200) =~
               "You are saving the following challenge to your saved list."

      assert html_response(conn, 200) =~ challenge.title
      assert html_response(conn, 200) =~ "Cancel"
      assert html_response(conn, 200) =~ "Finish"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      conn = get(conn, Routes.challenge_saved_challenge_path(conn, :new, challenge.id))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  # describe "show action" do
  #   test "successfully shows post-save page", %{conn: conn} do
  #     conn = prep_conn(conn)
  #     %{current_user: user} = conn.assigns

  #     user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
  #     challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
  #     {:ok, saved_challenge} = SavedChallenges.create(user, challenge)

  #     conn = get(conn, Routes.saved_challenge_path(conn, :show, saved_challenge.id))

  #     assert html_response(conn, 200) =~ "Challenge successfully saved"
  #   end

  #   test "redirect when not manager", %{conn: conn} do
  #     conn = prep_conn(conn)
  #     %{current_user: user} = conn.assigns

  #     user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
  #     challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})
  #     {:ok, saved_challenge} = SavedChallenges.create(user_2, challenge)

  #     conn = get(conn, Routes.saved_challenge_path(conn, :show, saved_challenge.id))

  #     assert conn.status === 302
  #     assert get_flash(conn, :error) === "Permission denied"
  #     assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
  #   end

  #   test "redirect when not found", %{conn: conn} do
  #     conn = prep_conn(conn)

  #     conn = get(conn, Routes.saved_challenge_path(conn, :show, 1))

  #     assert conn.status === 302
  #     assert get_flash(conn, :error) === "Saved challenge not found"
  #     assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
  #   end

  #   test "redirect to sign in when signed out", %{conn: conn} do
  #     user = AccountHelpers.create_user()
  #     challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

  #     {:ok, saved_challenge} = SavedChallenges.create(user, challenge)

  #     conn = get(conn, Routes.saved_challenge_path(conn, :show, saved_challenge.id))

  #     assert conn.status === 302
  #     assert conn.halted
  #     assert redirected_to(conn) == Routes.session_path(conn, :new)
  #   end
  # end

  describe "create action" do
    test "successfully", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})

      conn = post(conn, Routes.challenge_saved_challenge_path(conn, :create, challenge.id))

      saved_challenges = SavedChallenges.all(user)
      assert length(saved_challenges) === 1
      assert conn.status === 302

      assert get_flash(conn, :info) === [
               "Challenge saved. Click ",
               {:safe,
                [
                  60,
                  "a",
                  [
                    [
                      32,
                      "href",
                      61,
                      34,
                      "http://localhost:4001/?challenge=#{challenge.id}",
                      34
                    ]
                  ],
                  62,
                  "here",
                  60,
                  47,
                  "a",
                  62
                ]},
               " to be taken back to the challenge details"
             ]

      assert redirected_to(conn) ==
               Routes.saved_challenge_path(conn, :index)
    end

    @tag :pending
    test "successfully save after sign in", %{conn: _conn} do
      # saved_challenges = SavedChallenges.all(user)
      # assert length(saved_challenges) === 1
      # assert conn.status === 200
      # assert get_flash(conn, :info) === "Challenge saved"
      # assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
    end

    test "failure challenge not public", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "draft"})

      conn = post(conn, Routes.challenge_saved_challenge_path(conn, :create, challenge.id))

      saved_challenges = SavedChallenges.all(user)
      assert Enum.empty?(saved_challenges)
      assert conn.status === 302
      assert get_flash(conn, :error) === "There was an error saving this challenge"
      assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
    end

    @tag :pending
    test "failure when saving own challenge", %{conn: _conn} do
    end

    @tag :pending
    test "failure when not a solver", %{conn: _conn} do
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      conn = post(conn, Routes.challenge_saved_challenge_path(conn, :create, challenge.id))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "delete action" do
    test "successfully", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      {:ok, saved_challenge} = SavedChallenges.create(user, challenge)

      conn = delete(conn, Routes.saved_challenge_path(conn, :delete, saved_challenge.id))

      assert get_flash(conn, :info) === "Challenge unsaved"
      assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
    end

    test "failure when not found", %{conn: conn} do
      conn = prep_conn(conn)

      conn = delete(conn, Routes.saved_challenge_path(conn, :delete, 1))

      assert get_flash(conn, :error) === "Saved challenge not found"
      assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
    end

    test "failure when not manager", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})
      {:ok, saved_challenge} = SavedChallenges.create(user_2, challenge)

      conn = delete(conn, Routes.saved_challenge_path(conn, :delete, saved_challenge.id))

      assert conn.status === 302
      assert get_flash(conn, :error) === "Something went wrong"
      assert redirected_to(conn) == Routes.saved_challenge_path(conn, :index)
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      {:ok, saved_challenge} = SavedChallenges.create(user, challenge)

      conn = delete(conn, Routes.saved_challenge_path(conn, :delete, saved_challenge.id))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  defp prep_conn(conn) do
    user = AccountHelpers.create_user()
    assign(conn, :current_user, user)
  end
end
