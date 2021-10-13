defmodule TwiML.Magic do
  defmacro __using__(verbs: verbs) do
    quote do
      require TwiML.Magic
      import TwiML.Magic
    end

    for verb <- verbs, do: twiml_verb(verb)
  end

  def twiml_verb(verb) do
    quote do
      def unquote(verb)(verbs \\ nil, content, attrs \\ [])

      # If no content is specified (`""` or `[]`), we will just set an empty
      # content list for XmlBuilder so the XML Tag doesn't have a content body
      # and is closed immediately - e.g. <Hangup/>
      def unquote(verb)(nil, content, attrs) when content == [] or content == "" do
        [build_verb(unquote(verb), attrs, [])]
      end

      def unquote(verb)(nil, content, attrs) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)(verbs, content, attrs) do
        verbs ++ unquote(verb)(nil, content, attrs)
      end

      def unquote(String.to_atom("into_#{verb}"))(verbs, attrs, last_n_elements \\ :all)
          when is_list(attrs) do
        # How many of the preceding XML elements should be put into this one as
        # children? By default :all will be put in.
        case last_n_elements do
          :all ->
            [build_verb(unquote(verb), attrs, [verbs])]

          count when is_integer(count) and count > 0 ->
            {head, tail} = Enum.split(verbs, count * -1)
            head ++ [build_verb(unquote(verb), attrs, [tail])]
        end
      end
    end
  end
end
