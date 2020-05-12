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

  pipeline(:admin) do
    plug(Web.Plugs.VerifyAdmin)
  end

  pipeline(:user) do
    plug(Web.Plugs.VerifyUser)
  end

  pipeline(:pending) do
    plug(Web.Plugs.VerifyPendingUser)
    plug(Web.Plugs.SessionTimeout)
    plug(:put_layout, {Web.LayoutView, "admin.html"})
  end

  pipeline(:signed_in) do
    plug(Web.Plugs.CheckUserStatus)
    plug(Web.Plugs.SessionTimeout)
    plug(:put_layout, {Web.LayoutView, "admin.html"})
  end

  pipeline(:not_signed_in) do
    plug(Web.Plugs.VerifyNoUser)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug(Web.Plugs.FetchUser)
  end

  scope "/public", Web.Public, as: :public do
    get("/rss.xml", SitemapController, :rss)
  end

  scope "/admin", Web.Admin, as: :admin do
    pipe_through([:browser, :user, :pending])
    resources("/terms", TermsController, only: [:new, :create])

    get("/pending", TermsController, :pending)

    get("/reactivation", AccessController, :deactivated)
  end

  scope "/admin", Web.Admin, as: :admin do
    pipe_through([:browser, :user, :signed_in])

    get("/", DashboardController, :index)

    resources("/documents", DocumentController, only: [:delete])

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

    resources("/solutions", SolutionController, only: [:index, :show, :edit, :update, :delete])
    put("/solutions/:id/submit", SolutionController, :submit)

    resources("/saved_challenges", SavedChallengeController, only: [:index, :delete])
  end

  scope "/admin", Web.Admin, as: :admin do
    pipe_through([:browser, :admin, :signed_in])

    resources("/events", EventController, only: [:edit, :update, :delete])

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

    resources("/challenges", ChallengeController, only: [:index, :show])
    post("/challenges/:challenge_id/contact_form", ContactFormController, :send_email)
  end

  scope "/", Web do
    pipe_through([:browser, :user])

    resources("/sign-in", SessionController, only: [:delete], singleton: true)
  end

  scope "/", Web do
    pipe_through([:browser, :not_signed_in])

    resources("/sign-in", SessionController, only: [:new, :create], singleton: true)
    get("/auth/result", SessionController, :result)
  end

  if Mix.env() == :dev do
    forward("/emails/sent", Bamboo.SentEmailViewerPlug)
  end

  scope("/", Web) do
    pipe_through([:browser])

    get("/", PageController, :index)
    get("/challenges", PageController, :index, as: :public_challenge_index)
    get("/challenge/:id", PageController, :index, as: :public_challenge_details)
  end
end
