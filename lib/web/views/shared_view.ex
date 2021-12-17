defmodule Web.SharedView do
  use Web, :view

  alias Stein.Storage
  alias Web.SharedView

  def session_timeout(conn) do
    Plug.Conn.get_session(conn, "session_timeout_at")
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

  def pagination_post(opts) do
    pagination = opts[:pagination]
    opts = Keyword.put_new(opts, :pagination_param, nil)

    case pagination.total <= 1 do
      true ->
        []

      false ->
        render("_pagination_post.html", opts)
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

  def mailto_link(email) do
    link(email, to: "mailto:#{email}")
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

  def local_datetime_tag(datetime, tag_type \\ "div") do
    content_tag(tag_type, datetime, class: "js-local-datetime")
  end

  def string_to_link(string, opts \\ []) do
    link(string, Keyword.merge([to: string], opts))
  end

  def render_safe_html(html) do
    html
    |> HtmlSanitizeEx.basic_html()
    |> raw
  end

  def upload_url(path) do
    Storage.url(path, signed: [expires_in: 3600])
  end

  def render_breadcrumbs(breadcrumbs) do
    content_tag :div, class: "row mb-2" do
      content_tag :div, class: "col" do
        maybe_truncate_breadcrumbs(breadcrumbs)
      end
    end
  end

  def maybe_truncate_breadcrumbs(breadcrumbs) do
    visible_breadcrumbs =
      Enum.filter(breadcrumbs, fn breadcrumb ->
        !Map.has_key?(breadcrumb, :is_visible) or !!breadcrumb.is_visible
      end)

    {first, last_two} = Enum.split(visible_breadcrumbs, -2)

    breadcrumbs = if length(visible_breadcrumbs) > 2, do: last_two, else: breadcrumbs

    {:ok, data} = Jason.encode(first)

    breadcrumb_display =
      if length(visible_breadcrumbs) > 2 do
        [
          content_tag(:span, "", class: "truncated-breadcrumbs", "data-breadcrumbs": data),
          content_tag :li, class: "breadcrumb-item btn-link" do
            content_tag(:a, "...", href: "", class: "hidden-breadcrumbs")
          end,
          get_breadcrumb_html(breadcrumbs)
        ]
      else
        get_breadcrumb_html(breadcrumbs)
      end

    content_tag :ol, class: "breadcrumb" do
      breadcrumb_display
    end
  end

  def get_breadcrumb_html(breadcrumbs) do
    Enum.map(breadcrumbs, fn breadcrumb ->
      text = Map.get(breadcrumb, :text)
      route = Map.get(breadcrumb, :route, nil)
      is_visible = Map.get(breadcrumb, :is_visible, true)

      if is_visible do
        content_tag :li, class: "breadcrumb-item #{if is_nil(route), do: 'active'}" do
          content_tag(:a, text, href: route)
        end
      else
        []
      end
    end)
  end
end
