defmodule Web.Admin.DocumentController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.SupportingDocuments

  action_fallback(Web.Admin.FallbackController)

  def create(conn, %{"challenge_id" => challenge_id, "document" => params}) do
    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, document} <- SupportingDocuments.upload(challenge.user, params),
         {:ok, document} <- SupportingDocuments.attach_to_challenge(document, challenge) do
      conn
      |> put_flash(:info, "Document uploaded and attached")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, document.challenge_id))
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, document} <- SupportingDocuments.get(id),
         {:ok, document} <- SupportingDocuments.delete(document) do
      conn
      |> put_flash(:info, "Document removed")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, document.challenge_id))
    end
  end
end
