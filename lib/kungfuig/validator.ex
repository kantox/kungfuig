defmodule Kungfuig.Validator do
  @moduledoc """
  Generic validator encapsulation.

  Default implementation is
    [`NimbleOptions`](https://github.com/dashbitco/nimble_options).
  """

  @doc """
  Validates given options with the schema, provided by the implementation of this behaviour
  """
  @callback validate(options :: map() | keyword()) ::
              {:ok, validated_options :: keyword()} | {:error, any()}

  @doc """
  Generates a documentation for expected options
  """
  @callback doc(options :: keyword()) :: String.t()

  defmacro __using__(opts) do
    quote location: :keep, generated: true do
      @behaviour Kungfuig.Validator

      @validator (case Keyword.get(unquote(opts), :with, NimbleOptions) do
                    module when is_atom(module) -> {module, :validate}
                    {module, fun} when is_atom(module) and is_atom(fun) -> {module, fun}
                  end)
      @documentor (case Keyword.get(unquote(opts), :docs, elem(@validator, 0)) do
                     module when is_atom(module) -> {module, :docs}
                     {module, fun} when is_atom(module) and is_atom(fun) -> {module, fun}
                   end)
      @schema Keyword.get(unquote(opts), :schema, [])

      @impl Kungfuig.Validator
      def validate(options) when is_map(options),
        do: with({:ok, kw} <- options |> Map.to_list() |> validate(), do: {:ok, Map.new(kw)})

      @impl Kungfuig.Validator
      def validate(options) when is_list(options),
        do: with({m, f} <- @validator, do: apply(m, f, [options, @schema]))

      @impl Kungfuig.Validator
      def doc(options \\ []) when is_list(options),
        do: with({m, f} <- @documentor, do: apply(m, f, [@schema, options]))
    end
  end
end
