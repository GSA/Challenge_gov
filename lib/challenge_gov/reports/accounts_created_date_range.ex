defmodule ChallengeGov.Reports.AccountsCreatedDateRange do
  @moduledoc false
  import Ecto.Query

  # alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Accounts.User

  def execute(params) do
    %{
      "end_date" => end_date,
      "start_date" => start_date
    } = params

    s_date =
      start_date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Timex.to_datetime()

    e_date =
      end_date
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Timex.to_datetime()

    from(u in User)
    |> where([u], fragment("? BETWEEN ? AND ?", u.inserted_at, ^s_date, ^e_date))
    |> select([u], %{
      user_id: u.id,
      account_type: u.role,
      created_date: u.inserted_at,
      account_status: u.status,
      last_login: u.last_active,
      start_date: ^start_date,
      end_date: ^end_date
    })
    |> ChallengeGov.Repo.all()
    |> build_data_structure()
  end

  defp build_data_structure([]), do: %{}

  defp build_data_structure(active_published_challenge_data) do
    now = DateTime.utc_now()

    Enum.map(active_published_challenge_data, fn c ->
      %{
        user_id: c.user_id,
        account_type: c.account_type,
        created_date: c.created_date,
        account_status: c.account_status,
        last_login: c.last_login,
        start_date: c.start_date,
        end_date: c.end_date,
        current_timestamp: now
      }
    end)
  end
end
