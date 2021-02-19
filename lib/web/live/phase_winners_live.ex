defmodule Web.PhaseWinnersLive do
  @moduledoc """
  LiveView for Phase Winners
  """
  use Phoenix.LiveView, layout: {Web.LayoutView, "live.html"}

  alias Web.Router.Helpers, as: Routes

  alias ChallengeGov.Phases
  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges.Phases.Winner
  alias Stein.Storage

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    Phoenix.View.render(Web.PhaseView, "winners.html", assigns)
  end

  def mount(params, session, socket) do
    phase_winners = Repo.get_by(Winner, phase_id: String.to_integer(params["pid"]))

    socket =
      socket
      |> assign_defaults(params, session)
      |> assign_status_specific(phase_winners)

    {:ok, socket}
  end

  defp assign_defaults(socket, params, session) do
    {:ok, challenge} = ChallengeGov.Challenges.get(params["cid"])
    {:ok, phase} = ChallengeGov.Phases.get(params["pid"])
    {:ok, user} = ChallengeGov.Accounts.get(session["user_id"])

    socket
    |> assign(:phase, phase)
    |> assign(:challenge, challenge)
    |> assign(:user, user)
    |> assign(:uploaded_files, [])
  end

  defp assign_status_specific(socket, nil) do
    # if winner already exists, phase redirect is the answer
    changeset = Winner.changeset(%Winner{}, %{"winners" => []})

    changeset =
      changeset
      |> Ecto.Changeset.put_embed(:winners, [])

    socket
    |> assign(:changeset, changeset)
    |> assign(:action, :draft)
    |> assign(
      :text,
      "Entering winners is as flexible as you need for your phase. Add any information (overview details) about the challenge."
    )
    |> Phoenix.LiveView.allow_upload(:winner_overview_img,
      accept: ~w(.jpg .jpeg .png),
      max_file_size: 10_000_000,
      progress: &handle_progress/3,
      auto_upload: true
    )
  end

  defp assign_status_specific(socket, phase_winners) do
    socket =
      socket
      |> assign(:action, :review)
      |> assign(:winners, phase_winners)
      |> assign(:text, "Review the information and publish the winners.")
  end

  def handle_progress(key, entry, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", %{"winner" => winner_params}, socket) do
    changeset = Winner.changeset(%Winner{}, winner_params)

    socket =
      socket
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
      |> Phoenix.LiveView.allow_upload(String.to_atom(temp_id),
        accept: ~w(.jpg .jpeg .png),
        max_file_size: 10_000_000,
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:noreply, socket}
  end

  defp add_phase_winner(socket, temp_id) do
    changes = Map.get(socket.assigns.changeset.changes, :winners, [])

    _winners =
      changes
      |> Enum.concat([
        Winner.SingleWinner.changeset(%Winner.SingleWinner{}, %{temp_id: temp_id})
      ])
  end

  # generate a random string
  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  def handle_event("save", params, socket) do
    {:noreply, socket}
  end

  def handle_event("remove-winner", _params = %{"remove" => temp_id}, socket) do
    winners =
      socket.assigns.changeset.changes.winners
      |> Enum.reject(fn winner ->
        winner.changes.temp_id == temp_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:winners, winners)

    socket =
      socket
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    updated_winners =
      for w <- Map.get(socket.assigns.changeset.changes, :winners, []),
          res = consume_upload_and_generate_url(socket, String.to_atom(w.changes.temp_id)) do
        case res do
          [winner_img_url] ->
            w |> Ecto.Changeset.put_change(:winner_img_url, winner_img_url)

          _ ->
            w
        end
      end

    changeset = socket.assigns.changeset

    changeset =
      case consume_upload_and_generate_url(socket, :winner_overview_img) do
        [winner_overview_img_url] ->
          changeset
          |> Ecto.Changeset.put_change(:winner_overview_img_url, winner_overview_img_url)

        _ ->
          changeset
      end

    changeset =
      changeset
      |> Ecto.Changeset.put_change(:status, "draft")
      |> Ecto.Changeset.put_change(:phase_id, socket.assigns.phase.id)
      |> Ecto.Changeset.put_embed(:winners, updated_winners)

    winners_persisted = Repo.insert!(changeset)

    {:noreply,
     push_redirect(socket,
       to:
         Routes.live_path(
           Web.Endpoint,
           Web.ShowPhaseWinnersLive,
           socket.assigns.challenge.id,
           socket.assigns.phase.id,
           winners_persisted.id
         ),
       replace: true
     )}
  end

  defp consume_upload_and_generate_url(socket, key) do
    consume_uploaded_entries(socket, key, fn %{path: path} = p, entry ->
      # almost there... Stein Storage will come in handy here...
      # dest = Path.join("priv/static/uploads", Path.basename(path))
      # File.cp!(path, dest)
      [ext | _] = MIME.extensions(entry.client_type)
      url = Routes.static_path(socket, "/uploads/phases/winners/#{entry.uuid}.#{ext}")
    end)
  end

  def handle_event("publish", params, socket) do
    socket =
      socket
      |> assign(:action, :publish)
      |> put_flash(:info, "Winners updated successfully.")

    {:noreply, socket}
  end
end
