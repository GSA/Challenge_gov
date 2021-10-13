defmodule Web.SavedChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.SavedChallenges
  alias Web.ChallengeView

  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.FallbackController)

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: _page, per: _per} = conn.assigns

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    # {saved_challenges, pagination} =
    #   if !is_nil(page) and !is_nil(per) do
    #     %{page: saved_challenges, pagination: pagination} =
    #       SavedChallenges.all(user, filter: filter, sort: sort, page: page, per: per)
    #     {saved_challenges, pagination}
    #   else
    #     {SavedChallenges.all(user, filter: filter, sort: sort), nil}
    #   end

    {saved_challenges, _pagination} = {SavedChallenges.all(user, filter: filter, sort: sort), nil}

    open_saved_challenges =
      Enum.filter(saved_challenges, fn saved_challenge ->
        Challenges.is_open?(saved_challenge.challenge)
      end)

    closed_saved_challenges =
      Enum.filter(saved_challenges, fn saved_challenge ->
        Challenges.is_closed?(saved_challenge.challenge)
      end)

    conn
    |> assign(:user, user)
    |> assign(:open_saved_challenges, open_saved_challenges)
    |> assign(:closed_saved_challenges, closed_saved_challenges)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, saved_challenge} <- SavedChallenges.get(id),
         {:ok, saved_challenge} <- SavedChallenges.check_manager(user, saved_challenge) do
      conn
      |> assign(:challenge, saved_challenge.challenge)
      |> render("show.html")
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Saved challenge not found")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))

      {:error, :wrong_manager} ->
        conn
        |> put_flash(:error, "Permission denied")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))
    end
  end

  def new(conn, %{"challenge_id" => challenge_id}) do
    case Challenges.get(challenge_id) do
      {:ok, challenge} ->
        conn
        |> assign(:challenge, challenge)
        |> render("new.html")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))
    end
  end

  def create(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, _saved_challenge} <- SavedChallenges.create(user, challenge) do
      conn
      |> put_flash(:info, [
        "Challenge saved. Click ",
        Phoenix.HTML.Link.link("here",
          to: ChallengeView.public_details_url(challenge)
        ),
        " to be taken back to the challenge details"
      ])
      |> redirect(to: Routes.saved_challenge_path(conn, :index))
    else
      {:error, :not_saved} ->
        conn
        |> put_flash(:error, "There was an error saving this challenge")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Already saved this challenge")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, saved_challenge} <- SavedChallenges.get_saved_challenge(id),
         {:ok, _saved_challenge} <- SavedChallenges.delete(user, saved_challenge) do
      conn
      |> put_flash(:info, "Challenge unsaved")
      |> redirect(to: Routes.saved_challenge_path(conn, :index))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Saved challenge not found")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.saved_challenge_path(conn, :index))
    end
  end
end
