defmodule ChallengeGov.Repo do
  use Ecto.Repo,
    otp_app: :challenge_gov,
    adapter: Ecto.Adapters.Postgres

  alias Stein.Pagination

  def paginate(query, page, per) when is_integer(page) and is_integer(per) do
    Pagination.paginate(__MODULE__, query, %{page: page, per: per})
  end

  def paginate(query, _page, _per), do: __MODULE__.all(query)
end
