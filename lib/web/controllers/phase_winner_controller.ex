defmodule Web.PhaseWinnerController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.PhaseWinners

  def index(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> render("phase_selection.html")
    end
  end

  def show(conn, %{"phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns

    {:ok, phase} = Phases.get(phase_id)
    {:ok, challenge} = Challenges.get(phase.challenge_id)

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

  def edit(conn, %{"phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns

    {:ok, phase} = Phases.get(phase_id)
    {:ok, challenge} = Challenges.get(phase.challenge_id)

    case PhaseWinners.get_by_phase_id(phase.id) do
      {:ok, phase_winner} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:changeset, PhaseWinners.edit(phase_winner))
        |> assign(:action, Routes.phase_winner_path(conn, :update, phase.id))
        |> render("edit.html")

      {:error, :no_phase_winner} ->
        {:ok, _phase_winner} = PhaseWinners.create(phase, %{"phase_winner" => %{}})
        redirect(conn, to: Routes.phase_winner_path(conn, :edit, phase.id))
    end
  end

  def update(conn, params = %{"phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns

    {:ok, phase} = Phases.get(phase_id)
    {:ok, challenge} = Challenges.get(phase.challenge_id)
    {:ok, phase_winner} = PhaseWinners.get_by_phase_id(phase.id)

    case PhaseWinners.update(phase_winner, params) do
      {:ok, _phase_winner} ->
        conn
        |> put_flash(:info, "Winners updated")
        |> redirect(to: Routes.phase_winner_path(conn, :show, phase.id))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:phase, phase)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
