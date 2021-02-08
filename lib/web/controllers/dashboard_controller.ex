defmodule Web.DashboardController do
  use Web, :controller
  use Phoenix.HTML

  alias ChallengeGov.Solutions
  alias Web.Endpoint

  def index(conn, _params) do
    %{current_user: user} = conn.assigns
    # redirect(conn, to: Routes.challenge_path(conn, :index))

    # if current user is solver with submissions
    # which are drafts w/ manager ID, include notification.
    solutions = if user.role == "solver" do
      Solutions.get_all_with_user_id_and_manager(user)
    else
      []
    end

    IO.inspect("GETTING ALL")
    
    conn = conn
    |> assign(:user, user)
    |> assign(:filter, nil)
    |> assign(:sort, nil)

    conn = if Enum.count(solutions) > 0 do
      solution = solutions |> Enum.at(0)
      conn
      |> put_flash(:info, ["A new submission has been created for you. You must review the submission by clicking ", link("here", to: Routes.challenge_phase_solution_url(Endpoint, :show, solution.challenge_id, solution.phase_id, solution.id)), " or by navigating to My submissions and clicking Accept entry for this challenge."])
    else
      conn
    end

    conn
    |> render("index.html")
  end
end
