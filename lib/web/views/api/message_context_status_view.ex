defmodule Web.Api.MessageContextStatusView do
  use Web, :view

  def render("star.json", %{message_context_status: message_context_status}) do
    %{
      starred: message_context_status.starred
    }
  end
end
