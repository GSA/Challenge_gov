defmodule Web.TermsController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs

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
      case user_role == "challenge_manager" do
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
          |> add_to_security_log(user, "account_update", %{
            terms_of_use: true,
            privacy_guidelines: true,
            first_name: user.first_name,
            last_name: user.last_name
          })
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
    conn
    |> add_to_security_log(user, "accessed_site")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  def pending(conn, _params) do
    conn
    |> render("pending.html")
  end

  defp add_to_security_log(conn, user, action, details \\ nil) do
    SecurityLogs.track(%{
      originator_id: user.id,
      originator_role: user.role,
      originator_identifier: user.email,
      originator_remote_ip: Security.extract_remote_ip(conn),
      action: action,
      details: details
    })

    conn
  end
end
