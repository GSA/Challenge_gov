defmodule Web.Api.PhaseWinnerView do
  use Web, :view

  def render("upload_overview_image.json", %{key: key, extension: extension}) do
    %{key: key, extension: extension}
  end
end
