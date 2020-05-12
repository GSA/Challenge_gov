defmodule Web.ChallengeView do
  use Web, :view

  alias ChallengeGov.Challenges.Logo
  alias ChallengeGov.Challenges.WinnerImage
  alias Stein.Storage
  alias Web.AgencyView

  def logo_img(challenge, opts \\ []) do
    case is_nil(challenge.logo_key) do
      true ->
        AgencyView.avatar_img(challenge.agency, opts)

      false ->
        url = Storage.url(Logo.logo_path(challenge, "thumbnail"), signed: [expires_in: 3600])
        opts = Keyword.merge([alt: "Challenge Logo"], opts)
        img_tag(url, opts)
    end
  end

  def logo_url(challenge) do
    case is_nil(challenge.logo_key) do
      true ->
        nil

      false ->
        Storage.url(Logo.logo_path(challenge, "original"), signed: [expires_in: 3600])
    end
  end

  def agency_name(challenge) do
    if challenge.agency, do: challenge.agency.name
  end

  def agency_logo(challenge) do
    if challenge.agency.avatar_key,
      do: AgencyView.avatar_url(challenge.agency),
      else: nil
  end

  def winner_img(challenge, opts \\ []) do
    case is_nil(challenge.winner_image_key) do
      true ->
        path = Routes.static_path(Web.Endpoint, "/images/teams-card-logo.jpg")
        img_tag(path, alt: "Winner Image")

      false ->
        url =
          Storage.url(WinnerImage.winner_image_path(challenge, "thumbnail"),
            signed: [expires_in: 3600]
          )

        opts = Keyword.merge([alt: "Winner Image"], opts)
        img_tag(url, opts)
    end
  end

  def winner_img_url(challenge, _opts \\ []) do
    case is_nil(challenge.winner_image_key) do
      true ->
        nil

      false ->
        Storage.url(WinnerImage.winner_image_path(challenge, "original"),
          signed: [expires_in: 3600]
        )
    end
  end

  def public_index_url() do
    Routes.public_challenge_index_url(Web.Endpoint, :index)
  end

  def public_details_url(challenge) do
    Routes.public_challenge_details_url(
      Web.Endpoint,
      :index,
      challenge.custom_url || challenge.id
    )
  end

  def disqus_domain() do
    Application.get_env(:challenge_gov, :disqus_domain)
  end

  def timeline_position(event_time, events) do
    dates = Enum.map(events, fn x -> x.occurs_on end)
    dates = [Timex.today() | dates]

    {min, max} = Enum.min_max_by(dates, fn time -> Timex.to_unix(time) end)

    position =
      if min != max && Enum.count(dates) > 1 do
        days_range = Timex.diff(min, max, :days)
        days_from_start = Timex.diff(min, event_time, :days)
        "#{days_from_start / days_range * 100}%"
      else
        "0%"
      end

    position
  end

  def timeline_date(event_time) do
    with {:ok, time} = Timex.format(event_time, "{Mshort} {D}, {YYYY}") do
      time
    end
  end

  def timeline_class(event_time) do
    case Timex.compare(event_time, Timex.today()) do
      -1 -> "timeline-item-past"
      0 -> "timeline-item-current"
      1 -> "timeline-item-future"
    end
  end

  def challenge_status(challenge) do
    challenge.status
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def champion_display(challenge) do
    case challenge.champion_name do
      nil ->
        nil

      _ ->
        content_tag :div, class: "mt-3" do
          [content_tag(:h5, "Champion Name"), content_tag(:p, challenge.champion_name)]
        end
    end
  end

  def neighborhood_display(challenge) do
    case challenge.neighborhood do
      nil ->
        nil

      _ ->
        content_tag :div, class: "mt-3" do
          [content_tag(:h5, "Location"), content_tag(:p, challenge.neighborhood)]
        end
    end
  end
end
