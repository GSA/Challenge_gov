defmodule Web.Api.DapReportController do
  use Web, :controller

  alias ChallengeGov.Reports.DapReports
  alias Web.ErrorView

  action_fallback(Web.FallbackController)
  plug(Web.Plugs.EnsureRole, [:admin, :super_admin])

  def create(conn, %{"document" => params}) do
    %{current_user: user} = conn.assigns

    case DapReports.upload_dap_report(conn, user, params) do
      {:ok, report} ->
        conn
        |> assign(:report, report)
        |> put_status(:created)
        |> render("show.json")

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, file} <- DapReports.get_dap_report(id),
         {:ok, _file} <- DapReports.delete_report(file) do
      conn
      |> put_status(:ok)
      |> render("delete.json")
    end
  end
end
