# TwiML

Generate complex TwiML responses for Twilio in an elegant Elixir way.

<!-- MDOC !-->

## Examples

Say something:

```elixir
iex> TwiML.say("Hello") |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Hello</Say>
</Response>)
```

Say 2 things, one after the other:

```elixir
iex> TwiML.say("Hello") |> TwiML.say("world") |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Hello</Say>
  <Say>world</Say>
</Response>)
```

Say something in another voice:

```elixir
iex> TwiML.say("Hello", voice: "woman") |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="woman">Hello</Say>
</Response>)
```

Leaving the content empty for a TwiML verb, will create a TwiML element that has
no body:

```elixir
iex> TwiML.hangup() |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Hangup/>
</Response>)
```

You can embed TwiML tags into other tags using the `into_*` function:

```elixir
iex> TwiML.say("Lets say this inside the gather")
...> |> TwiML.into_gather(language: "en-US", input: "speech")
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather language="en-US" input="speech">
    <Say>Lets say this inside the gather</Say>
  </Gather>
</Response>)
```

If you have multiple TwiML tags you want to embed, that works too:

```elixir
iex> TwiML.say("Hi")
...> |> TwiML.say("We cool?")
...> |> TwiML.into_gather(language: "en-US", input: "speech", hints: "yes, no")
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather language="en-US" input="speech" hints="yes, no">
    <Say>Hi</Say>
    <Say>We cool?</Say>
  </Gather>
</Response>)
```

It is also possible to just include a few of the preceding tags into the body of
another element. The `1` decides that we want to only put the last element into
the Dial element's body:

```elixir
iex> TwiML.say("Calling Yodel")
...> |> TwiML.number("+1 415-483-0400")
...> |> TwiML.into_dial(1)
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Calling Yodel</Say>
  <Dial>
    <Number>+1 415-483-0400</Number>
  </Dial>
</Response>)
```

The `into_*` functions can take the number of preceding tags, attributes or both
as arguments:

```elixir
iex> TwiML.identity("venkman")
...> |> TwiML.into_client(1)
...> |> TwiML.identity("stantz")
...> |> TwiML.into_client(1, method: "GET")
...> |> TwiML.into_dial(caller: "+1 415-483-0400")
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial caller="+1 415-483-0400">
    <Client>
      <Identity>venkman</Identity>
    </Client>
    <Client method="GET">
      <Identity>stantz</Identity>
    </Client>
  </Dial>
</Response>)
```

Multiple calls to `into_*` functions allow building complex nested TwiML
structures without losing readability in the code due to nested function calls:

```elixir
iex> TwiML.identity("venkman")
...> |> TwiML.parameter(name: "first_name", value: "Peter")
...> |> TwiML.parameter(name: "last_name", value: "Venkman")
...> |> TwiML.into_client(3)
...> |> TwiML.into_dial(1)
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial>
    <Client>
      <Identity>venkman</Identity>
      <Parameter name="first_name" value="Peter"/>
      <Parameter name="last_name" value="Venkman"/>
    </Client>
  </Dial>
</Response>)
```

Attributes can be provided both as `snake_case` or `camelCase`, but the latter is preferred as the code looks more Elixir-like.

```elixir
iex> TwiML.dial("+1 415-483-0400", recordingStatusCallback: "https://example.org", recording_status_callback_method: "POST")
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial recordingStatusCallback="https://example.org" recordingStatusCallbackMethod="POST">+1 415-483-0400</Dial>
</Response>)
```

Safe binary strings, **IO Data** or **CDATA** are supported as well. Make sure
to only mark actually safe data as safe!

```elixir
iex> TwiML.say({:safe, "<tag>Hello World</tag>"}) |> TwiML.to_xml()
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Say><tag>Hello World</tag></Say>\n</Response>"

iex> TwiML.say({:iodata, [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100]}) |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>\n<Response>\n  <Say>hello world</Say>\n</Response>)

iex> TwiML.say({:cdata, "<Hello>\\<World>"}) |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>\n<Response>\n  <Say><![CDATA[<Hello>\\<World>]]></Say>\n</Response>)
```

This also works with attributes:

```elixir
iex> TwiML.say({:safe, "<tag>Hello World</tag>"}, voice: "Polly.Joanna") |> TwiML.to_xml()
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Say voice=\"Polly.Joanna\"><tag>Hello World</tag></Say>\n</Response>"

iex> TwiML.say({:iodata, [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100]}, voice: "Polly.Joanna") |> TwiML.to_xml()
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Say voice=\"Polly.Joanna\">hello world</Say>\n</Response>"

iex> TwiML.say({:cdata, "<Hello>\\<World>"}, voice: "Polly.Joanna") |> TwiML.to_xml()
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  <Say voice=\"Polly.Joanna\"><![CDATA[<Hello>\\<World>]]></Say>\n</Response>"
```

Comments can help with debugging (yes, they are somewhat ugly, until `xml_builder` properly supports them):

```elixir
iex> TwiML.comment("Blocked because of insufficient funds") |> TwiML.reject() |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <!-->Blocked because of insufficient funds</!-->
  <Reject/>
</Response>)
```

And can also be chained:

```elixir
iex> TwiML.say("Sorry, calls are currently unavailable")
...> |> TwiML.comment("Blocked because of insufficient funds")
...> |> TwiML.reject()
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Sorry, calls are currently unavailable</Say>
  <!-->Blocked because of insufficient funds</!-->
  <Reject/>
</Response>)
```

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:twiml, "~> 0.2.0"}
  ]
end
```

## License

[MIT](./LICENSE)
