defmodule Web.Admin.TermsController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.SecurityLogs.SecurityLog

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("index.html")
  end

  def create(conn, params) do
    %{current_user: user} = conn.assigns
    %{role: user_role} = user
    %{"user" => user_params} = params

    updated_params =
      case user_role == "challenge_owner" do
        true ->
          %{"user" => %{"agency_id" => agency_id}} = params
          Map.put(user_params, "agency_id", String.to_integer(agency_id))

        false ->
          Map.merge(user_params, %{"agency_id" => nil, "status" => "active"})
      end

    if Map.get(updated_params, "accept_terms_of_use") == "true" and
         Map.get(updated_params, "accept_privacy_guidelines") == "true" do
      case Accounts.update_terms(user, updated_params) do
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
    redirect_route =
      if Accounts.is_pending?(user),
        do: Routes.admin_terms_path(conn, :pending),
        else: Routes.admin_dashboard_path(conn, :index)

    SecurityLogs.track(%SecurityLog{}, %{
      originator_id: user.id,
      originator_role: user.role,
      originator_identifier: user.email,
      originator_remote_ip: to_string(:inet_parse.ntoa(conn.remote_ip)),
      action: "accessed_site"
    })

    redirect(conn, to: redirect_route)
  end

  def pending(conn, _params) do
    conn
    |> render("pending.html")
  end
end
