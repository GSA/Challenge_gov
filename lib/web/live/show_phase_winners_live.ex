defmodule Web.ShowPhaseWinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    ~L"""
    <h1>Showing Winners (html)</h1>
    """
  end

  def mount(_params, s, socket) do
    IO.inspect("mounting!")
    {:ok, socket}
  end
end
