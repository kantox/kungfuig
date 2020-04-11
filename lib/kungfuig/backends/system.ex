defmodule Kungfuig.Backends.System do
  @moduledoc false

  use Kungfuig

  @impl Kungfuig
  def update_config(%Kungfuig{__meta__: meta, state: %{} = state}) do
    mine =
      meta
      |> Keyword.get(:for, [])
      |> Enum.reduce(%{}, &Map.put(&2, &1, System.get_env(&1)))

    Map.put(state, :system, mine)
  end
end
