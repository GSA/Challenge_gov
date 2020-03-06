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
alias ChallengeGov.Agencies.Agency
alias ChallengeGov.Repo

defmodule Helpers do
  def create_admin(email) do
    case Accounts.get_by_email(email) do
      {:error, :not_found} ->
        Accounts.create(%{
          email: email,
          password: "password",
          password_confirmation: "password",
          first_name: "Admin",
          last_name: "User",
          role: "admin",
          terms_of_user: nil,
          privacy_guidelines: nil,
          agency_id: nil,
          token: Ecto.UUID.generate()
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

  def import_agencies_api(url) do
    {:ok, %{body: body, status_code: 200}} = HTTPoison.get(url)
    data = Jason.decode!(body)
    count = data["metadata"]["count"]

    {:ok, %{body: body, status_code: 200}} = HTTPoison.get(url <> "?page_size=#{count}")
    data = Jason.decode!(body)

    num_inserted = 0
    agencies_to_insert = []

    Enum.each(data["results"], fn agency ->
      api_id = agency["id"]
      title = agency["title"]
      parent = Enum.at(agency["parent"], 0)
      parent_id = String.to_integer(parent["id"])

      case Agencies.get_by_name(title) do
        {:error, :not_found} ->
          agencies_to_insert ++
          [
            name: title,
            api_id: api_id,
            parent_id: parent_id
          ]

          IO.inspect agencies_to_insert
          # Agencies.create(%{
          #   name: title,
          #   api_id: api_id,
          #   parent_id: parent_id
          # })
          num_inserted = num_inserted + 1

        _ ->
          nil
      end
    end)

    IO.puts "Inserted #{num_inserted} agencies"
  end
end

defmodule Seeds do
  import Helpers

  def run do
    # create_admin("admin@example.com")
    # create_agencies("priv/repo/agencies.txt")
    import_agencies_api("https://usagov.platform.gsa.gov/usaapi/api/v1/usagov/directory_records/federal.json")
  end
end

Seeds.run()
