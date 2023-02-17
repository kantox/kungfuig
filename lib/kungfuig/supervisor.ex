defmodule Kungfuig.Supervisor do
  @moduledoc false

  use Supervisor

  alias Kungfuig.{Backends, Blender, Manager}

  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, Keyword.put(opts, :name, name), name: name)
  end

  @impl true
  def init(opts) do
    {name, opts} = Keyword.pop(opts, :name)

    default_blender =
      case name do
        atom when is_atom(atom) -> {Blender, name: Module.concat([name, Blender])}
        _ -> Blender
      end

    {blender, opts} = Keyword.pop(opts, :blender, default_blender)

    {blender, blender_opts} =
      case blender do
        module when is_atom(module) -> {module, []}
        {module, opts} -> {module, opts}
      end

    blender_name = Keyword.get(blender_opts, :name, blender)

    {workers, opts} =
      Keyword.pop(
        opts,
        :workers,
        Application.get_env(:kungfuig, :backends, [Backends.Env, Backends.System])
      )

    workers =
      Enum.map(workers, fn
        module when is_atom(module) ->
          {module, callback: {blender_name, {:call, :updated}}}

        {module, opts} ->
          {module, [{:callback, {blender_name, {:call, :updated}}} | opts]}
      end)

    {:ok, pid} =
      Task.start_link(fn ->
        receive do
          :ready -> Enum.each(workers, &DynamicSupervisor.start_child(Manager, &1))
        end
      end)

    children = [
      {blender, blender_opts},
      {Manager, post_mortem: pid}
    ]

    Supervisor.init(children, Keyword.put_new(opts, :strategy, :one_for_one))
  end
end
