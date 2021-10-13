# TwiML

Generate complex TwiML responses for Twilio in an elegant Elixir way.

<!-- MDOC !-->

## Examples

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
iex> TwiML.say(nil, "Hello", voice: "woman") |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="woman">Hello</Say>
</Response>)
```

Leaving the content empty for a TwiML verb, will create a XML Element that has no body:

```elixir
iex> TwiML.hangup([]) |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Hangup/>
</Response>)
```

You can embed TwiML tags into other tags using the into_<verb> function:

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

It is also possible to just include a few of the preceding tags into the body of another element.
The `1` decides that we want to only put the last element into the Dial element's body:

```elixir
iex> TwiML.say("Calling Yodel")
...> |> TwiML.number("+1 415-483-0400")
...> |> TwiML.into_dial([], 1)
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Calling Yodel</Say>
  <Dial>
    <Number>+1 415-483-0400</Number>
  </Dial>
</Response>)
```

```elixir
iex> TwiML.say("Calling Yodel")
...> |> TwiML.identity("deadmau5")
...> |> TwiML.parameter([], name: "first_name", value: "Joel")
...> |> TwiML.parameter([], name: "last_name", value: "Zimmermann")
...> |> TwiML.into_client([], 3)
...> |> TwiML.into_dial([], 1)
...> |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Calling Yodel</Say>
  <Dial>
    <Client>
      <Identity>deadmau5</Identity>
      <Parameter name="first_name" value="Joel"/>
      <Parameter name="last_name" value="Zimmermann"/>
    </Client>
  </Dial>
</Response>)
```

Reject a call:

```elixir
iex> TwiML.reject([]) |> TwiML.to_xml()
~s(<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Reject/>
</Response>)
```

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:twiml, "~> 0.1.0"}
  ]
end
```

## License

[MIT](./LICENSE)
