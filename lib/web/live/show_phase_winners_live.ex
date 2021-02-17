defmodule ChallengeGov.Web.ShowPhaseWinnersLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h1>Showing Winners (html)</h1>
    """
  end

  def mount(_params, s, socket) do
    {:ok, socket}
  end
end
