defmodule Kungfuig.Backends.Env do
  @moduledoc false

  use Kungfuig

  @impl Kungfuig
  def update_config(%Kungfuig{__meta__: meta, state: %{} = state}) do
    mine =
      meta
      |> Keyword.get(:for, [:rates_blender])
      |> Enum.reduce(%{}, &Map.put(&2, &1, Application.get_all_env(&1)))

    Map.put(state, :env, mine)
  end
end
