defmodule Seeds.SeedModules.Agencies do
  NimbleCSV.define(ChallengeGov.CSVParser, separator: ",", escape: "\"")

  alias ChallengeGov.Agencies
  alias ChallengeGov.CSVParser

  def run() do
    IO.inspect "Seeding Agencies"

    import_agencies_csv("priv/repo/agencies_updated.csv")
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
    case Agencies.get_by_name(name) do
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
end
