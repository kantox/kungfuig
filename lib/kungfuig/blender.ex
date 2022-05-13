defmodule Kungfuig.Blender do
  @moduledoc false

  use Kungfuig, imminent: true

  @spec state :: Kungfuig.t()
  def state, do: GenServer.call(__MODULE__, :state)

  @impl GenServer
  def handle_call(
        {:updated, %{} = updated},
        _from,
        %Kungfuig{state: state} = config
      ),
      do: {:reply, :ok, %Kungfuig{config | state: Map.merge(state, updated)}}
end
