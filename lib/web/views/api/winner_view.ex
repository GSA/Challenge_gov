defmodule Web.Api.WinnerView do
  use Web, :view

  alias Stein.Storage

  def render("upload_image.json", %{image_path: image_path}) do
    %{image_path: Storage.url(image_path)}
  end

  def render(
        "phase_winner.json",
        _assigns = %{winner: phase_winner, phase_title: phase_title}
      ) do
    %{
      id: phase_winner.id,
      inserted_at: phase_winner.inserted_at,
      overview: phase_winner.overview,
      overview_delta: phase_winner.overview_delta,
      overview_image_path: phase_winner.overview_image_path,
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
    %{
      id: winner.id,
      image_path: winner.image_path,
      inserted_at: winner.inserted_at,
      name: winner.name,
      place_title: winner.place_title,
      updated_at: winner.updated_at
    }
  end
end
