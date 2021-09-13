defmodule Web.Api.DocumentController do
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
      |> put_status(:ok)
      |> assign(:document, document)
      |> render("show.json")
    else
      _error ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, document} <- SupportingDocuments.get(id),
         {:ok, _document} <- SupportingDocuments.delete(document) do
      conn
      |> put_status(:ok)
      |> render("delete.json")
    end
  end
end
