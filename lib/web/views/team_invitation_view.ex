defmodule Web.TeamInvitationView do
  use Web, :view

  alias Web.AccountView
  alias Web.Endpoint

  def render("index.json", %{team: team, accounts: accounts}) do
    %{
      collection: render_many(accounts, __MODULE__, "show.json", team: team, as: :account)
    }
  end

  def render("show.json", %{team: team, account: account}) do
    %{
      name: AccountView.full_name(account),
      avatar_url: AccountView.avatar_url(account),
      invite_url: Routes.team_invitation_path(Endpoint, :create, team.id, user_id: account.id)
    }
  end
end
