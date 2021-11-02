defmodule TwiML do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use TwiML.Magic,
    verbs: [
      :client,
      :dial,
      :enqueue,
      :gather,
      :hangup,
      :identity,
      :leave,
      :number,
      :parameter,
      :pause,
      :play,
      :record,
      :redirect,
      :reject,
      :say
    ]

  def to_xml(verbs, opts \\ []) do
    XmlBuilder.document(:Response, verbs)
    |> XmlBuilder.generate(opts)
  end

  defp build_verb(verb, attrs, children) do
    verb = verb |> Atom.to_string() |> String.capitalize()
    {verb, attrs, children}
  end
end
