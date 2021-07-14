defmodule Web.Public.PageController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Logo
  alias Stein.Storage

  def index(conn, params) do
    case Map.has_key?(params, "id") do
      true ->
        %{"id" => id} = params
        {:ok, challenge} = Challenges.get(id)

        challenge_image = get_open_graph_image(challenge)

        conn
        |> assign(:og_title, challenge.title)
        |> assign(:og_description, HtmlSanitizeEx.strip_tags(challenge.brief_description))
        |> assign(:og_image, challenge_image)
        |> render("index.html")

      false ->
        conn
        |> render("index.html")
    end
  end

  defp get_open_graph_image(challenge) do
    if challenge.upload_logo do
      custom_image_path =
        Storage.url(Logo.logo_path(challenge, "original"), signed: [expires_in: 3600])

      Routes.static_url(Web.Endpoint, custom_image_path)
    else
      Routes.static_url(Web.Endpoint, "/images/challenge-logo-2_1.svg")
    end
  end
end
