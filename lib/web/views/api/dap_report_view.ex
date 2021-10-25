defmodule Web.Api.DapReportView do
  use Web, :view

  alias ChallengeGov.Reports.DapReports

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      filename: document.filename,
      url: DapReports.download_report_url(document)
    }
  end

  def render("delete.json", _) do
    %{}
  end
end
