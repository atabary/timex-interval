defmodule TimexInterval.Mixfile do
  use Mix.Project

  def project do
    [ app: :timex_interval,
      version: "0.1.0",
      elixir: "~> 1.0.0",
      description: "A date/time interval library for Elixir projects, based on Timex.",
      package: package,
      docs: [readme: true, main: "README"],
      deps: deps() ]
  end

  defp deps do
    [
      {:timex, github: "bitwalker/timex", tag: "0.12.7"},
    ]
  end

  defp package do
    [ files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Alexis Tabary"],
      licenses: ["Apache 2"],
      links: [
        {"GitHub", "https://github.com/atabary/timex-interval"},
      ] ]
  end
end
