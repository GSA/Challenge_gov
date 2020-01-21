defmodule Web.DocumentController do
  use Web, :controller

  alias ChallengeGov.SupportingDocuments
  alias Web.ErrorView

  def create(conn, %{"document" => params}) do
    %{current_user: user} = conn.assigns

    case SupportingDocuments.upload(user, params) do
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
end
