defmodule Web.Api.SolutionDocumentController do
  use Web, :controller

  alias ChallengeGov.SolutionDocuments
  alias Web.ErrorView

  def create(conn, %{"document" => params}) do
    %{current_user: user} = conn.assigns

    case SolutionDocuments.upload(user, params) do
      {:ok, document} ->
        conn
        |> assign(:document, document)
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
    with {:ok, document} <- SolutionDocuments.get(id),
         {:ok, _document} <- SolutionDocuments.delete(document) do
      conn
      |> put_status(:ok)
      |> render("delete.json")
    end
  end
end
