defmodule Web.Plugs.FetchSubmission do
  @moduledoc """
  Fetches a submission and assigns it to the conn.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias ChallengeGov.Submissions
  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, opts) do
    redirect_route = Keyword.get(opts, :redirect, Routes.dashboard_path(conn, :index))

    case Submissions.get(conn.params["id"]) do
      {:ok, submission} ->
        assign(conn, :current_submission, submission)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Submission not found")
        |> redirect(to: redirect_route)
        |> halt()
    end
  end
end
