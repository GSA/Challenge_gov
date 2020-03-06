defmodule Web.Api.PaginationView do
  use Web, :view

  def render("pagination.json", %{pagination: pagination, base_url: base_url}) do
    json = %{
      page: pagination.current,
      total: pagination.total
    }

    json
    |> maybe_next(pagination, base_url)
    |> maybe_prev(pagination, base_url)
  end

  defp maybe_next(json, pagination, base_url) do
    case pagination.current < pagination.total do
      true ->
        Map.put(json, :next, pagination_url(base_url, pagination.current + 1))

      false ->
        json
    end
  end

  defp maybe_prev(json, pagination, base_url) do
    case pagination.current > 1 && pagination.current <= pagination.total do
      true ->
        Map.put(json, :prev, pagination_url(base_url, pagination.current - 1))

      false ->
        json
    end
  end

  defp pagination_url(base_url, page) do
    uri = URI.parse(base_url)

    uri
    |> Map.put(:query, set_page(uri.query, page))
    |> URI.to_string()
  end

  defp set_page(nil, page), do: URI.encode_query(%{page: page})

  defp set_page(query, page) do
    query
    |> URI.decode_query()
    |> Map.put(:page, page)
    |> URI.encode_query()
  end
end
