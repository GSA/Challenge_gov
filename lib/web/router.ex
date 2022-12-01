defmodule Web.Router do
  use Web, :router

  pipeline :browser do
    plug :accepts, ["html", "pdf"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {Web.LayoutView, :root}
    plug Web.Plugs.FetchUser
    plug(Web.Plugs.SiteWideBanner)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug(Web.Plugs.FetchUser)
  end

  pipeline :public do
    plug(:put_layout, {Web.LayoutView, "public.html"})
  end

  # Session pipelines
  pipeline(:signed_in) do
    plug(Web.Plugs.VerifyUser)
    plug(Web.Plugs.SessionTimeout)
  end

  pipeline(:signed_out) do
    plug(Web.Plugs.VerifyNoUser)
  end

  pipeline(:signed_in_api) do
    plug(Web.Plugs.VerifyUser, for: :api)
    plug(Web.Plugs.SessionTimeout)
  end

  # Status pipelines
  pipeline(:valid_status) do
    plug(Web.Plugs.CheckUserStatus)
  end

  pipeline(:pending) do
    plug(Web.Plugs.VerifyPendingUser)
  end

  # Portal Routes
  scope "/", Web do
    pipe_through([:browser, :signed_out])

    resources("/sign-in", SessionController, only: [:new, :create], singleton: true)
    get("/auth/result", SessionController, :result)
  end

  scope "/", Web do
    pipe_through([:browser, :signed_in])

    resources("/sign-in", SessionController, only: [:delete], singleton: true)

    post("/recertification", AccessController, :request_recertification)
    get("/recertification", AccessController, :recertification)

    get("/reactivation", AccessController, :reactivation)
    post("/reactivation", AccessController, :request_reactivation)

    get("/access", AccessController, :index)
  end

  scope "/", Web do
    pipe_through([:browser, :signed_in, :pending])
    resources("/terms", TermsController, only: [:new, :create])

    get("/pending", TermsController, :pending)
  end

  scope "/", Web do
    pipe_through([:browser, :signed_in, :valid_status])

    get("/", DashboardController, :index)
    get("/certification_requested", AccessController, :index)

    get("/analytics", AnalyticsController, :index)

    resources("/challenges", ChallengeController) do
      resources("/documents", DocumentController, only: [:create])
      resources("/events", EventController, only: [:new, :create])
      resources("/bulletin", BulletinController, only: [:new, :create])

      post("/phases/:id", PhaseController, :show)

      resources("/phases", PhaseController, only: [:index, :show]) do
        get("/submissions/managed", SubmissionController, :managed_submissions,
          as: :managed_submission
        )

        resources("/submissions", SubmissionController, only: [:index, :show, :new, :create]) do
        end
      end

      resources("/submissions", SubmissionController, only: [:index, :new, :create])
      resources("/save_challenge", SavedChallengeController, only: [:new, :create])
    end

    get("/challenges/:id/edit/:section", ChallengeController, :edit, as: :challenge)

    post("/challenges/:id/approve", ChallengeController, :approve, as: :challenge)
    post("/challenges/:id/publish", ChallengeController, :publish, as: :challenge)
    post("/challenges/:id/unpublish", ChallengeController, :unpublish, as: :challenge)
    post("/challenges/:id/reject", ChallengeController, :reject, as: :challenge)
    post("/challenges/:id/submit", ChallengeController, :submit, as: :challenge)
    post("/challenges/:id/archive", ChallengeController, :archive, as: :challenge)
    post("/challenges/:id/unarchive", ChallengeController, :unarchive, as: :challenge)
    post("/challenges/:id/remove_logo", ChallengeController, :remove_logo, as: :challenge)

    # Winners
    get("/challenges/:challenge_id/winners", PhaseWinnerController, :index)

    resources("/phase/:phase_id/winners", PhaseWinnerController,
      except: [:new, :delete],
      singleton: true
    )

    post("/challenges/:id/remove_winner_image", ChallengeController, :remove_winner_image,
      as: :challenge
    )

    post("/challenges/:id/remove_resource_banner", ChallengeController, :remove_resource_banner,
      as: :challenge
    )

    post("/challenges/:id/create_announcement", ChallengeController, :create_announcement)
    post("/challenges/:id/remove_announcement", ChallengeController, :remove_announcement)

    resources("/challenges/:id/submissions/export", SubmissionExportController,
      only: [:index, :create]
    )

    resources("/phases/:phase_id/submission_invites", SubmissionInviteController,
      only: [:index, :show, :create]
    )

    post("/submission_invites/:id/accept", SubmissionInviteController, :accept)
    post("/submission_invites/:id/revoke", SubmissionInviteController, :revoke)

    post("/submission_exports/:id", SubmissionExportController, :restart)
    resources("/submission_exports", SubmissionExportController, only: [:delete])

    resources("/submissions", SubmissionController, only: [:index, :show, :edit, :update, :delete])

    put("/submissions/:id/submit", SubmissionController, :submit)

    resources("/documents", DocumentController, only: [:delete])
    resources("/events", EventController, only: [:edit, :update, :delete])

    resources("/saved_challenges", SavedChallengeController, only: [:index, :delete])

    get("/help", HelpController, :index)

    get("/solver_help", HelpController, :solver_index)

    get("/exports/challenges/:id/:format", ExportController, :export_challenge)

    get("/reports/security_log", ReportsController, :export_security_log)
    get("/reports/certification_log", ReportsController, :export_certification_log)

    # PMO new reports by AD
    get("/reports/pmo", ReportsController, :pmo_page)
    get("/reports/pmo/:id", ReportsController, :pmo_report_name)
    get("/reports", ReportsController, :new)

    resources("/agencies", AgencyController)
    get("/agencies/new/:id", AgencyController, :new)
    post("/agencies/:id/remove_logo", AgencyController, :remove_logo, as: :agency)

    post("/users/:id/toggle", UserController, :toggle, as: :user)
    resources("/users", UserController, only: [:index, :show, :edit, :update, :create])

    post("/users/:user_id/challenge/:challenge_id", UserController, :restore_challenge_access,
      as: :restore_challenge_access
    )

    get("/messages/drafts", MessageContextController, :drafts)
    post("/messages/bulk_message/new", MessageContextController, :bulk_new)
    post("/messages/bulk_message/:challenge_id", MessageContextController, :bulk_message)
    resources("/messages", MessageContextController, only: [:index, :show, :new, :create])

    post("/message_context_statuses/:id/mark_read", MessageContextStatusController, :mark_read)

    post(
      "/message_context_statuses/:id/mark_unread",
      MessageContextStatusController,
      :mark_unread
    )

    post("/message_context_statuses/:id/archive", MessageContextStatusController, :archive)
    post("/message_context_statuses/:id/unarchive", MessageContextStatusController, :unarchive)

    resources("/site_content", SiteContentController, [:index, :show, :edit, :update])
  end

  # API Routes
  scope "/api", Web.Api, as: :api do
    pipe_through([:api, :signed_in_api])

    resources("/documents", DocumentController, only: [:create, :delete])
    resources("/submission_documents", SubmissionDocumentController, only: [:create, :delete])
    resources("/dap_reports", DapReportController, only: [:create, :delete])

    put("/submissions/:id/:judging_status", SubmissionController, :update_judging_status)

    # Winners
    post(
      "/phase_winners/:id/upload_overview_image",
      PhaseWinnerController,
      :upload_overview_image
    )

    post("/phase_winners/:id/upload_winner_image", WinnerController, :upload_image)

    post("/session/renew", SessionController, :check_session_timeout)
    post("/session/logout", SessionController, :logout_user)
  end

  scope "/api", Web.Api, as: :api do
    pipe_through([:api])

    get("/agencies/:agency_id/sub_agencies", AgencyController, :sub_agencies)

    get("/challenges/preview/:uuid", ChallengeController, :preview)
    resources("/challenges", ChallengeController, only: [:index, :show])
    post("/challenges/:challenge_id/contact_form", ContactFormController, :send_email)

    post("/messages/:message_context_id", MessageController, :create)
    put("/messages/:message_context_id", MessageController, :create)
    post("/message_context_status/:id/star", MessageContextStatusController, :toggle_starred)

    get("/phase/:phase_id/winners", WinnerController, :phase_winners)
  end

  # Public Routes
  scope "/public", Web.Public, as: :public do
    pipe_through([:browser, :public])
    get("/rss.xml", SitemapController, :rss)

    get("/previews/challenges", PreviewController, :index)

    get("/", PageController, :index)
  end

  if Mix.env() == :dev || Mix.env() == :test do
    scope "/dev_accounts", Web, as: :dev_accounts do
      pipe_through([:browser, :signed_out])

      get("/", PageController, :dev_accounts)
      post("/sign_in", PageController, :dev_account_sign_in)
    end

    forward("/emails/sent", Bamboo.SentEmailViewerPlug)
  end
end
