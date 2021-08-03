defmodule Web.Api.WinnerView do
  use Web, :view

  alias Stein.Storage
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Winners

  def render("upload_image.json", %{key: key, extension: extension}) do
    %{key: key, extension: extension}
  end

  def render(
        "phase_winner.json",
        _assigns = %{winner: phase_winner, phase_title: phase_title}
      ) do
    overview_image_path =
      if PhaseWinners.overview_image_path(phase_winner),
        do:
          Storage.url(PhaseWinners.overview_image_path(phase_winner), signed: [expires_in: 3600]),
        else: nil

    %{
      id: phase_winner.id,
      inserted_at: phase_winner.inserted_at,
      overview: phase_winner.overview,
      overview_delta: phase_winner.overview_delta,
      overview_image_path: overview_image_path,
      phase_title: phase_title,
      phase_id: phase_winner.phase_id,
      status: phase_winner.status,
      updated_at: phase_winner.updated_at,
      uuid: phase_winner.uuid,
      winners: render_many(phase_winner.winners, __MODULE__, "winners.json")
    }
  end

  def render("phase_winner.json", _assigns) do
    %{}
  end

  def render("winners.json", %{winner: winner}) do
    image_path =
      if Winners.image_path(winner),
        do: Storage.url(Winners.image_path(winner), signed: [expires_in: 3600]),
        else: nil

    %{
      id: winner.id,
      image_path: image_path,
      inserted_at: winner.inserted_at,
      name: winner.name,
      place_title: winner.place_title,
      updated_at: winner.updated_at
    }
  end
end
