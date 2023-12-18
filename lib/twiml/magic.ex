defmodule TwiML.Magic do
  @moduledoc false

  defmacro __using__(verbs: verbs) do
    quote do
      require TwiML.Magic
      import TwiML.Magic
    end

    for verb <- verbs |> List.flatten() |> Enum.uniq(), do: twiml_verb(verb)
  end

  def twiml_verb(verb) do
    quote do
      twiml = TwiML.Camelize.camelize(Atom.to_string(unquote(verb)))

      link =
        "https://www.twilio.com/docs/voice/twiml/" <>
          String.replace(Atom.to_string(unquote(verb)), "_", "")

      @doc """
      Generates an empty `<#{twiml}>` verb.
      """
      @spec unquote(verb)() :: TwiML.t()
      def unquote(verb)() do
        [build_verb(unquote(verb), [], [])]
      end

      @doc """
      Generates a `<#{twiml}>` verb.

      There are three supported usages:

      - Wraps `args` in `<#{twiml}>` if it's `t:TwiML.content/0`.
      - Creates an empty `<#{twiml}>` with attributes for `args` as a keyword
        list.
      - Appends an empty `<#{twiml}>` to `args` if it's `t:TwiML.t/0`, enabling
        verb chaining (refer to [Examples](#module-examples)).

      > #### Note {: .warning}
      >
      > Please refer to the [official documentation](#{link}) to verify that the
      > `#{twiml}` TwiML verb actually supports content or the given attributes.
      """
      @spec unquote(verb)(TwiML.content() | keyword() | TwiML.t()) :: TwiML.t()
      def unquote(verb)(args)

      def unquote(verb)(content) when is_binary(content) do
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:safe, text} = content) when is_binary(text) do
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:cdata, text} = content) when is_binary(text) do
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)({:iodata, text} = content) when is_list(text) do
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)(verbs_or_attrs) when is_list(verbs_or_attrs) do
        if Keyword.keyword?(verbs_or_attrs) do
          [build_verb(unquote(verb), verbs_or_attrs, [])]
        else
          verbs_or_attrs ++ [build_verb(unquote(verb), [], [])]
        end
      end

      @doc """
      Appends or generates a `<#{twiml}>` verb.

      There are two supported usages:

      - Appends `<#{twiml}>` to `verbs_or_content` if it's `t:TwiML.t/0`,
        enabling verb chaining (see [Examples](#module-examples)). This verb
        wraps `content_or_attrs` if it's `t:TwiML.content/0`, or includes
        attributes if `content_or_attrs` is a keyword list.
      - Generates `<#{twiml}>` with attributes if `content_or_attrs` is a
        keyword list.

      > #### Note {: .warning}
      >
      > Please refer to the [official documentation](#{link}) to verify that the
      > `#{twiml}` TwiML verb actually supports content or the given attributes.
      """
      def unquote(verb)(verbs_or_content, content_or_attrs)

      @spec unquote(verb)(TwiML.t(), keyword() | TwiML.content()) :: TwiML.t()
      def unquote(verb)(verbs, attrs) when is_list(verbs) and is_list(attrs) do
        verbs ++ [build_verb(unquote(verb), attrs, [])]
      end

      def unquote(verb)(verbs, content) when is_binary(content) do
        verbs ++ [build_verb(unquote(verb), [], content)]
      end

      @spec unquote(verb)(TwiML.content(), keyword()) :: TwiML.t()
      def unquote(verb)(content, attrs) when is_binary(content) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:safe, text} = content, attrs) when is_binary(text) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:cdata, text} = content, attrs) when is_binary(text) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)({:iodata, text} = content, attrs) when is_list(text) do
        [build_verb(unquote(verb), attrs, content)]
      end

      @doc """
      Appends a `<#{twiml}>` verb with attributes.

      Adds a `<#{twiml}>` verb to `verbs` using `attrs` as attributes,
      facilitating verb chaining (see [Examples](#module-examples)).

      > #### Note {: .warning}
      >
      > Please refer to the [official documentation](#{link}) to verify that the
      > `#{twiml}` TwiML verb actually supports content or the given attributes.
      """
      @spec unquote(verb)(TwiML.t(), TwiML.content(), keyword()) :: TwiML.t()
      def unquote(verb)(verbs, content, attrs)
          when is_list(verbs) and is_binary(content) and is_list(attrs) do
        verbs ++ [build_verb(unquote(verb), attrs, content)]
      end

      @doc """
      Wraps preceding TwiML verbs in a `<#{twiml}>` verb.

      There are three supported usages:
      - Uses `attrs_or_last_n_elements` as attributes to wrap all preceding verbs
        in `<#{twiml}>` if it's a keyword list.
      - Wraps all preceding verbs in `<#{twiml}>` if `attrs_or_last_n_elements` is
        `:all`.
      - Encloses the last `attrs_or_last_n_elements` verbs in `<#{twiml}>` if it's a
        positive integer.

      > #### Note {: .warning}
      >
      > Please refer to the [official documentation](#{link}) to verify that the
      > `#{twiml}` TwiML verb actually supports the given attributes.
      """
      @spec unquote(String.to_atom("into_#{verb}"))(
              TwiML.t(),
              keyword() | :all | pos_integer()
            ) :: TwiML.t()
      def unquote(String.to_atom("into_#{verb}"))(verbs, attrs_or_last_n_elements \\ :all)

      def unquote(String.to_atom("into_#{verb}"))(verbs, attrs_or_last_n_elements)
          when is_integer(attrs_or_last_n_elements) or is_atom(attrs_or_last_n_elements) do
        unquote(String.to_atom("into_#{verb}"))(verbs, attrs_or_last_n_elements, [])
      end

      def unquote(String.to_atom("into_#{verb}"))(verbs, attrs) when is_list(attrs) do
        unquote(String.to_atom("into_#{verb}"))(verbs, :all, attrs)
      end

      @doc """
      Wraps preceding TwiML verbs in a `<#{twiml}>` verb with attributes.

      There are three supported usages:
      - Wraps all preceding verbs in `<#{twiml}>` using `attrs` as attributes if
        `last_n_elements` is `:all`.
      - Encloses the last `last_n_elements` verbs in `<#{twiml}>` using `attrs`
        as attribute if it's a positive integer.

      > #### Note {: .warning}
      >
      > Please refer to the [official documentation](#{link}) to verify that the
      > `#{twiml}` TwiML verb actually supports the given attributes.
      """
      @spec unquote(String.to_atom("into_#{verb}"))(
              TwiML.t(),
              :all | pos_integer(),
              keyword()
            ) :: TwiML.t()
      def unquote(String.to_atom("into_#{verb}"))(verbs, last_n_elements, attrs)

      def unquote(String.to_atom("into_#{verb}"))(verbs, :all, attrs) do
        [build_verb(unquote(verb), attrs, [verbs])]
      end

      def unquote(String.to_atom("into_#{verb}"))(verbs, last_n_elements, attrs)
          when is_integer(last_n_elements) and last_n_elements > 0 do
        {head, tail} = Enum.split(verbs, last_n_elements * -1)
        head ++ [build_verb(unquote(verb), attrs, [tail])]
      end
    end
  end
end
