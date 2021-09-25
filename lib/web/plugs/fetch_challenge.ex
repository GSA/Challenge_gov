defmodule Web.Plugs.FetchChallenge do
  @moduledoc """
  Fetches a challenge and sets it in the conn when applicable.
  Able to override id to use if something other than "id" is
  passed into the controller action's params. Including "phase_id"
  """

  import Plug.Conn

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Repo

  def init(default), do: default

  def call(conn, opts) do
    id_param = Keyword.get(opts, :id_param, "id")

    case id_param do
      "id" ->
        load_challenge(conn, conn.params["id"])

      "challenge_id" ->
        load_challenge(conn, conn.params["challenge_id"])

      "phase_id" ->
        load_challenge_through_phase(conn, conn.params["phase_id"])

      "phase_winner_id" ->
        load_challenge_through_phase_winner(conn, conn.params["id"])
    end
  end

  defp load_challenge(conn, id) do
    case Challenges.get(id) do
      {:ok, challenge} ->
        challenge = Repo.preload(challenge, :challenge_managers)

        assign(conn, :current_challenge, challenge)

      {:error, :not_found} ->
        conn
    end
  end

  defp load_challenge_through_phase(conn, id) do
    case Phases.get(id) do
      {:ok, phase} ->
        phase = Repo.preload(phase, challenge: [:challenge_managers])

        conn
        |> assign(:current_challenge, phase.challenge)
        |> assign(:current_phase, phase)

      {:error, :not_found} ->
        conn
    end
  end

  defp load_challenge_through_phase_winner(conn, id) do
    case PhaseWinners.get(id) do
      {:ok, phase_winner} ->
        phase_winner = Repo.preload(phase_winner, phase: [challenge: [:challenge_managers]])

        conn
        |> assign(:current_challenge, phase_winner.phase.challenge)
        |> assign(:current_phase, phase_winner.phase)
        |> assign(:current_phase_winner, phase_winner)

      {:error, :not_found} ->
        conn
    end
  end
end
