defmodule Web.ChallengeView do
  use Web, :view

  alias IdeaPortal.Challenges
  alias IdeaPortal.Recaptcha
  alias IdeaPortal.SupportingDocuments
  alias Web.FormView
  alias Web.SharedView

  def disqus_domain() do
    Application.get_env(:idea_portal, :disqus_domain)
  end
end
