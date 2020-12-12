ExUnit.start()

defmodule Kungfuig.Backends.EnvTransform do
  @moduledoc false

  use Kungfuig.Backend

  @impl Kungfuig.Backend
  def get(meta) do
    {:ok,
     meta
     |> Keyword.get(:for, [:kungfuig])
     |> Enum.reduce(%{}, &Map.put(&2, &1, Application.get_all_env(&1)))}
  end

  @impl Kungfuig.Backend
  def transform(%{kungfuig: env}) do
    {:ok, for({k, v} <- env, {_, value} <- v, do: {k, value})}
  end
end
