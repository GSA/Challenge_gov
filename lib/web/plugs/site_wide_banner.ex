defmodule Web.Plugs.SiteWideBanner do
  @moduledoc """
  Check for site wide banner and apply if currently active
  """

  import Plug.Conn

  alias ChallengeGov.SiteContent

  def init(default), do: default

  def call(conn, _opts) do
    {:ok, banner} = SiteContent.get("site_wide_banner")

    case banner_is_active?(banner) do
      true ->
        assign(conn, :site_wide_banner, banner)

      false ->
        conn
    end
  end

  defp banner_is_active?(banner) do
    now = DateTime.utc_now()

    if is_nil(banner.start_date) or is_nil(banner.end_date) do
      false
    else
      !is_nil(banner.content) and
        DateTime.compare(now, banner.start_date) === :gt and
        DateTime.compare(now, banner.end_date) === :lt
    end
  end
end
