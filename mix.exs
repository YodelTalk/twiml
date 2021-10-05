defmodule Twiml.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/YodelTalk/twiml"
  @maintainers ["Christoph Leitner", "Mario Uher"]

  def project do
    [
      app: :twiml,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "TwiML",
      source_url: @url,
      docs: [main: "TwiML", source_ref: "v#{@version}"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xml_builder, "~> 2.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    Generate complex TwiML responses for Twilio in an elegant Elixir way.
    """
  end

  defp package() do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"GitHub" => @url}
    ]
  end
end
