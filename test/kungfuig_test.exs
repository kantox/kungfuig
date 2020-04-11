defmodule KungfuigTest do
  use ExUnit.Case
  doctest Kungfuig

  test "custom target" do
    {:ok, pid} =
      Kungfuig.Supervisor.start_link(
        blender: {Kungfuig.Blender, callback: {self(), {:info, :updated}}}
      )

    assert_receive {:updated, %{env: %{kungfuig: []}}}, 10

    Application.put_env(:kungfuig, :foo, 42)
    assert_receive {:updated, %{env: %{kungfuig: [foo: 42]}}}, 1_010

    System.put_env("KUNGFUIG_FOO", "42")
    assert_receive {:updated, %{system: %{"KUNGFUIG_FOO" => "42"}}}, 1_010

    Supervisor.stop(pid)
  end
end
