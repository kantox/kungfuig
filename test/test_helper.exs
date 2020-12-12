ExUnit.start()

defmodule Kungfuig.Backends.EnvTransform do
  @moduledoc false

  use Kungfuig.Backend, report: :logger

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

defmodule Kungfuig.Validators.Env do
  @moduledoc false

  use Kungfuig.Validator,
    schema: [env: [type: :any, required: false], system: [type: :any, required: false]]
end

defmodule Kungfuig.Validators.EnvTransform do
  @moduledoc false

  use Kungfuig.Validator, schema: [foo_transform: [type: :atom, required: false]]
end
