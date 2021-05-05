defmodule Web.Api.WinnerView do
  use Web, :view

  alias Stein.Storage

  def render("upload_image.json", %{image_path: image_path}) do
    %{image_path: Storage.url(image_path)}
  end
end
