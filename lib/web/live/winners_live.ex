defmodule Web.WinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  def mount(p, s, socket) do
    {:ok, challenge} = ChallengeGov.Challenges.get(p["id"])
    {:ok, user} = ChallengeGov.Accounts.get(s["user_id"])

    socket =
      socket
      |> assign(:challenge, challenge)
      |> assign(:user, user)

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(Web.ChallengeView, "winners.html", assigns)
  end
end
