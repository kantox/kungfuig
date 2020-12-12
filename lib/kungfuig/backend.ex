defmodule Kungfuig.Backend do
  @moduledoc "The scaffold for the backend watching the external config source."

  @doc "The key this particular config would be stored under, defaults to module name"
  @callback key :: atom()

  @doc "The implementation of the call to remote that retrieves the data"
  @callback get([Kungfuig.option()]) :: {:ok, any()} | {:error, any()}

  @doc "The transformer that converts the retrieved data to internal representation"
  @callback transform(any()) :: {:ok, any()} | {:error, any()}

  @doc "The implementation of error reporting"
  @callback report(any()) :: :ok

  @doc false
  defmacro __using__(opts \\ []) do
    quote location: :keep, generated: true do
      @behaviour Kungfuig.Backend

      @key Keyword.get(
             unquote(opts),
             :key,
             __MODULE__ |> Module.split() |> List.last() |> Macro.underscore() |> String.to_atom()
           )

      @report Keyword.get(unquote(opts), :report, :none)

      @impl Kungfuig.Backend
      def key, do: @key

      @impl Kungfuig.Backend
      def transform(any), do: {:ok, any}

      @impl Kungfuig.Backend
      case @report do
        :logger ->
          require Logger

          def report(error),
            do:
              Logger.info(fn ->
                "Failed to retrieve config in #{key()}. Error: #{inspect(error)}."
              end)

        _ ->
          def report(_any), do: :ok
      end

      defoverridable Kungfuig.Backend

      use Kungfuig

      @impl Kungfuig
      def update_config(%Kungfuig{__meta__: meta, state: %{} = state}) do
        with {:ok, result} <- get(meta),
             {:ok, result} <- transform(result) do
          Map.put(state, key(), result)
        else
          {:error, error} ->
            report(error)
            state
        end
      end

      @spec smart_validate(validator :: nil | module(), options :: keyword()) ::
              {:ok, keyword()} | {:error, any()}
      defp smart_validate(nil, options), do: {:ok, options}
      defp smart_validate(Kungfuig.Validators.Void, options), do: {:ok, options}

      defp smart_validate(validator, options) do
        with {:ok, validated} <- validator.validate(options[key()]),
             do: {:ok, %{options | key() => validated}}
      end

      @spec report_error(error :: any()) :: :ok
      defp report_error(error), do: report(error)
    end
  end
end
