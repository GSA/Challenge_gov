defmodule Web.BulletinController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Bulletin
  alias ChallengeGov.GovDelivery

  def new(conn, %{"challenge_id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.can_send_bulletin(user, challenge) do
      conn
      |> assign(:changeset, Bulletin.create_changeset(%Bulletin{}, %{}))
      |> assign(:path, Routes.challenge_bulletin_path(conn, :create, challenge.id))
      |> assign(:challenge, challenge)
      |> render("new.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to send a bulletin for this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def create(conn, %{"challenge_id" => id, "bulletin" => bulletin_params}) do
    %{current_user: user} = conn.assigns

    subject = "Challenge.Gov Bulletin: #{bulletin_params["subject"]}"

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.can_send_bulletin(user, challenge),
         {:ok, :sent} <- GovDelivery.send_bulletin(challenge, subject, bulletin_params["body"]) do
      conn
      |> put_flash(:info, "Bulletin scheduled to send")
      |> redirect(to: Routes.challenge_path(conn, :index))
    else
      {:send_error, _e} ->
        conn
        |> put_flash(:error, "Error sending bulletin")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to send a bulletin for this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end
end
