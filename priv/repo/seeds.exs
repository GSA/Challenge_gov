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

NimbleCSV.define(ChallengeGov.CSVParser, separator: ",", escape: "\"")

alias ChallengeGov.Accounts
alias ChallengeGov.Agencies
alias ChallengeGov.CertificationLogs
alias ChallengeGov.Challenges.Challenge
alias ChallengeGov.CSVParser
alias ChallengeGov.Repo

defmodule Helpers do
  def create_super_admin(nil, nil, nil) do
  end

  def create_super_admin(email, first_name, last_name) do
    case Accounts.get_by_email(email) do
      {:error, :not_found} ->
        Accounts.system_create(%{
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

  def create_user_certifications do
    Enum.map(Accounts.all_for_select(), fn x ->
      case CertificationLogs.check_user_certification_history(x) do
        {:error, :no_log_found} ->
          CertificationLogs.track(%{
            user_id: x.id,
            user_role: x.role,
            user_identifier: x.email,
            certified_at: Timex.now(),
            expires_at: CertificationLogs.calulate_expiry()
          })

        {:ok, _result} ->
          nil
      end
    end)
  end

  def import_agencies_api(url) do
    {:ok, %{body: body, status: 200}} = Finch.build(:get, url) |> Finch.request(HTTPClient)
    data = Jason.decode!(body)
    count = data["metadata"]["count"]

    {:ok, %{body: body, status: 200}} =
      Finch.build(:get, url <> "?page_size=#{count}") |> Finch.request(HTTPClient)

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

    IO.puts("Inserted #{num_inserted} agencies")
  end

  def import_agencies_csv(file) do
    Mix.Task.run("app.start")

    {:ok, binary} = File.read(file)
    parsed = CSVParser.parse_string(binary)

    Enum.map(parsed, fn row ->
      [acronym, top_agency_name, sub_agency_name] = row

      {:ok, top_agency} = maybe_import_agency(top_agency_name, acronym)
      maybe_import_agency(sub_agency_name, acronym, top_agency)
    end)
  end

  defp maybe_import_agency(name, acronym) when name !== "" do
    case Agencies.get_by_name(name) do
      {:error, :not_found} ->
        IO.puts("Imported #{name}")

        Agencies.create(%{
          acronym: acronym,
          name: name
        })

      {:ok, agency} ->
        {:ok, agency}
    end
  end

  defp maybe_import_agency(name, acronym, parent_agency)
       when name !== "" and not is_nil(parent_agency) do
    case Agencies.get_by_name(name, parent_agency) do
      {:error, :not_found} ->
        IO.puts("Imported #{name}")

        Agencies.create(%{
          parent_id: parent_agency.id,
          acronym: acronym,
          name: name
        })

      {:ok, agency} ->
        {:ok, agency}
    end
  end

  defp maybe_import_agency(name, acronym, parent_agency), do: {:error, :no_name}

  def set_initial_challenge_uuids do
    Challenge
    |> Repo.all()
    |> Enum.map(fn challenge ->
      if is_nil(challenge.uuid) do
        challenge
        |> Ecto.Changeset.change(%{uuid: Ecto.UUID.generate()})
        |> Repo.update()
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

    # create_agencies("priv/repo/agencies.txt")
    create_user_certifications()
    # create_admin("admin@example.com")
    # create_agencies("priv/repo/agencies.txt")
    import_agencies_csv("priv/repo/agencies_updated.csv")

    # import_agencies_api("https://usagov.platform.gsa.gov/usaapi/api/v1/usagov/directory_records/federal.json")
    set_initial_challenge_uuids()
  end
end

Seeds.run()
