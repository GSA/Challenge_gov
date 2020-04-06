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
      agency_name: ChallengeView.agency_name(challenge),
      logo: ChallengeView.logo_url(challenge),
      open_until: challenge.end_date
    }
  end

  def render("show.json", %{challenge: challenge}) do
    %{
      status: challenge.status,
      agency_id: challenge.agency_id,
      agency_name: ChallengeView.agency_name(challenge),
      poc_email: challenge.poc_email,
      id: challenge.id,
      type: challenge.type,
      description: challenge.description,
      brief_description: challenge.brief_description,
      how_to_enter: challenge.how_to_enter,
      fiscal_year: challenge.fiscal_year,
      start_date: challenge.start_date,
      end_date: challenge.end_date,
      multi_phase: challenge.multi_phase,
      legal_authority: challenge.legal_authority,
      title: challenge.title,
      prize_total: challenge.prize_total,
      winner_information: challenge.winner_information,
      faq: challenge.faq,
      rules: challenge.rules,
      logo: challenge.logo,
      upload_logo: challenge.upload_logo,
      logo_extension: challenge.logo_extension,
      federal_partners:
        render_many(
          challenge.federal_partner_agencies,
          __MODULE__,
          "federal_partner_agencies.json",
          as: :agency
        ),
      non_federal_partners:
        render_many(
          challenge.non_federal_partners,
          __MODULE__,
          "non_federal_partners.json",
          as: :partner
        )
    }
  end

  def render("federal_partner_agencies.json", %{agency: agency}) do
    IO.inspect agency
    %{
      id: agency.id,
      name: agency.name
    }
  end

  def render("non_federal_partners.json", %{partner: partner}) do
    %{
      id: partner.id,
      name: partner.name
    }
  end
end
