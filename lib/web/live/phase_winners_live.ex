defmodule Web.PhaseWinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  alias ChallengeGov.Phases
  alias ChallengeGov.Challenges.Phases.Winner

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    Phoenix.View.render(Web.PhaseView, "winners.html", assigns)
  end

  def mount(p, s, socket) do
    {:ok, challenge} = ChallengeGov.Challenges.get(p["cid"])
    {:ok, phase} = ChallengeGov.Phases.get(p["pid"])
    changeset = Winner.changeset(%Winner{}, %{})

    socket =
      socket
      |> assign(:phase, phase)
      |> assign(:challenge, challenge)
      |> assign(:changeset, changeset)
      |> assign(:uploaded_files, [])
      |> Phoenix.LiveView.allow_upload(:winner_image_extension, accept: ~w(.jpg .jpeg .png), progress: &handle_progress/3, auto_upload: true)
    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    changeset = Winner.changeset(%Winner{}, params["winner"])
    socket = socket
    |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_progress(:winner_image_extension, entry, socket) do
    {:noreply, socket}
  end

  def handle_progress(other, entry, socket) do
    {:noreply, socket}
  end

  def handle_event("add-winner", params, socket) do
    IO.inspect("params may be key")
    IO.inspect(params)
    # the plan:
    # count all outstanding 'winner-uploads'
    # generate an atom with the appropriate name
    # reference this name (or id), using 'w' to
    # form the ID

    # on submit, consume each and every uploaded file
    existing_winners = Map.get(socket.assigns.changeset.changes, :winners, [])
    str = "single_winner_image_#{Enum.count(existing_winners)}"
    temp_id = get_temp_id()

    winners = existing_winners
    |> Enum.concat([
      Ecto.Changeset.change(%Winner.SingleWinner{}, %{temp_id: temp_id})
    ])

    #IO.inspect("winners")
    #IO.inspect(winners)
    
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:winners, winners)

    IO.inspect("changeset")
    IO.inspect(changeset)
    socket =
      socket
      |> assign(:changeset, changeset)
      |> Phoenix.LiveView.allow_upload(String.to_atom(temp_id), accept: ~w(.jpg .jpeg .png), progress: &handle_progress/3, auto_upload: true)
    {:noreply, socket}
  end

  # JUST TO GENERATE A RANDOM STRING
  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)

  def handle_event("save", params, socket) do
    {:noreply, socket}
  end

  def handle_event("remove-winner", params, socket) do
    # remove nonpersisted winner
    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    #  to: Routes.challenge_phase_winner_path(Web.Endpoint, :winners_published, @challenge.id, @phase.id),
    winners = consume_uploaded_entries(socket, :winner_image_extension, fn %{path: path}, entry ->
    end)
    
    existing_winners = Map.get(socket.assigns.changeset.changes, :winners, [])
    for w <- existing_winners do
      single_winner_img = consume_uploaded_entries(socket, w.data.temp_id, fn %{path: path}, entry ->

      end)
    end

    changeset = socket.assigns.changeset
    |> Ecto.Changeset.put_change(:status, "draft")
    |> Ecto.Changeset.put_change(:phase_id, socket.assigns.phase.id)

    #Enum.map(changeset.changes.winners, fn e ->
    #  IO.inspect("WINNERS?")
    #  IO.inspect(e)
    #  IO.inspect(e.data)
    #  IO.inspect(e.changes)
    #end)
    
    socket =
      socket
      |> assign(:uploaded_files, :winners)

    #Phases.create_winner(params)
    
    {:noreply, socket}
  end
end
