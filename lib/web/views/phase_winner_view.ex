defmodule Web.PhaseWinnerView do
  use Web, :view

  alias Web.FormView
  alias Web.SharedView

  def render_title(challenge, phase) do
    content_tag :h1 do
      "Winners for Phase #{phase.title} of #{challenge.title}"
    end
  end

  def render_overview_image(%{overview_image_path: nil}), do: nil

  def render_overview_image(%{overview_image_path: overview_image_path}),
    do: img_tag(SharedView.upload_url(overview_image_path))

  def render_winner_image(%{image_path: nil}), do: nil

  def render_winner_image(%{image_path: image_path}),
    do: img_tag(SharedView.upload_url(image_path))

  def render_remove_image_checkbox(form, image_field, opts \\ []) do
    content_tag :label do
      [
        checkbox(form, :"remove_#{image_field}", Keyword.merge([hidden_input: false], opts)),
        " Remove image"
      ]
    end
  end
end
