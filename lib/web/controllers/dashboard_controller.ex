defmodule Web.DashboardController do
  use Web, :controller
  use Phoenix.HTML

  alias ChallengeGov.Submissions
  alias Web.Endpoint

  def index(conn, _params) do
    %{current_user: user} = conn.assigns
    # redirect(conn, to: Routes.challenge_path(conn, :index))

    # if current solver user is has submissions created for them
    # which need to be verified, include notification.
    submissions =
      if user.role == "solver" do
        Submissions.all_unreviewed_by_submitter_id(user.id)
      else
        []
      end

    conn =
      conn
      |> assign(:user, user)
      |> assign(:filter, nil)
      |> assign(:sort, nil)

    conn =
      if Enum.count(submissions) > 0 do
        submission = submissions |> Enum.at(0)

        conn
        |> put_flash(:info, [
          content_tag(:span, "New submission to review", class: "h3"),
          content_tag(:br, ""),
          "A new submission has been created for you. You must review and verify the submission by clicking ",
          link("here",
            to:
              Routes.submission_path(
                Endpoint,
                :edit,
                submission.id
              )
          ),
          ". Or view all submissions that need review at the top of My Submissions."
        ])
      else
        conn
      end

    conn
    |> render("index.html")
  end
end
