defmodule Web.Public.SitemapView do
  use Web, :view

  import XmlBuilder

  alias Web.ChallengeView

  def render("rss.xml", %{challenges: challenges}) do
    challenges_xml =
      Enum.reduce(challenges, [], fn challenge, xml ->
        [challenge_xml(challenge) | xml]
      end)

    challenges_xml
    |> base_rss()
    |> generate()
  end

  defp challenge_xml(challenge) do
    element(:item,
      title: challenge.title,
      link: ChallengeView.public_details_url(challenge),
      description:
        Enum.join(
          [
            challenge.brief_description,
            challenge.description
          ],
          " "
        ),
      pubDate: format_pub_date(challenge.updated_at),
      guid: ChallengeView.public_details_url(challenge)
    )
  end

  defp base_rss(content) do
    element(
      :rss,
      %{version: "2.0"},
      rss_channel(
        "Challenge.gov challenges",
        "Public and archived Challenge.gov challenges",
        ChallengeView.public_index_url(),
        content
      )
    )
  end

  defp rss_channel(title, description, link, content, _opts \\ []) do
    [
      element(:channel, [
        [
          element(title: title),
          element(description: description),
          element(link: link)
        ]
        | content
      ])
    ]
  end

  defp format_pub_date(naive_datetime) do
    naive_datetime
    |> Timex.to_datetime()
    |> Timex.format!("{RFC822}")
  end
end
