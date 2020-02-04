defmodule ChallengeGov.LoginGov.Cache do
  use GenServer

  require Logger

  alias ChallengeGov.LoginGov

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def all() do
    GenServer.call(__MODULE__, :get_all)
  end

  def init(state) do
    {:ok, %{}, {:continue, :warm_cache}}
  end

  def handle_continue(:warm_cache, _state) do
    case get_initial_state() do
      {:error, error} ->
        Process.send_after(self(), :warm_cache, 1_500)
        {:noreply, {:error, error}}

      state ->
        {:noreply, state}
    end
  end

  def handle_info(:warm_cache, state) do
    Logger.debug("Attempting to warm the LoginGov OIDC cache again", labels: __MODULE__)
    {:noreply, state, {:continue, :warm_cache}}
  end

  def handle_call({:get, key}, _from, state) do
    case Map.has_key?(state, key) do
      true ->
        {:reply, {:ok, state[key]}, state}

      false ->
        {:reply, {:error, :no_key}, state}
    end
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  defp get_initial_state() do
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
    end
  end

  defp string_keys_to_atoms(map) do
    Enum.into(map, %{}, fn {k, v} ->
      {String.to_atom(k), v}
    end)
  end
end
