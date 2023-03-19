defmodule Kungfuig.Blender do
  @moduledoc false

  use Kungfuig, imminent: true

  @spec state :: Kungfuig.t()
  def state, do: GenServer.call(__MODULE__, :state)

  @spec state(GenServer.name()) :: Kungfuig.t()
  def state(name), do: :persistent_term.get(name, nil) || state()

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
