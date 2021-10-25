defmodule ChallengeGov.Reports.DapReports do
  @moduledoc """
  Context for creating a report
  """

  import Ecto.Query

  alias ChallengeGov.Repo
  alias ChallengeGov.Reports.DapReport
  alias Stein.Storage

  @doc """
  Get a dap report
  """
  def get_dap_report(id) do
    case Repo.get(DapReport, id) do
      nil ->
        {:error, :not_found}

      document ->
        {:ok, document}
    end
  end

  def all_last_six_months() do
    last_six_months = Timex.shift(DateTime.utc_now(), months: -6)

    DapReport
    |> where([r], r.inserted_at > ^last_six_months)
    |> order_by([r], desc: r.inserted_at, desc: r.id)
    |> Repo.all()
  end

  @doc """
  Upload a new DAP report
  """
  def upload_dap_report(user, %{"file" => file, "name" => name}) do
    file = Storage.prep_file(file)
    key = UUID.uuid4()
    path = dap_report_path(key, file.extension)

    meta = [
      {:content_disposition, ~s{attachment; filename="#{file.filename}"}}
    ]

    allowed_extensions = [".pdf", ".txt", ".csv", ".jpg", ".png", ".tiff"]

    case Storage.upload(file, path, meta: meta, extensions: allowed_extensions) do
      :ok ->
        %DapReport{}
        |> DapReport.create_changeset(file, key, name)
        |> Repo.insert()

      {:error, _reason} ->
        user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:file, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  @doc """
  Delete a DAP report

  Also removes the file from remote storage
  """
  def delete_report(file) do
    case Storage.delete(dap_report_path(file)) do
      :ok ->
        Repo.delete(file)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a signed URL to view the report
  """
  def download_report_url(file) do
    Storage.url(dap_report_path(file.key, file.extension), signed: [expires_in: 3600])
  end

  @doc """
  Get the storage path for a report
  """
  def dap_report_path(key, extension), do: "/dap_reports/#{key}#{extension}"

  def dap_report_path(file = %DapReport{}) do
    dap_report_path(file.key, file.extension)
  end
end
