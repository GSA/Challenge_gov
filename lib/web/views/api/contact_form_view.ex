defmodule Web.Api.ChallengeView do
  use Web, :view

  def render("success.json", _) do
    %{
      message: "Your message has been received"
    }
  end
end