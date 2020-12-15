defmodule Kungfuig.Test do
  use ExUnit.Case, async: false
  doctest Kungfuig

  test "custom target" do
    {:ok, pid} =
      Kungfuig.Supervisor.start_link(
        name: :server_1,
        blender:
          {Kungfuig.Blender,
           interval: 100,
           validator: Kungfuig.Validators.Env,
           callback: {self(), {:info, :updated}}}
      )

    assert_receive {:updated, %{env: %{kungfuig: []}}}, 1_010

    Application.put_env(:kungfuig, :foo, 42)

    assert_receive {:updated, %{env: %{kungfuig: [foo: 42]}}}, 1_010

    System.put_env("KUNGFUIG_FOO", "42")
    assert_receive {:updated, %{system: %{"KUNGFUIG_FOO" => "42"}}}, 1_010

    assert Kungfuig.config(:server_1) == %{
             env: %{kungfuig: [foo: 42]},
             system: %{"KUNGFUIG_FOO" => "42"}
           }

    Application.delete_env(:kungfuig, :foo)
    System.delete_env("KUNGFUIG_FOO")
    Supervisor.stop(pid)
  end

  test "transform/1" do
    {:ok, pid} =
      Kungfuig.Supervisor.start_link(
        workers: [
          {Kungfuig.Backends.EnvTransform,
           interval: 100,
           validator: Kungfuig.Validators.EnvTransform,
           callback: {self(), {:info, :updated}}}
        ]
      )

    assert_receive {:updated, %{env_transform: []}}, 120

    Application.put_env(:kungfuig, :foo_transform, %{bar: :baz})
    assert_receive {:updated, %{env_transform: [foo_transform: :baz]}}, 120
    assert Kungfuig.config() == %{env_transform: [foo_transform: :baz]}

    Application.put_env(:kungfuig, :foo_transform, %{bar: 42})
    refute_receive({:updated, %{env_transform: [foo_transform: 42]}}, 120)
    assert Kungfuig.config() == %{env_transform: [foo_transform: :baz]}

    Application.delete_env(:kungfuig, :foo_transform)
    Supervisor.stop(pid)
  end

  test "custom target with via registered name" do
    {:ok, _} = Registry.start_link(keys: :unique, name: Registry.ViaTest)
    name = {:via, Registry, {Registry.ViaTest, "server_2"}}

    {:ok, pid} =
      Kungfuig.Supervisor.start_link(
        name: name,
        blender:
          {Kungfuig.Blender,
           interval: 100,
           validator: Kungfuig.Validators.Env,
           callback: {self(), {:info, :updated}}}
      )

    assert_receive {:updated, %{env: %{kungfuig: []}}}, 1_010

    Application.put_env(:kungfuig, :bar, 24)

    assert_receive {:updated, %{env: %{kungfuig: [bar: 24]}}}, 1_010

    System.put_env("KUNGFUIG_BAR", "24")
    assert_receive {:updated, %{system: %{"KUNGFUIG_BAR" => "24"}}}, 1_010

    assert Kungfuig.config(name) == %{
             env: %{kungfuig: [bar: 24]},
             system: %{"KUNGFUIG_BAR" => "24"}
           }

    Application.delete_env(:kungfuig, :bar)
    System.delete_env("KUNGFUIG_BAR")
    Supervisor.stop(pid)
    Registry.unregister(Registry.ViaTest, "server_2")
  end
end
