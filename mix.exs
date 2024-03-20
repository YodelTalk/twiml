defmodule Twiml.MixProject do
  use Mix.Project

  @version "0.5.0"
  @url "https://github.com/YodelTalk/twiml"
  @maintainers ["Mario Uher"]

  def project do
    [
      app: :twiml,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ],

      # Docs
      name: "TwiML",
      source_url: @url,
      docs: [
        main: "TwiML",
        source_ref: "v#{@version}",
        groups_for_docs: [
          {:Types, &(&1[:kind] == :type)},
          {:"TwiML Verbs", &(!&1[:helper])}
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xml_builder, "~> 2.2"},
      {:doctest_formatter, "~> 0.2.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :docs},
      {:styler, ">= 0.11.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Generate complex TwiML documents for Twilio in an elegant Elixir way.
    """
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end
end
