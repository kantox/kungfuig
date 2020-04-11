defmodule Kungfuig.Blender do
  @moduledoc false

  use Kungfuig

  @spec state :: Kungfuig.t()
  def state, do: GenServer.call(Kungfuig.Blender, :state)

  @impl GenServer
  def handle_call(
        {:updated, %{} = updated},
        _from,
        %Kungfuig{__meta__: meta, state: state} = config
      ) do
    state = Map.merge(state, updated)
    send_callback(meta[:callback], state)
    {:reply, :ok, %Kungfuig{config | state: state}}
  end
end
