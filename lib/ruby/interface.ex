defmodule Ruby.Interface do
  @moduledoc """
  false
  """
  use Export.Ruby

  def call(file, method, params) do
    {:ok, ruby} = Ruby.start(ruby_lib: Path.join([:code.priv_dir(:challenge_gov), "ruby"]))
    Ruby.call(ruby, "param_decoder", "setup_param_decoder", [])
    result = Ruby.call(ruby, file, method, params)
    Ruby.stop(ruby)
    result
  end
end
