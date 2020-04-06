defmodule Web.Admin.TermsController do
  use Web, :controller

  alias ChallengeGov.Accounts

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("index.html")
  end

  def create(conn, params) do
    %{current_user: user} = conn.assigns
    data = Map.get(params, "user")

    parsed_data =
      if Map.get(data, "agency_id") == nil do
        Map.put(
          data,
          "agency_id",
          nil
        )
      else
        Map.put(
          data,
          "agency_id",
          String.to_integer(Map.get(data, "agency_id"))
        )
      end

    if Map.get(parsed_data, "accept_terms_of_use") === "true" and
         Map.get(parsed_data, "accept_privacy_guidelines") === "true" do
      case Accounts.update_terms(user, parsed_data) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "Your account has been updated")
          |> redirect_based_on_user(user)

        {:error, changeset} ->
          conn
          |> put_flash(:error, "There was an issue updating your account")
          |> put_status(422)
          |> assign(:changeset, changeset)
          |> render("index.html")
      end
    else
      conn
      |> put_flash(
        :info,
        "We encountered a problem submitting your information. Please try again."
      )
      |> render("index.html")
    end
  end

  def redirect_based_on_user(conn, user) do
    case Accounts.is_pending?(user) do
      true ->
        redirect(conn, to: Routes.admin_terms_path(conn, :pending))

      false ->
        redirect(conn, to: Routes.admin_challenge_path(conn, :index))
    end
  end

  def pending(conn, _params) do
    conn
    |> render("pending.html")
  end
end
