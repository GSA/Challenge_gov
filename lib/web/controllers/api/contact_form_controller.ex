defmodule Web.Api.ContactFormController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.ContactForms
  alias Web.ErrorView

  def send_email(conn, params = %{"challenge_id" => challenge_id}) do
    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, _changeset} <- ContactForms.send_email(challenge, params) do
      conn
      |> put_status(:ok)
      |> render("success.json")
    else
      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("errors.json")
    end
  end
end
