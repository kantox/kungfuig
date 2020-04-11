defmodule Kungfuig.Manager do
  @moduledoc false

  @type option ::
          {:start_options, [DynamicSupervisor.option()]}
          | {:init_options, [DynamicSupervisor.init_option()]}
          | {:children, [Supervisor.child_spec() | {module(), term()} | module()]}

  use DynamicSupervisor

  @spec start_link(opts :: [option()]) :: GenServer.on_start()
  def start_link(opts) do
    opts =
      Keyword.update(
        opts,
        :start_options,
        [name: __MODULE__],
        &Keyword.put_new(&1, :name, __MODULE__)
      )

    {start_options, opts} = Keyword.pop(opts, :start_options, [])
    DynamicSupervisor.start_link(__MODULE__, opts, start_options)
  end

  @impl DynamicSupervisor
  def init(opts) do
    {post_mortem, opts} = Keyword.pop(opts, :post_mortem)
    {init_options, _opts} = Keyword.pop(opts, :init_options, [])

    {:ok, sup_flags} =
      init_options
      |> Keyword.put_new(:strategy, :one_for_one)
      |> DynamicSupervisor.init()

    if is_pid(post_mortem), do: Process.send(post_mortem, :ready, [])

    {:ok, sup_flags}
  end
end
