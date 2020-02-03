defmodule ChallengeGov.LoginGov.Cache do
  use Agent

  alias ChallengeGov.LoginGov

  def start_link(_opts) do
    preload = Application.get_env(:challenge_gov, :cache)[:preload]

    start_fn =
      case preload do
        true -> fn -> get_initial_state() end
        _ -> fn -> %{} end
      end

    Agent.start_link(start_fn, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def get_all do
    Agent.get(__MODULE__, & &1)
  end

  def init(state) do
    Agent.update(__MODULE__, fn _ -> state end)
  end

  defp get_initial_state do
    %{
      idp_authorize_url: idp_authorize_url,
      private_key_path: private_key_path
    } = Application.get_env(:challenge_gov, :oidc_config)

    with {:ok, well_known_config} <- LoginGov.get_well_known_configuration(idp_authorize_url),
         {:ok, public_key} <- LoginGov.get_public_key(well_known_config["jwks_uri"]),
         private_key <- LoginGov.load_private_key(private_key_path) do
      well_known_config
      |> string_keys_to_atoms()
      |> Map.put(:public_key, public_key)
      |> Map.put(:private_key, private_key)
    else
      {:error, error} -> %{error: error}
    end
  end

  defp string_keys_to_atoms(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
  end
end
