defmodule Web.Router do
  use Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Web.Plugs.FetchUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
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

    resources("/challenges", ChallengeController,
      only: [:index, :show, :new, :create, :edit, :update, :delete]
    ) do
      resources("/documents", DocumentController, only: [:create])

      resources("/events", EventController, only: [:new, :create])

      resources("/solutions", SolutionController, only: [:index, :new, :create])

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

    post("/challenges/:id/remove_winner_image", ChallengeController, :remove_winner_image,
      as: :challenge
    )

    post("/challenges/:id/remove_resource_banner", ChallengeController, :remove_resource_banner,
      as: :challenge
    )

    resources("/documents", DocumentController, only: [:delete])
    resources("/events", EventController, only: [:edit, :update, :delete])

    resources("/solutions", SolutionController, only: [:index, :show, :edit, :update, :delete])
    put("/solutions/:id/submit", SolutionController, :submit)

    resources("/saved_challenges", SavedChallengeController, only: [:index, :delete])

    get("/reports/security_log", ReportsController, :export_security_log)
    get("/reports/certification_log", ReportsController, :export_certification_log)
    get("/reports", ReportsController, :new)

    resources("/agencies", AgencyController)
    post("/agencies/:id/remove_logo", AgencyController, :remove_logo, as: :agency)

    post("/users/:id/toggle", UserController, :toggle, as: :user)
    resources("/users", UserController, only: [:index, :show, :edit, :update, :create])

    post("/users/:user_id/challenge/:challenge_id", UserController, :restore_challenge_access,
      as: :restore_challenge_access
    )
  end

  # API Routes
  scope "/api", Web.Api, as: :api do
    pipe_through([:api, :signed_in])

    resources("/documents", DocumentController, only: [:create, :delete])
    resources("/solution_documents", SolutionDocumentController, only: [:create, :delete])

    # TODO: This might make sense to move elsewhere
    post("/session/renew", SessionController, :check_session_timeout)
    post("/session/logout", SessionController, :logout_user)
  end

  scope "/api", Web.Api, as: :api do
    pipe_through([:api])

    get("/challenges/preview/:uuid", ChallengeController, :preview)
    resources("/challenges", ChallengeController, only: [:index, :show])
    post("/challenges/:challenge_id/contact_form", ContactFormController, :send_email)
  end

  # Public Routes
  scope "/public", Web.Public, as: :public do
    pipe_through([:browser, :public])
    get("/rss.xml", SitemapController, :rss)

    get("/previews/challenges/:challenge_uuid", PreviewController, :index)

    get("/", PageController, :index)
    get("/challenges", PageController, :index, as: :challenge_index)
    get("/challenge/:id", PageController, :index, as: :challenge_details)
  end

  if Mix.env() == :dev do
    forward("/emails/sent", Bamboo.SentEmailViewerPlug)
  end
end
