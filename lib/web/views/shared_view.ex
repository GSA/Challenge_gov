defmodule Web.SharedView do
  use Web, :view

  alias Web.SharedView

  def session_timeout(conn) do
    Map.get(conn.private.plug_session, "session_timeout_at")
  end

  def public_page_path(path, page, pagination_param \\ nil) do
    uri = URI.parse(path)

    query =
      if pagination_param do
        uri.query
        |> decode_query()
        |> Map.put("#{pagination_param}[page]", page)
        |> URI.encode_query()
      else
        uri.query
        |> decode_query()
        |> Map.put(:page, page)
        |> URI.encode_query()
      end

    %{uri | query: query}
    |> URI.to_string()
  end

  def decode_query(nil), do: %{}

  def decode_query(query) do
    URI.decode_query(query)
  end

  def previous_pagination(%{current: 1}), do: []

  def previous_pagination(%{current: current}) do
    1..(current - 1)
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.reverse()
  end

  def more_previous?(%{current: current}), do: current > 4

  def next_pagination(%{current: page, total: page}), do: []

  def next_pagination(%{current: current, total: total}) do
    (current + 1)..total
    |> Enum.take(3)
  end

  def more_next?(%{current: current, total: total}), do: total - current >= 4

  def pagination(opts) do
    pagination = opts[:pagination]
    opts = Keyword.put_new(opts, :pagination_param, nil)

    case pagination.total <= 1 do
      true ->
        []

      false ->
        render("_pagination.html", opts)
    end
  end

  def parse_markdown(value) do
    with false <- is_nil(value),
         {:ok, markdown, _} <- Earmark.as_html(value) do
      raw(markdown)
    else
      _ ->
        value
    end
  end

  def readable_date(date) do
    if date do
      Timex.format!(date, "{0M}/{0D}/{YYYY}")
    end
  end

  def readable_datetime(datetime) do
    if datetime do
      Timex.format!(datetime, "{0M}/{0D}/{YYYY} {h12}:{0m} {AM} {Zname}")
    end
  end

  def naive_to_readable_datetime(naive_datetime) do
    naive_datetime
    |> Timex.to_datetime()
    |> readable_datetime
  end

  def string_to_link(string, opts \\ []) do
    link(string, Keyword.merge([to: string], opts))
  end

  def render_safe_html(html) do
    html
    |> HtmlSanitizeEx.basic_html()
    |> raw
  end
end
