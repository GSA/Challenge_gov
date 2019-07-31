defmodule Web.ChallengeView do
  use Web, :view

  alias IdeaPortal.Challenges
  alias IdeaPortal.Recaptcha
  alias IdeaPortal.SupportingDocuments
  alias Web.FormView
  alias Web.SharedView

  def disqus_domain() do
    Application.get_env(:idea_portal, :disqus_domain)
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
