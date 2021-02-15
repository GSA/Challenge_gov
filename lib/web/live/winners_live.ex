defmodule Web.WinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}
  def mount(p, s, socket) do
    {:ok, challenge} = ChallengeGov.Challenges.get(s["cid"])
    socket =
      socket
      |> assign(:challenge, challenge)
    
    {:ok, socket}
  end

  def render(assigns) do
    # {:ok, challenge} <- Challenges.
    Phoenix.View.render(Web.ChallengeView, "winners.html", assigns)
   # ~L"""
    #Winners Overview
    #<%= @conn %>    
    #<%= link("Review + Publish", to: Routes.challenge_phase_winner_path(@conn, :winners_published, @challenge_id, @phase_id), class: "btn btn-primary") %>
    #"""
  end

  def challenge_winners() do
  end

  def phase_winners() do
  end
end
