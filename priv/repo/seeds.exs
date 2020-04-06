# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChallengeGov.Repo.insert!(%ChallengeGov.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChallengeGov.Accounts
alias ChallengeGov.Agencies

defmodule Helpers do
  def create_super_admin(nil, nil, nil) do
  end

  def create_super_admin(email, first_name, last_name) do
    case Accounts.get_by_email(email) do
      {:error, :not_found} ->
        Accounts.create(%{
          email: email,
          first_name: first_name,
          last_name: last_name,
          role: "super_admin",
          terms_of_use: DateTime.truncate(DateTime.utc_now(), :second),
          privacy_guidelines: DateTime.truncate(DateTime.utc_now(), :second),
          status: "active"
        })

      _ ->
        nil
    end
  end

  def create_agencies(file) do
    {:ok, binary} = File.read(file)
    agencies = String.split(binary, ",")

    Enum.each(agencies, fn agency ->
      case Agencies.get_by_name(agency) do
        {:error, :not_found} ->
          Agencies.create(%{
            name: agency
          })

        _ ->
          nil
      end
    end)
  end
end

defmodule Seeds do
  import Helpers

  def run do
    create_super_admin(
      System.get_env("FIRST_USER_EMAIL"),
      System.get_env("FIRST_USER_FN"),
      System.get_env("FIRST_USER_LN")
    )

    create_agencies("priv/repo/agencies.txt")
  end
end

Seeds.run()
