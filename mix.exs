defmodule SQLite3.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :sqlite3,
      version: @version,
      elixir: "~> 1.9",
      description: "sqlite3 driver for Elixir",
      source_url: "https://github.com/gnalck/elixir-sqlite3",
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      maintainers: ["Kevin Lang"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gnalck/elixir-sqlite3"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_connection, "2.2.2"},
      {:esqlite, "0.4.1"},
      {:ex_doc, "0.22.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
