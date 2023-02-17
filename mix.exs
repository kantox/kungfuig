defmodule Kungfuig.MixProject do
  use Mix.Project

  @app :kungfuig
  @name "Kungfuig"
  @version "0.4.4"
  @owner "kantox"
  @maintainers ["Aleksei Matiushkin"]
  @private_hex ""
  @licenses ["MIT"]

  def project do
    [
      app: @app,
      name: @name,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      xref: [exclude: []],
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      xref: [exclude: []],
      docs: docs(),
      releases: [],
      dialyzer: [
        plt_file: {:no_warn, ".dialyzer/dialyzer.plt"},
        ignore_warnings: ".dialyzer/ignore.exs"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_options, "~> 0.3"},
      # dev / test
      {:credo, "~> 1.0", only: [:dev, :ci]},
      {:dialyxir, "~> 1.0", only: [:dev, :test, :ci], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end

  defp description do
    """
    Live config supporting many different backends.

    **Kungfuig** (_pronounced:_ [ˌkʌŋˈfig]) provides a drastically easy way to plug
    live configuration into everything.

    It provides backends for `env` and `system` and supports custom backends.
    """
  end

  defp package do
    [
      name: @app,
      files: ~w|stuff lib mix.exs README.md|,
      maintainers: @maintainers,
      licenses: @licenses,
      links: %{
        "GitHub" => "https://github.com/#{@owner}/#{@app}",
        "Docs" => "https://#{@private_hex}hexdocs.pm/#{@app}"
      }
    ]
  end

  defp docs do
    [
      main: "Kungfuig",
      source_ref: "v#{@version}",
      canonical: "http://#{@private_hex}hexdocs.pm/#{@app}",
      logo: "stuff/#{@app}-48x48.png",
      source_url: "https://github.com/#{@owner}/#{@app}",
      assets: "stuff/images",
      extras: ["README.md"],
      groups_for_modules: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:ci), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
