defmodule Kungfuig.Supervisor do
  @moduledoc false

  use Supervisor

  alias Kungfuig.{Backends, Blender, Manager}

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    {blender, opts} = Keyword.pop(opts, :blender, Blender)

    {workers, opts} =
      Keyword.pop(
        opts,
        :workers,
        Application.get_env(:kungfuig, :backends, [
          {Backends.Env, callback: {Blender, {:call, :updated}}},
          {Backends.System, callback: {Blender, {:call, :updated}}}
        ])
      )

    {:ok, pid} =
      Task.start_link(fn ->
        receive do
          :ready -> Enum.each(workers, &DynamicSupervisor.start_child(Manager, &1))
        end
      end)

    children = [
      blender,
      {Manager, post_mortem: pid}
    ]

    Supervisor.init(children, Keyword.put_new(opts, :strategy, :one_for_one))
  end
end
