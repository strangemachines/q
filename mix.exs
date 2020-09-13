defmodule Q.MixProject do
  use Mix.Project

  def project do
    [
      app: :q,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      name: "Q",
      description: "A query parser builder",
      homepage_url: "https://github.com/strangemachines/q",
      source_url: "https://github.com/strangemachines/q",
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
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
      {:credo, "~> 0.9", only: :dev, runtime: false},
      {:dummy, "~> 1.4", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :q_parser,
      files: ~w(mix.exs lib .formatter.exs README.md LICENSE),
      maintainers: ["Jacopo Cascioli"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/strangemachines/q"}
    ]
  end
end
