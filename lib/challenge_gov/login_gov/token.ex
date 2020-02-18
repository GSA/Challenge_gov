defmodule ChallengeGov.LoginGov.Token do
  @moduledoc """
  Token context for login.gov
  """
  use Joken.Config

  def signer(private_key) do
    %Joken.Signer{
      alg: "RS256",
      jwk: private_key,
      jws: JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})
    }
  end

  def token_config do
    %{}
  end
end
