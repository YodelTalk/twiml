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
      def unquote(verb)() do
        [build_verb(unquote(verb), [], [])]
      end

      def unquote(verb)(content) when is_binary(content) do
        [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)(verbs_or_attrs) when is_list(verbs_or_attrs) do
        if Keyword.keyword?(verbs_or_attrs) do
          [build_verb(unquote(verb), verbs_or_attrs, [])]
        else
          verbs_or_attrs ++ [build_verb(unquote(verb), [], [])]
        end
      end

      def unquote(verb)(verbs, attrs) when is_list(verbs) and is_list(attrs) do
        verbs ++ [build_verb(unquote(verb), attrs, [])]
      end

      def unquote(verb)(content, attrs) when is_binary(content) do
        [build_verb(unquote(verb), attrs, content)]
      end

      def unquote(verb)(verbs, content) when is_binary(content) do
        verbs ++ [build_verb(unquote(verb), [], content)]
      end

      def unquote(verb)(verbs, content, attrs)
          when is_list(verbs) and is_binary(content) and is_list(attrs) do
        verbs ++ [build_verb(unquote(verb), attrs, content)]
      end

      # How many of the preceding XML elements should be put into this one as
      # children? By default :all will be put in.
      def unquote(String.to_atom("into_#{verb}"))(verbs, last_n_elements \\ :all)

      def unquote(String.to_atom("into_#{verb}"))(verbs, last_n_elements)
          when is_integer(last_n_elements) or is_atom(last_n_elements) do
        unquote(String.to_atom("into_#{verb}"))(verbs, last_n_elements, [])
      end

      def unquote(String.to_atom("into_#{verb}"))(verbs, attrs) when is_list(attrs) do
        unquote(String.to_atom("into_#{verb}"))(verbs, :all, attrs)
      end

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
