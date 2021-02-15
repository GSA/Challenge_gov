defmodule Web.PhaseWinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  def render(assigns) do
    IO.inspect("ASSIGNS")
    IO.inspect("phase winner live")
    IO.inspect(assigns)
    Phoenix.View.render(Web.PhaseView, "winners.html", assigns)
  end

  def create(_p, _s, socket) do
    IO.inspect("create acction!")
  end

  def mount(p, s, socket) do
    IO.inspect("phase winner mount")
    IO.inspect(p)
    IO.inspect(s)
    IO.inspect(socket)
    {:ok, challenge} = ChallengeGov.Challenges.get(p["cid"])
    {:ok, phase} = ChallengeGov.Phases.get(p["pid"])
    socket =
      socket
      |> assign(:phase, phase)
      |> assign(:challenge, challenge)
    {:ok, socket}
  end

  def phase_winners(params) do
    IO.inspect("phase_winners?")
  end
end
