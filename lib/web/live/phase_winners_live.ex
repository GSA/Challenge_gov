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
    {:noreply, socket}
  end

  def handle_progress(:winner_image_extension, entry, socket) do
    {:noreply, socket}
  end

  def handle_progress(other, entry, socket) do
    {:noreply, socket}
  end

  def handle_event("add-winner", params, socket) do
    # the plan:
    # count all outstanding 'winner-uploads'
    # generate an atom with the appropriate name
    # reference this name (or id), using 'w' to
    # form the ID

    # on submit, consume each and every uploaded file

    
    
    existing_winners = Map.get(socket.assigns.changeset.changes, :winners, [])
    str = "single_winner_image_#{Enum.count(existing_winners)}"
    img_key = String.to_atom(str)
    tmp_id = get_temp_id()

    winners = existing_winners
    |> Enum.concat([%Winner.SingleWinner{temp_id: tmp_id}])
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:winners, winners)
    socket =
      socket
      |> assign(:changeset, changeset)
      |> Phoenix.LiveView.allow_upload(img_key, accept: ~w(.jpg .jpeg .png), progress: &handle_progress/3, auto_upload: true)
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
    for {w, i} <- Enum.with_index(existing_winners) do
      str = "single_winner_image_#{i}"
      img_key = String.to_atom(str)
      single_winners = consume_uploaded_entries(socket, img_key, fn %{path: path}, entry ->
      end)
    end
    socket =
      socket
      |> assign(:uploaded_files, :winners)

    #Phases.create_winner(params)
    
    {:noreply, socket}
      end

#        defp generate_img_key(i) do
#        end
end
