defmodule Web.Api.MessageView do
  use Web, :view

  alias Web.AccountView
  alias Web.MessageContextView

  def render("create.json", %{user: user, message: message}) do
    %{
      author_id: message.author_id,
      author_name: AccountView.full_name(message.author),
      content: message.content,
      status: message.status,
      class: MessageContextView.message_class(user, message)
    }
  end
end
