defmodule Kungfuig.Backends.System do
  @moduledoc false

  use Kungfuig

  @impl Kungfuig
  def update_config(%Kungfuig{__meta__: meta, state: %{} = state}) do
    mine =
      meta
      |> Keyword.get(:for, get_kungfuig_env())
      |> Enum.reduce(%{}, &Map.put(&2, &1, System.get_env(&1)))

    Map.put(state, :system, mine)
  end

  defp get_kungfuig_env do
    for {k, _} <- System.get_env(), String.starts_with?(k, "KUNGFUIG_"), do: k
  end
end
