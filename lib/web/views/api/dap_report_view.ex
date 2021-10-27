defmodule Web.Api.DapReportView do
  use Web, :view

  alias ChallengeGov.Reports.DapReports

  def render("show.json", %{report: report}) do
    %{
      id: report.id,
      filename: report.filename,
      url: DapReports.download_report_url(report)
    }
  end

  def render("delete.json", _) do
    %{}
  end
end
