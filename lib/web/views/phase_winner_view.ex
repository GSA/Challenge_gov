defmodule Web.PhaseWinnerView do
  use Web, :view

  alias Web.FormView
  alias ChallengeGov.Challenges
  alias Web.SharedView
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Winners

  def render_title(challenge, phase) do
    content_tag :h1 do
      "Winners for Phase #{phase.title} of #{challenge.title}"
    end
  end

  def render_overview_image(%{overview_image_key: nil}), do: nil

  def render_overview_image(phase_winner) do
    overview_image_path = PhaseWinners.overview_image_path(phase_winner)
    img_tag(SharedView.upload_url(overview_image_path), style: "max-height: 200px")
  end

  def render_winner_image(%{image_key: nil}), do: nil

  def render_winner_image(winner) do
    image_path = Winners.image_path(winner)
    img_tag(SharedView.upload_url(image_path), style: "max-height: 200px")
  end

  def render_remove_image_checkbox(form, image_field, opts \\ []) do
    content_tag :label do
      [
        checkbox(form, :"remove_#{image_field}", Keyword.merge([hidden_input: false], opts)),
        " Remove image"
      ]
    end
  end
end
