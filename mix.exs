defmodule Voorhees.Mixfile do
  use Mix.Project

  def project do
    [
      app: :voorhees,
      version: "0.1.1",
      name: "Voorhees",
      description: "A library for validating JSON responses",
      source_url: "https://github.com/danmcclain/voorhees",
      package: package,
      elixir: "~> 1.0",
      deps: deps
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poison, ">= 0.0.0"},
      {:ex_doc, "~> 0.6"},
      {:inch_ex, only: :docs}
    ]
  end

  defp package do
    [
      contributors: ["Dan McClain"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/danmcclain/voorhees",
        "Documentation" => "http://hexdocs.pm/voorhees"
      }
    ]
  end
end
