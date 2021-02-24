defmodule ChallengeGov.SiteContent do
  @moduledoc """
  Site content context
  """
  import Ecto.Query

  alias ChallengeGov.Repo
  alias ChallengeGov.SiteContent.Content

  def all(opts \\ []) do
    Content
    |> order_by([c], asc: c.section)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  def get(section) do
    Content
    |> where([c], c.section == ^section)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      content ->
        {:ok, content}
    end
  end

  def edit(content), do: Content.changeset(content, %{})

  def update(content, params) do
    content
    |> Content.changeset(params)
    |> Repo.update()
  end
end
