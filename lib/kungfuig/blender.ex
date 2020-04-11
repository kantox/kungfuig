defmodule Kungfuig.Blender do
  @moduledoc false
  use Kungfuig

  @spec state :: Kungfuig.t()
  def state, do: GenServer.call(Kungfuig.Blender, :state)

  @impl GenServer
  def handle_call({:updated, %{} = updated}, _from, %Kungfuig{state: state} = config),
    do: {:reply, :ok, %Kungfuig{config | state: Map.merge(state, updated)}}
end
