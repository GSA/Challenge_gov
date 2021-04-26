defmodule Web.Api.PhaseWinnerView do
  use Web, :view

  def render("upload_overview_image.json", %{overview_image_path: overview_image_path}) do
    %{overview_image_path: overview_image_path}
  end
end
