defmodule Web.Admin.SavedChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.SavedChallenges

  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.Admin.FallbackController)

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    %{page: saved_challenges, pagination: pagination} =
      SavedChallenges.all(user, filter: filter, sort: sort, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:saved_challenges, saved_challenges)
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def create(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, _saved_challenge} <- SavedChallenges.create(user, challenge) do
      conn
      |> put_flash(:info, "Challenge saved")
      |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))
    else
      {:error, :not_saved} ->
        conn
        |> put_flash(:error, "There was an error saving this challenge")
        |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, saved_challenge} <- SavedChallenges.get(id),
         {:ok, _saved_challenge} <- SavedChallenges.delete(user, saved_challenge) do
      conn
      |> put_flash(:info, "Challenge unsaved")
      |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Saved challenge not found")
        |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.admin_saved_challenge_path(conn, :index))
    end
  end
end
