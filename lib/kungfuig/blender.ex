defmodule Kungfuig.Blender do
  @moduledoc false

  use Kungfuig, imminent: true

  @spec state(GenServer.name()) :: Kungfuig.t()
  def state(name \\ __MODULE__),
    do: :persistent_term.get(name, nil) || GenServer.call(name, :state)

  @impl GenServer
  def handle_call(
        {:updated, %{} = updated},
        _from,
        %Kungfuig{__meta__: opts, state: state} = config
      ) do
    name = Keyword.get(opts, :name)
    state = Map.merge(state, updated)
    unless is_nil(name), do: :persistent_term.put(name, state)
    {:reply, :ok, %Kungfuig{config | state: state}}
  end
end
