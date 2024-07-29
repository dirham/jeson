defmodule Lexer do
  def scan(input) do
    tokenize(input, [], 1, 1)
  end

  defp tokenize(<<>>, tokens, _line, _row) do
    Enum.reverse([Token.new(:EOF, "") | tokens])
  end

  defp tokenize(input, tokens, line, row) do
    case input do
      # String literal
      <<?", rest::binary>> ->
        read_string(rest, tokens, line, row)

      # number literal
      <<char, rest::binary>> when char in ?0..?9 or char == ?- ->
        read_number(rest, tokens, line, row + 1, false, <<char>>)

      # literals true/false/null
      <<?t, rest::binary>> ->
        case rest do
          <<?r, ?u, ?e, next::binary>> ->
            tokenize(next, [Token.new(:TRUE, true) | tokens], line, row + 4)

          _ ->
            {:error, "Unexpected token at line #{line} row #{row}"}
        end

      <<?f, rest::binary>> ->
        case rest do
          <<?a, ?l, ?s, ?e, next::binary>> ->
            tokenize(next, [Token.new(:FALSE, false) | tokens], line, row + 5)

          _ ->
            {:error, "Unexpected token at line #{line} row #{row}"}
        end

      <<?n, rest::binary>> ->
        case rest do
          <<?u, ?l, ?l, next::binary>> ->
            tokenize(next, [Token.new(:NULL, nil) | tokens], line, row + 4)

          any ->
            {:error, "Unexpected token #{any} at line #{line} row #{row}"}
        end

      # array
      <<?[, rest::binary>> ->
        tokenize(rest, [Token.new(:LBRACKET, "[") | tokens], line, row + 1)

      <<?], rest::binary>> ->
        tokenize(rest, [Token.new(:RBRACKET, "]") | tokens], line, row + 1)

      # object
      <<?{, rest::binary>> ->
        tokenize(rest, [Token.new(:LBRACE, "{") | tokens], line, row + 1)

      <<?}, rest::binary>> ->
        tokenize(rest, [Token.new(:RBRACE, "}") | tokens], line, row + 1)

      <<?:, rest::binary>> ->
        tokenize(rest, [Token.new(:COLON, ":") | tokens], line, row + 1)

      <<?,, rest::binary>> ->
        tokenize(rest, [Token.new(:COMMA, ",") | tokens], line, row + 1)

      # whitespaces
      <<char, rest::binary>> when char in [?\s, ?\t] ->
        tokenize(rest, tokens, line, row + 1)

      <<?\n, rest::binary>> ->
        tokenize(rest, tokens, line + 1, 1)

      <<?\r, rest::binary>> ->
        tokenize(rest, tokens, line + 1, 1)

      <<?\n, ?\r, rest::binary>> ->
        tokenize(rest, tokens, line + 1, 1)

      any ->
        {:error, "Unexpected token #{inspect(any)} at line #{line}, row #{row + 1}"}
    end
  end

  defp read_number(data, tokens, line, row, float, acc) do
    case data do
      <<char, rest::binary>> when char in ?0..?9 ->
        read_number(rest, tokens, line, row + 1, float, acc <> <<char>>)

      <<char, rest::binary>> when char == ?. ->
        read_number(rest, tokens, line, row + 1, true, acc <> <<char>>)

      <<char, rest::binary>> when char in [?e, ?E] ->
        case rest do
          <<next_char, rest2::binary>> when next_char in [?-, ?+] ->
            read_number(rest2, tokens, line, row + 2, true, acc <> <<char>> <> <<next_char>>)

          <<next_char, rest2::binary>> when next_char in ?0..?9 ->
            read_number(rest2, tokens, line, row + 2, true, acc <> <<char>> <> <<next_char>>)

          _ ->
            {:error,
             "Unexpected token after #{<<char>>}, expect - or + or digit at line #{line} row #{row}"}
        end

      _ ->
        case float do
          true ->
            case to_number(acc, true) do
              {:ok, number} -> tokenize(data, [Token.new(:NUMBER, number) | tokens], line, row)
              {:error, msg} -> {:error, msg <> "#{line} row #{row}"}
            end

          false ->
            case to_number(acc, false) do
              {:ok, number} -> tokenize(data, [Token.new(:NUMBER, number) | tokens], line, row)
              {:error, msg} -> {:error, msg <> "#{line} row #{row}"}
            end
        end
    end
  end

  defp read_string(data, tokens, line, row, acc \\ "") do
    case data do
      <<?", rest::binary>> ->
        tokenize(rest, [Token.new(:STRING, acc) | tokens], line, row + 1)

      <<char, rest::binary>> ->
        read_string(rest, tokens, line, row + 1, acc <> <<char>>)

      <<>> ->
        {:error, "Unexpected token at line #{line} row #{row}, expect \""}
    end
  end

  defp to_number(val, float) do
    case float do
      true ->
        try do
          num = String.to_float(val)
          {:ok, num}
        rescue
          ArgumentError ->
            {:error, "Invalid number format: #{val} at line "}
        end

      _ ->
        try do
          num = String.to_integer(val)
          {:ok, num}
        rescue
          ArgumentError ->
            {:error, "Invalid number format: #{val} at line "}
        end
    end
  end
end
