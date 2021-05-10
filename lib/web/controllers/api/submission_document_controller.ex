defmodule Web.Api.SubmissionDocumentController do
  use Web, :controller

  alias ChallengeGov.SubmissionDocuments
  alias Web.ErrorView
  alias ChallengeGov.Accounts
  alias ChallengeGov.Submissions

  def create(conn, %{"document" => _params, "solver_email" => ""}) do
    {:error, changeset} =
      Submissions.new()
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.add_error(:solver_addr, "must add solver email first")
      |> Ecto.Changeset.apply_action(:insert)

    conn
    |> assign(:changeset, changeset)
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("errors.json")
  end

  def create(conn, %{"document" => params, "solver_email" => solver_email}) do
    with {:ok, user} <- Accounts.get_by_email(solver_email),
         {:ok, document} <- SubmissionDocuments.upload(user, params) do
      conn
      |> assign(:document, document)
      |> put_status(:created)
      |> render("show.json")
    else
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")

      {:error, :not_found} ->
        {:error, changeset} =
          Submissions.new()
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.add_error(:solver_addr, "user not found")
          |> Ecto.Changeset.apply_action(:insert)

        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, document} <- SubmissionDocuments.get(id),
         {:ok, _document} <- SubmissionDocuments.delete(document) do
      conn
      |> put_status(:ok)
      |> render("delete.json")
    end
  end
end
