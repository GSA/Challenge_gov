defmodule Web.EventController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Timeline

  action_fallback(Web.FallbackController)

  def new(conn, %{"challenge_id" => challenge_id}) do
    with {:ok, challenge} <- Challenges.get(challenge_id) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:changeset, Timeline.new_event(challenge))
      |> render("new.html")
    end
  end

  def create(conn, %{"challenge_id" => challenge_id, "event" => params}) do
    {:ok, challenge} = Challenges.get(challenge_id)

    case Timeline.create_event(challenge, params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Timeline event created!")
        |> redirect(to: Routes.challenge_path(conn, :show, event.challenge_id))

      {:error, changeset} ->
        conn
        |> assign(:challenge, challenge)
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, event} <- Timeline.get_event(id),
         {:ok, challenge} <- Challenges.get(event.challenge_id) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:event, event)
      |> assign(:changeset, Timeline.edit_event(event))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "event" => params}) do
    {:ok, event} = Timeline.get_event(id)

    case Timeline.update_event(event, params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Timeline event updated")
        |> redirect(to: Routes.challenge_path(conn, :show, event.challenge_id))

      {:error, changeset} ->
        {:ok, challenge} = Challenges.get(event.challenge_id)

        conn
        |> assign(:challenge, challenge)
        |> assign(:event, event)
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, event} <- Timeline.get_event(id),
         {:ok, event} <- Timeline.delete_event(event) do
      conn
      |> put_flash(:info, "Timeline event deleted")
      |> redirect(to: Routes.challenge_path(conn, :show, event.challenge_id))
    end
  end
end
