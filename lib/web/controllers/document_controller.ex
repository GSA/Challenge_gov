defmodule Web.DocumentController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.SupportingDocuments
  alias Web.ErrorView

  action_fallback(Web.FallbackController)

  def create(conn, %{"challenge_id" => challenge_id, "document" => params}) do
    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, document} <- SupportingDocuments.upload(challenge.user, params),
         {:ok, document} <-
           SupportingDocuments.attach_to_challenge(
             document,
             challenge,
             Map.get(params, "section"),
             Map.get(params, "name")
           ) do
      conn
      |> put_flash(:info, "Document uploaded and attached")
      |> redirect(to: Routes.challenge_path(conn, :show, document.challenge_id))
    end
  end

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

  def delete(conn, %{"id" => id}) do
    with {:ok, document} <- SupportingDocuments.get(id),
         {:ok, document} <- SupportingDocuments.delete(document) do
      conn
      |> put_flash(:info, "Document removed")
      |> redirect(to: Routes.challenge_path(conn, :show, document.challenge_id))
    end
  end
end
