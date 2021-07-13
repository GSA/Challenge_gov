defmodule Web.Plugs.SiteWideBanner do
  @moduledoc """
  Check for site wide banner and apply
  """

  import Plug.Conn

  alias ChallengeGov.SiteContent

  def init(default), do: default

  def call(conn, _opts) do
    {:ok, banner_content} = SiteContent.get("site_wide_banner")
    case is_nil(banner_content.content) do
      false ->
        IO.puts "RIGHT HERE - got one"
        IO.inspect(banner_content, label: "RIGHT HERE - banner_content")
        assign(conn, :site_wide_banner, banner_content)

      true ->
        IO.puts "RIGHT HERE - nop"
        conn
    end
  end
end
