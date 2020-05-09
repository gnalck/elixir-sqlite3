defmodule SQLite3.MixProject do
  use Mix.Project

  def project do
    [
      app: :sqlite3,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: "sqlite3 driver for Elixir",
      source_url: "https://github.com/gnalck/elixir-sqlite3",
      deps: deps()
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
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gnalck/elixir-sqlite3"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_connection, "~> 2.2.2"},
      {:sqlitex, "~> 1.7.1"}
    ]
  end
end
