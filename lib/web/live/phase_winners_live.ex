defmodule Web.PhaseWinnersLive do
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  alias Web.Router.Helpers, as: Routes

  alias ChallengeGov.Phases
  alias ChallengeGov.Challenges.Phases.Winner
  alias Stein.Storage

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    Phoenix.View.render(Web.PhaseView, "winners.html", assigns)
  end

  def mount(p, s, socket) do
    {:ok, challenge} = ChallengeGov.Challenges.get(p["cid"])
    {:ok, phase} = ChallengeGov.Phases.get(p["pid"])
    changeset = Winner.changeset(%Winner{}, %{"winners" => []})
    |> Ecto.Changeset.put_embed(:winners, [])

    socket =
      socket
      |> assign(:phase, phase)
      |> assign(:challenge, challenge)
      |> assign(:changeset, changeset)
      |> assign(:uploaded_files, [])
      |> Phoenix.LiveView.allow_upload(:winner_overview_img, accept: ~w(.jpg .jpeg .png), max_file_size: 10_000_000, progress: &handle_progress/3, auto_upload: true)
    {:ok, socket}
  end
  def handle_progress(key, entry, socket) do
    {:noreply, socket}
  end  

  def handle_event("validate", %{"winner" => winner_params}, socket) do
    changeset = Winner.changeset(%Winner{}, winner_params)
    socket = socket
    |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("add-winner", params, socket) do
    temp_id = get_temp_id()    
    winners = add_phase_winner(socket, temp_id)
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:winners, winners)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> Phoenix.LiveView.allow_upload(String.to_atom(temp_id), accept: ~w(.jpg .jpeg .png), max_file_size: 10_000_000, progress: &handle_progress/3, auto_upload: true)
    {:noreply, socket}
  end

  defp add_phase_winner(socket, temp_id) do
    _winners = Map.get(socket.assigns.changeset.changes, :winners, [])
    |> Enum.concat([
      Winner.SingleWinner.changeset(%Winner.SingleWinner{}, %{temp_id: temp_id})
    ])
  end

  # JUST TO GENERATE A RANDOM STRING
  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)

  def handle_event("save", params, socket) do
    {:noreply, socket}
  end

  def handle_event("remove-winner", %{"remove" => temp_id} = params, socket) do
    winners =
      socket.assigns.changeset.changes.winners |> Enum.reject(
      fn winner ->
        winner.changes.temp_id == temp_id
      end)
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:winners, winners)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("submit", params, socket) do
    updated_winners = for w <- Map.get(socket.assigns.changeset.changes, :winners, []),
      res = consume_upload_and_generate_url(socket, String.to_atom(w.changes.temp_id)) do
        case res do
          [winner_img_url] ->
            w |> Ecto.Changeset.put_change(:winner_img_url, winner_img_url)
          _ ->
            w
        end
    end

    changeset = socket.assigns.changeset
    changeset = case consume_upload_and_generate_url(socket, :winner_overview_img) do
      [winner_overview_img_url] ->
        changeset
        |> Ecto.Changeset.put_change(:winner_overview_img_url, winner_overview_img_url)
      _ ->
        changeset
    end
    changeset = changeset
    |> Ecto.Changeset.put_change(:status, "draft")
    |> Ecto.Changeset.put_change(:phase_id, socket.assigns.phase.id)
    |> Ecto.Changeset.put_embed(:winners, updated_winners)

    # next: save phase winners

    #socket =
     # socket
     # |> assign(:uploaded_files, :winners)

    #Phases.create_winner(params)
    #  to: Routes.challenge_phase_winner_path(Web.Endpoint, :winners_published, @challenge.id, @phase.id),
    {:noreply, socket}
  end

  defp consume_upload_and_generate_url(socket, key) do
    consume_uploaded_entries(socket, key, fn %{path: path} = p, entry ->
      # almost there... Stein Storage will come in handy here...
      #dest = Path.join("priv/static/uploads", Path.basename(path))
      #File.cp!(path, dest)
      [ext|_] = MIME.extensions(entry.client_type)      
      url = Routes.static_path(socket, "/uploads/phases/winners/#{entry.uuid}.#{ext}")
    end)
  end
end
