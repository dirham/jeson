defmodule Lexer do
  @spec scan(binary()) :: list(Token.t()) | {:error, String.t()}
  def scan(input) do
    tokenize(input, [], 1, 1)
  end

  defp tokenize(<<>>, tokens, line, row) do
    Enum.reverse([Token.new(:EOF, "", line, row) | tokens])
  end

  defp tokenize(input, tokens, line, row) do
    case input do
      # String literal
      <<?", rest::binary>> ->
        read_string(rest, tokens, line, row, row + 1)

      # number literal
      <<char, rest::binary>> when char in ?0..?9 or char == ?- ->
        read_number(rest, tokens, line, row, row + 1, false, <<char>>)

      # literals true/false/null
      <<?t, rest::binary>> ->
        case rest do
          <<?r, ?u, ?e, next::binary>> ->
            tokenize(next, [Token.new(:TRUE, true, line, row) | tokens], line, row + 4)

          _ ->
            {:error, "Unexpected token at line #{line} row #{row}"}
        end

      <<?f, rest::binary>> ->
        case rest do
          <<?a, ?l, ?s, ?e, next::binary>> ->
            tokenize(next, [Token.new(:FALSE, false, line, row) | tokens], line, row + 5)

          _ ->
            {:error, "Unexpected token at line #{line} row #{row}"}
        end

      <<?n, rest::binary>> ->
        case rest do
          <<?u, ?l, ?l, next::binary>> ->
            tokenize(next, [Token.new(:NULL, nil, line, row) | tokens], line, row + 4)

          any ->
            {:error, "Unexpected token #{any} at line #{line} row #{row}"}
        end

      # array
      <<?[, rest::binary>> ->
        tokenize(rest, [Token.new(:LBRACKET, "[", line, row) | tokens], line, row + 1)

      <<?], rest::binary>> ->
        tokenize(rest, [Token.new(:RBRACKET, "]", line, row) | tokens], line, row + 1)

      # object
      <<?{, rest::binary>> ->
        tokenize(rest, [Token.new(:LBRACE, "{", line, row) | tokens], line, row + 1)

      <<?}, rest::binary>> ->
        tokenize(rest, [Token.new(:RBRACE, "}", line, row) | tokens], line, row + 1)

      <<?:, rest::binary>> ->
        tokenize(rest, [Token.new(:COLON, ":", line, row) | tokens], line, row + 1)

      <<?,, rest::binary>> ->
        tokenize(rest, [Token.new(:COMMA, ",", line, row) | tokens], line, row + 1)

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

  defp read_number(data, tokens, line, start, row, float, acc) do
    case data do
      <<char, rest::binary>> when char in ?0..?9 ->
        read_number(rest, tokens, line, start, row + 1, float, acc <> <<char>>)

      <<char, rest::binary>> when char == ?. ->
        read_number(rest, tokens, line, start, row + 1, true, acc <> <<char>>)

      <<char, rest::binary>> when char in [?e, ?E] ->
        case rest do
          <<next_char, rest2::binary>> when next_char in [?-, ?+] ->
            read_number(
              rest2,
              tokens,
              line,
              start,
              row + 2,
              true,
              acc <> <<char>> <> <<next_char>>
            )

          <<next_char, rest2::binary>> when next_char in ?0..?9 ->
            read_number(
              rest2,
              tokens,
              line,
              start,
              row + 2,
              true,
              acc <> <<char>> <> <<next_char>>
            )

          _ ->
            {:error,
             "Unexpected token after #{<<char>>}, expect - or + or digit at line #{line} row #{row}"}
        end

      _ ->
        case float do
          true ->
            case to_number(acc, true) do
              {:ok, number} ->
                tokenize(data, [Token.new(:NUMBER, number, line, start) | tokens], line, row)

              {:error, msg} ->
                {:error, msg <> "#{line} row #{row}"}
            end

          false ->
            case to_number(acc, false) do
              {:ok, number} ->
                tokenize(data, [Token.new(:NUMBER, number, line, start) | tokens], line, row)

              {:error, msg} ->
                {:error, msg <> "#{line} row #{row}"}
            end
        end
    end
  end

  defp read_string(data, tokens, line, start, row, acc \\ "") do
    case data do
      <<?", rest::binary>> ->
        tokenize(rest, [Token.new(:STRING, acc, line, start) | tokens], line, row + 1)

      <<char, rest::binary>> ->
        read_string(rest, tokens, line, start, row + 1, acc <> <<char>>)

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
