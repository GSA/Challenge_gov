defmodule Web.Admin.ChallengeView do
  use Web, :view

  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges
  alias ChallengeGov.SupportingDocuments
  alias Web.Admin.FormView
  alias Web.SharedView
  alias Web.ChallengeView

  def name_link(conn, challenge) do
    link(challenge.title, to: Routes.admin_challenge_path(conn, :show, challenge.id))
  end
end
