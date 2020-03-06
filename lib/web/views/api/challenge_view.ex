defmodule Web.Api.ChallengeView do
  use Web, :view

  alias Web.ChallengeView
  alias Web.Api.PaginationView

  def render("index.json", assigns = %{challenges: challenges}) do
    %{
      collection: render_many(challenges, __MODULE__, "card.json", assigns),
      pagination: render(PaginationView, "pagination.json", assigns)
    }
  end

  def render("card.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      title: challenge.title,
      tagline: challenge.tagline,
      agency_name: challenge.agency.name,
      logo: ChallengeView.logo_url(challenge),
      open_until: challenge.end_date
    }
  end

  def render("show.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      title: challenge.title,
      description: challenge.description
    }
  end
end
