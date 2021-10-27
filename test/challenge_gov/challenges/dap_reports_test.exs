defmodule ChallengeGov.DapReportsTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.Reports.DapReports

  describe "uploading reports" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})

      {:ok, report} =
        DapReports.upload_dap_report(conn, user, %{
          "file" => %{path: "test/fixtures/test.pdf"},
          "name" => "Test File Name"
        })

      assert report.extension == ".pdf"
      assert report.key
      assert report.filename === "Test File Name.pdf"
    end
  end

  describe "deleting a report" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})

      {:ok, report} =
        DapReports.upload_dap_report(conn, user, %{
          "file" => %{path: "test/fixtures/test.pdf"},
          "name" => "Test File Name"
        })

      {:ok, report} = DapReports.delete_report(report)

      report = DapReports.get_dap_report(report.id)

      assert report == {:error, :not_found}
    end
  end
end
