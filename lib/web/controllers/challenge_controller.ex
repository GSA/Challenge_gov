defmodule Web.ChallengeController do
  use Web, :controller
  use Phoenix.HTML

  alias ChallengeGov.Challenges
  alias ChallengeGov.Security
  alias ChallengeGov.SiteContent

  plug(Web.Plugs.FetchPage when action in [:index])

  plug(
    Web.Plugs.EnsureRole,
    [:super_admin, :admin, :challenge_manager]
  )

  action_fallback(Web.FallbackController)

  def index(conn = %{assigns: %{current_user: user}}, params) do
    pending_page = String.to_integer(params["pending"]["page"] || "1")
    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    pending_challenges =
      Challenges.all_pending_for_user(user, filter: %{}, sort: %{}, page: pending_page, per: 5)

    challenges =
      user
      |> Challenges.all_for_user(filter: filter, sort: sort)
      |> aggregate_challenges_by_type()

    render(conn, "index.html",
      user: user,
      pending_challenges: pending_challenges.page,
      pending_pagination: pending_challenges.pagination,
      challenges: challenges,
      filter: filter,
      sort: sort
    )
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      Challenges.add_to_security_log(user, challenge, "read", Security.extract_remote_ip(conn))

      render(conn, "show.html",
        user: user,
        challenge: challenge,
        events: challenge.events,
        supporting_documents: challenge.supporting_documents
      )
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to view this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def new(conn, %{"non_wizard" => "true"}) do
    %{current_user: user} = conn.assigns

    render(conn, "new.html",
      user: user,
      action: action_name(conn),
      changeset: Challenges.new(user)
    )
  end

  def new(conn, params) do
    %{current_user: user} = conn.assigns

    show_info = Map.get(params, "show_info", false)
    {:ok, wizard_info} = SiteContent.get("challenge_wizard_info")

    render(conn, "wizard.html",
      user: user,
      changeset: Challenges.new(user),
      path: Routes.challenge_path(conn, :create),
      action: action_name(conn),
      section: "general",
      show_info: show_info,
      wizard_info: wizard_info,
      challenge: nil
    )
  end

  def create(
        conn = %{assigns: %{current_user: user}},
        params = %{"action" => action, "challenge" => %{"section" => section}}
      ) do
    case Challenges.create(params, user, Security.extract_remote_ip(conn)) do
      {:ok, challenge} ->
        if action == "save" do
          conn
          |> put_flash(:info, "Challenge saved")
          |> redirect(to: Routes.challenge_path(conn, :edit, challenge.id, section))
        else
          conn
          |> redirect(
            to:
              Routes.challenge_path(
                conn,
                :edit,
                challenge.id,
                Challenges.next_section(section).id
              )
          )
        end

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("wizard.html",
          user: user,
          path: Routes.challenge_path(conn, :create),
          action: action_name(conn),
          section: section,
          changeset: changeset,
          challenge: nil,
          show_info: false
        )
    end
  end

  def create(conn, %{"challenge" => params}) do
    %{current_user: user} = conn.assigns

    case Challenges.old_create(user, params, Security.extract_remote_ip(conn)) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge created!")
        |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:action, action_name(conn))
        |> assign(:changeset, changeset)
        |> put_flash(:error, "An error occured")
        |> put_status(422)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id, "section" => section}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:challenge, challenge)
      |> maybe_reset_challenge_status(user, challenge)
      |> assign(:user, user)
      |> assign(:path, Routes.challenge_path(conn, :update, id))
      |> assign(:action, action_name(conn))
      |> assign(:show_info, false)
      |> assign(:section, section)
      |> assign(:changeset, Challenges.edit(challenge))
      |> render("wizard.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def update(
        conn,
        params = %{"id" => id, "action" => action, "challenge" => %{"section" => section}}
      ) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(id)
    to_section = Challenges.to_section(section, action)

    with {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, challenge} <-
           Challenges.update(challenge, params, user, Security.extract_remote_ip(conn)) do
      case action do
        "save_draft" ->
          conn
          |> put_flash(:info, "Challenge saved as draft")
          |> redirect(to: Routes.challenge_path(conn, :edit, challenge.id, section))

        "save" ->
          conn
          |> put_flash(:info, "Changes saved")
          |> maybe_put_flash_subscriber_update(challenge)
          |> redirect(to: Routes.challenge_path(conn, :edit, challenge.id, section))

        "submit" ->
          conn
          |> put_flash(
            :info,
            [
              "Your challenge was submitted on ",
              Phoenix.HTML.Tag.content_tag(:span, "", class: "js-current-local-date"),
              " at ",
              Phoenix.HTML.Tag.content_tag(:span, "", class: "js-current-local-time"),
              ". Next, a GSA Admin will review your challenge to approve or post comments with questions for you to respond to before publishing. If you have any questions or concerns, please contact a GSA Admin (",
              Phoenix.HTML.Tag.content_tag(:a, "team@challenge.gov",
                href: "mailto: team@challenge.gov",
                target: "_blank"
              ),
              ") with your question and Challenge ID number #{challenge.id}."
            ]
          )
          |> maybe_put_flash_subscriber_update(challenge)
          |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))

        _ ->
          if to_section do
            redirect(conn, to: Routes.challenge_path(conn, :edit, challenge.id, to_section.id))
          else
            redirect(conn, to: Routes.challenge_path(conn, :index))
          end
      end
    else
      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:path, Routes.challenge_path(conn, :update, id))
        |> assign(:action, action_name(conn))
        |> assign(:section, section)
        |> assign(:changeset, changeset)
        |> assign(:show_info, false)
        |> put_flash(:error, "An error occured")
        |> render("wizard.html")

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "challenge" => params}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(id)

    with {:ok, challenge} <-
           Challenges.update(challenge, params, user, Security.extract_remote_ip(conn)),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> put_flash(:info, "Challenge updated!")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    else
      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:action, action_name(conn))
        |> assign(:challenge, challenge)
        |> assign(:changeset, changeset)
        |> put_flash(:error, "An error occured")
        |> render("edit.html")

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(id)

    case Challenges.delete(challenge, user, Security.extract_remote_ip(conn)) do
      {:ok, _challenge} ->
        conn
        |> put_flash(:info, "Challenge deleted")
        |> redirect(to: Routes.challenge_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Something went wrong")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def approve(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.approve(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge approved")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def publish(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.publish(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge published")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def unpublish(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <-
           Challenges.unpublish(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge unpublished")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def reject(conn, params = %{"id" => id}) do
    %{current_user: user} = conn.assigns
    message = Map.get(params, "rejection_message")

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <-
           Challenges.reject(challenge, user, Security.extract_remote_ip(conn), message) do
      conn
      |> put_flash(:info, "Challenge rejected")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def submit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.submit(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge submitted")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Please check that all steps have been filled out correctly")
        |> redirect(to: Routes.challenge_path(conn, :show, id))
    end
  end

  def archive(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.archive(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge archived")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def unarchive(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <-
           Challenges.unarchive(challenge, user, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Challenge unarchived")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def create_announcement(conn, %{"id" => id, "announcement" => announcement}) do
    with {id, _} <- Integer.parse(id),
         {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.create_announcement(challenge, announcement) do
      conn
      |> put_flash(:info, "Challenge announcement posted")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Something went wrong")
        |> redirect(to: Routes.challenge_path(conn, :show, id))
    end
  end

  def remove_announcement(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_announcement(challenge) do
      conn
      |> put_flash(:info, "Challenge announcement removed")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Something went wrong")
        |> redirect(to: Routes.challenge_path(conn, :show, id))
    end
  end

  def remove_logo(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_logo(challenge) do
      conn
      |> put_flash(:info, "Logo removed")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def remove_winner_image(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_winner_image(challenge) do
      conn
      |> put_flash(:info, "Winner image removed")
      |> redirect(to: Routes.challenge_path(conn, :show, challenge.id))
    end
  end

  def remove_resource_banner(conn, %{"id" => id, "section" => section}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_resource_banner(challenge) do
      conn
      |> put_flash(:info, "Resource banner removed")
      |> redirect(to: Routes.challenge_path(conn, :edit, challenge.id, section))
    end
  end

  defp maybe_reset_challenge_status(
         conn,
         user,
         challenge = %{status: "gsa_review"}
       ) do
    remote_ip = Security.extract_remote_ip(conn)
    {:ok, challenge} = Challenges.set_statuses(user, challenge, "draft", nil, remote_ip)

    conn
    |> put_flash(:warning, [
      content_tag(:p, "Challenge Removed from Queue", class: "h4 mb-0"),
      content_tag(
        :p,
        "Once edits are made you will need to resubmit this challenge for GSA approval"
      )
    ])
    |> assign(:challenge, challenge)
  end

  defp maybe_reset_challenge_status(conn, _user, _challenge), do: conn

  defp maybe_put_flash_subscriber_update(conn, challenge) do
    case challenge.status do
      "published" ->
        conn
        |> put_flash(:info, [
          content_tag(:p, "Challenge updated", class: "h4 mb-0"),
          content_tag(
            :p,
            [
              "Please share critical updates with Solvers that have saved this challenge ",
              link("Govdelivery", to: Routes.challenge_bulletin_path(conn, :new, challenge.id))
            ]
          )
        ])

      _ ->
        conn
    end
  end

  defp aggregate_challenges_by_type(challenges) do
    accumulator = %{published: [], draft: [], archived: []}

    Enum.reduce(challenges, accumulator, fn challenge, acc ->
      cond do
        challenge.status in ["approved", "published"] and challenge.sub_status in ["open", nil] ->
          Map.put(acc, :published, [challenge | acc.published])

        challenge.status in ["draft", "gsa_review", "edits_requested", "unpublished"] ->
          Map.put(acc, :draft, [challenge | acc.draft])

        challenge.status == "published" and challenge.sub_status in ["closed", "archived"] ->
          Map.put(acc, :archived, [challenge | acc.archived])

        challenge.status == "archived" ->
          Map.put(acc, :archived, [challenge | acc.archived])

        true ->
          acc
      end
    end)
  end
end
