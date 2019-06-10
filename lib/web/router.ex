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

  pipeline(:signed_in) do
    plug(Web.Plugs.VerifyUser)
  end

  pipeline(:not_signed_in) do
    plug(Web.Plugs.VerifyNoUser)
  end

  pipeline(:admin) do
    plug(Web.Plugs.VerifyAdmin)
    plug(:put_layout, {Web.LayoutView, "admin.html"})
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Web.Plugs.FetchUser
  end

  scope "/", Web do
    pipe_through([:browser, :signed_in])

    resources("/accounts", AccountController, only: [:index, :show])
    resources("/account", AccountController, only: [:edit, :update], singleton: true)

    resources("/challenges", ChallengeController, only: [:new, :create])

    resources("/sign-in", SessionController, only: [:delete], singleton: true)

    resources("/teams", TeamController, only: [:new, :create])

    resources("/teams/:team_id/invite", TeamInvitationController, only: [:create])

    get("/teams/:team_id/invite/accept", TeamInvitationController, :accept)
    get("/teams/:team_id/invite/reject", TeamInvitationController, :reject)

    resources("/users/invite", UserInviteController, only: [:new, :create])
  end

  scope "/", Web do
    pipe_through([:browser])

    get("/", PageController, :index)

    resources("/challenges", ChallengeController, only: [:index, :show])

    get("/register/verify", RegistrationVerifyController, :show)

    resources("/teams", TeamController, only: [:index, :show])
  end

  scope "/", Web do
    pipe_through([:browser, :not_signed_in])

    resources("/register", RegistrationController, only: [:new, :create])

    get("/register/reset", RegistrationResetController, :new)
    post("/register/reset", RegistrationResetController, :create)

    get("/register/reset/verify", RegistrationResetController, :edit)
    post("/register/reset/verify", RegistrationResetController, :update)

    resources("/users/invite/accept", UserInviteAcceptController, only: [:new, :create])

    resources("/sign-in", SessionController, only: [:new, :create], singleton: true)
  end

  scope "/", Web do
    pipe_through([:api, :signed_in])

    resources("/documents", DocumentController, only: [:create])
  end

  scope "/admin", Web.Admin, as: :admin do
    pipe_through([:browser, :admin])

    get("/", DashboardController, :index)

    resources("/documents", DocumentController, only: [:delete])

    resources("/challenges", ChallengeController, only: [:index, :show, :edit, :update]) do
      resources("/documents", DocumentController, only: [:create])

      resources("/events", EventController, only: [:new, :create])
    end

    post("/challenges/:id/publish", ChallengeController, :publish, as: :challenge)
    post("/challenges/:id/archive", ChallengeController, :archive, as: :challenge)

    resources("/events", EventController, only: [:edit, :update, :delete])

    resources("/teams", TeamController, only: [:index, :show, :edit, :update, :delete])

    resources("/users", UserController, only: [:index, :show])
    post("/users/:id/toggle", UserController, :toggle, as: :user)
  end

  if Mix.env() == :dev do
    forward("/emails/sent", Bamboo.SentEmailViewerPlug)
  end
end
