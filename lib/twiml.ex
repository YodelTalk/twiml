defmodule TwiML do
  import TwiML.Camelize, only: [camelize: 2]

  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use TwiML.Magic,
    # The nesting and duplication is intentionally as it improves comparing the
    # verbs with the official TwiML at https://www.twilio.com/docs/voice/twiml
    verbs: [
      [:connect, :autopilot, :siprec, :stream, :virtual_agent],
      [:dial, :client, [:identity, :parameter], :conference, :number, :queue, :sim, :sip],
      :enqueue,
      :gather,
      :hangup,
      :leave,
      :pause,
      [:pay, :prompt],
      :play,
      :record,
      :redirect,
      :refer,
      :reject,
      :say,
      :siprec,
      :stream
    ]

  def to_xml(verbs, opts \\ []) do
    XmlBuilder.document(:Response, verbs)
    |> XmlBuilder.generate(opts)
  end

  defp build_verb(verb, attrs, children) do
    verb = verb |> Atom.to_string() |> String.capitalize()
    attrs = Enum.map(attrs, fn {k, v} -> {camelize(k, :lower), v} end)

    {verb, attrs, children}
  end

  def comment(text) do
    [{"!--", [], text}]
  end

  def comment(verbs, text) do
    verbs ++ [comment(text)]
  end
end
