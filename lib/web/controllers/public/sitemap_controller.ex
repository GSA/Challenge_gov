defmodule Web.Public.SitemapController do
  use Web, :controller

  alias ChallengeGov.Challenges

  def rss(conn, _params) do
    conn
    |> assign(:challenges, Challenges.all_for_sitemap())
    |> render("rss.xml")
  end
end
