defmodule TwiML do
  import TwiML.Camelize, only: [camelize: 2]

  @external_resource "README.md"
  @moduledoc """
  Generate complex TwiML responses for Twilio in an elegant Elixir way.

  For more details on supported TwiML verbs and their arguments, please consult
  the official [Twilio documentation](https://www.twilio.com/docs/voice/twiml).

  #{"README.md" |> File.read!() |> String.split("<!-- MDOC !-->") |> Enum.fetch!(1)}
  """

  use TwiML.Magic,
    # The nesting and duplication is intentionally as it improves comparing the
    # verbs with the official TwiML at https://www.twilio.com/docs/voice/twiml
    verbs: [
      [:connect, :autopilot, :siprec, :stream, :virtual_agent],
      [
        :dial,
        :application,
        :client,
        [:identity, :parameter],
        :conference,
        :number,
        :queue,
        :sim,
        :sip
      ],
      :enqueue,
      :gather,
      :hangup,
      :leave,
      :pause,
      [:pay, :prompt, :parameter],
      :play,
      :record,
      :redirect,
      :refer,
      :reject,
      :say,
      :siprec,
      :stream
    ]

  @typedoc """
  A TwiML document contains one or more TwiML verbs. These verbs can have
  attributes and can wrap nested TwiML verbs.
  """
  @type t :: [{atom(), keyword(), content() | t()}]

  @typedoc """
  Content which can be used within a TwiML verb. Refer to the `XmlBuilder`
  documentation for more information.
  """
  @type content :: binary() | {:safe, binary()} | {:cdata, binary()} | {:iodata, binary()}

  @doc """
  Generates a XML document from the provided verbs and arguments. For the
  supported `opts`, please refer to the documentation of
  `XmlBuilder.generate/2`.

  ## Examples

      iex> TwiML.say("Hello world")
      ...> |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Say>Hello world</Say></Response>)

  """
  @doc helper: true
  def to_xml(verbs, opts \\ []) do
    XmlBuilder.document(:Response, verbs)
    |> XmlBuilder.generate(opts)
  end

  defp build_verb(verb, attrs, children) do
    verb = verb |> Atom.to_string() |> String.capitalize()

    attrs =
      attrs
      |> Enum.reject(fn
        {_, nil} -> true
        {_, ""} -> true
        _ -> false
      end)
      |> Enum.map(fn {k, v} -> {camelize(k, :lower), v} end)

    {verb, attrs, children}
  end

  @doc """
  Generates a comment.

  ## Examples

      iex> TwiML.comment("Blocked because of insufficient funds")
      ...> |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><!-->Blocked because of insufficient funds</!--></Response>)

  """
  @doc helper: true
  def comment(text) do
    [{"!--", [], text}]
  end

  @doc """
  Appends a comment to the TwiML.

  ## Examples

      iex> TwiML.reject() |> TwiML.comment("Blocked because of insufficient funds") |> TwiML.to_xml(format: :none)
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Reject/><!-->Blocked because of insufficient funds</!--></Response>)

  """
  @doc helper: true
  def comment(verbs, text) do
    verbs ++ [comment(text)]
  end
end
