defmodule Web.PhaseWinnerController do
  use Web, :controller

  alias ChallengeGov.PhaseWinners

  plug(
    Web.Plugs.FetchChallenge,
    [id_param: "challenge_id"] when action in [:index]
  )

  plug(
    Web.Plugs.FetchChallenge,
    [id_param: "phase_id"] when action in [:show, :edit, :update]
  )

  plug Web.Plugs.AuthorizeChallenge

  def index(conn, %{"challenge_id" => _challenge_id}) do
    %{current_user: user, current_challenge: challenge} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> render("phase_selection.html")
  end

  def show(conn, %{"phase_id" => _phase_id}) do
    %{current_user: user, current_challenge: challenge, current_phase: phase} = conn.assigns

    case PhaseWinners.get_by_phase_id(phase.id) do
      {:ok, phase_winner} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:phase_winner, phase_winner)
        |> render("show.html")

      {:error, :no_phase_winner} ->
        {:ok, _phase_winner} = PhaseWinners.create(phase, %{"phase_winner" => %{}})
        redirect(conn, to: Routes.phase_winner_path(conn, :edit, phase.id))
    end
  end

  def edit(conn, %{"phase_id" => _phase_id}) do
    %{current_user: user, current_challenge: challenge, current_phase: phase} = conn.assigns

    case PhaseWinners.get_by_phase_id(phase.id) do
      {:ok, phase_winner} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:changeset, PhaseWinners.edit(phase_winner))
        |> assign(:upload_error, false)
        |> assign(:action, Routes.phase_winner_path(conn, :update, phase.id))
        |> render("edit.html")

      {:error, :no_phase_winner} ->
        {:ok, _phase_winner} = PhaseWinners.create(phase, %{"phase_winner" => %{}})
        redirect(conn, to: Routes.phase_winner_path(conn, :edit, phase.id))
    end
  end

  def update(conn, params = %{"phase_id" => _phase_id}) do
    %{current_user: user, current_challenge: challenge, current_phase: phase} = conn.assigns

    with {:ok, phase_winner} <- PhaseWinners.get_by_phase_id(phase.id),
         {:ok, _phase_winner} <- PhaseWinners.update(phase_winner, params) do
      conn
      |> put_flash(:info, "Winners updated")
      |> redirect(to: Routes.phase_winner_path(conn, :show, phase.id))
    else
      {:error, :no_phase_winner} ->
        {:ok, _phase_winner} = PhaseWinners.create(phase, %{"phase_winner" => %{}})
        redirect(conn, to: Routes.phase_winner_path(conn, :edit, phase.id))

      {:error, :something_went_wrong} ->
        {:ok, phase_winner} = PhaseWinners.get_by_phase_id(phase.id)

        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:changeset, PhaseWinners.edit(phase_winner))
        |> assign(:upload_error, true)
        |> assign(:action, Routes.phase_winner_path(conn, :update, phase.id))
        |> render("edit.html")

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:changeset, changeset)
        |> assign(:action, Routes.phase_winner_path(conn, :update, phase.id))
        |> render("edit.html")
    end
  end
end
