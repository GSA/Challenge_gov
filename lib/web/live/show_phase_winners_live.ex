defmodule Web.ShowPhaseWinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges.Phases.Winner

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    Phoenix.View.render(Web.PhaseView, "show_winners.html", assigns)
  end

  def mount(p, s, socket) do
    IO.inspect("mounting!")
    winners = Repo.get(Winner, p["wid"])
    {:ok, phase} = ChallengeGov.Phases.get(winners.phase_id)
    {:ok, challenge} = ChallengeGov.Challenges.get(p["cid"])

    socket = socket
    |> assign(:phase, phase)
    |> assign(:winners, winners)
    |> assign(:challenge, challenge)
    |> assign(:text, "Review the information and publish winners.")
    {:ok, socket}
  end

  def handle_event("publish", params, socket) do
    changeset = Winner.changeset(%Winner{}, %{"status" => "review"})

    {:noreply, put_flash(socket, :info, "Winners updated successfully.")}
  end
end
