# ![Kungfuig](https://raw.githubusercontent.com/kantox/kungfuig/master/stuff/kungfuig-48x48.png) Kungfuig    [![Kantox ❤ OSS](https://img.shields.io/badge/❤-kantox_oss-informational.svg)](https://kantox.com/)  ![Test](https://github.com/kantox/kungfuig/workflows/Test/badge.svg)  ![Dialyzer](https://github.com/kantox/kungfuig/workflows/Dialyzer/badge.svg)

## Intro

Live config supporting many different backends.

**Kungfuig** (_pronounced:_ [ˌkʌŋˈfig]) provides an easy way to plug
live configuration into everything.

It provides backends for `env` and `system` and supports custom backends.

## Installation

```elixir
def deps do
  [
    {:kungfuig, "~> 0.1"}
  ]
end
```

## Using

**Kungfuig** is the easy way to read the external configuration from sources that are not controlled by the application using it, such as _Redis_, or _Database_.

Here is the example of backend implementation for the config read from external _MySQL_.

```elixir
defmodule MyApp.Kungfuig.MySQL do
  @moduledoc false

  use Kungfuig.Backend

  @impl Kungfuig.Backend
  def get(_meta) do
    with {:ok, host} <- System.fetch_env("MYSQL_HOST"),
         {:ok, db} <- System.fetch_env("MYSQL_DB"),
         {:ok, user} <- System.fetch_env("MYSQL_USER"),
         {:ok, pass} <- System.fetch_env("MYSQL_PASS"),
         {:ok, pid} when is_pid(pid) <-
           MyXQL.start_link(hostname: host, database: db, username: user, password: pass),
         result <- MyXQL.query!(pid, "SELECT * FROM some_table") do
      GenServer.stop(pid)

      result =
        result.rows
        |> Flow.from_enumerable()
        |> Flow.map(fn [_, field1, field2, _, _] -> {field1, field2} end)
        |> Flow.partition(key: &elem(&1, 0))
        |> Flow.reduce(fn -> %{} end, fn {field1, field2}, acc ->
          Map.update(
            acc,
            String.to_existing_atom(field1),
            [field2],
            &[field2 | &1]
          )
        end)

      Logger.info("Loaded #{Enum.count(result)} values from " <> host)

      {:ok, result}
    else
      :error ->
        Logger.warn("Skipped reconfig, one of MYSQL_{HOST,DB,USER,PASS} is missing")
        :ok

      error ->
        Logger.error("Reconfiguring failed. Error: " <> inspect(error))
        {:error, error}
    end
  end
end
```

## Testing

Simply implement a stub returning an expected config and you are all set.

```elixir
defmodule MyApp.Kungfuig.Stub do
  @moduledoc false

  use Kungfuig.Backend

  @impl Kungfuig.Backend
  def get(_meta), do: %{foo: :bar, baz: [42]}
end
```

## Changelog

- **`0.4.3`** — fix a bug with hardcoded names (`Supervisor` and `Blender`)
- **`0.4.2`** — allow `imminent: true` option to `Kungfuig.Backend`
- **`0.4.0`** — allow named `Kungfuig.Supervisor` (thanks @vbroskas)
- **`0.3.0`** — allow validation through `NimbleOptions` (per backend and global)
- **`0.2.0`** — scaffold for backends + several callbacks (and the automatic one for `Blender`)

## [Documentation](https://hexdocs.pm/kungfuig)
