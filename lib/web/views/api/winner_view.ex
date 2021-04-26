defmodule Web.Api.WinnerView do
  use Web, :view

  def render("upload_image.json", %{image_path: image_path}) do
    %{image_path: image_path}
  end
end
