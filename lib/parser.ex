defmodule Parser do
  @moduledoc """
  A simple JSON parser that processes a list of tokens and produces a native data structure.
  """

  alias Token
  @type token_list :: [Token.t()]

  @type json_value :: map() | list() | String.t() | integer() | float() | boolean() | nil
  @type json_object :: map()
  @type json_array :: list(json_value())

  @spec parse(String.t()) :: {:ok, json_value()} | {:error, String.t()}
  def parse(data) do
    case Lexer.scan(data) do
      {:error, reason} -> {:error, reason}
      tokens when is_list(tokens) -> do_parse(tokens)
    end
  end

  defp do_parse(tokens) do
    case parse_value(tokens) do
      {:error, error} ->
        {:error, error}

      {value, [%Token{type: :EOF}]} ->
        {:ok, value}

      {value, rest} ->
        {:error, "Unexpected tokens after `#{value}`, #{inspect(rest)}"}
    end
  end

  @spec parse_value(token_list()) :: {json_value(), token_list()} | {:error, String.t()}
  defp parse_value(tokens) do
    case tokens do
      [%Token{type: :STRING, value: value} | rest] ->
        {value, rest}

      [%Token{type: :NUMBER, value: value} | rest] ->
        {value, rest}

      [%Token{type: :TRUE} | rest] ->
        {true, rest}

      [%Token{type: :FALSE} | rest] ->
        {false, rest}

      [%Token{type: :NULL} | rest] ->
        {nil, rest}

      [%Token{type: :LBRACE} | rest] ->
        parse_object(rest)

      [%Token{type: :LBRACKET} | rest] ->
        parse_array(rest)

      [unexpected_token | _rest] ->
        {:error,
         "Unexpected token #{unexpected_token.value} at line #{unexpected_token.line} row #{unexpected_token.row}"}

      [] ->
        {:error, "Unexpected end of input"}
    end
  end

  @spec parse_object(token_list()) :: {json_object(), token_list()} | {:error, String.t()}
  defp parse_object(tokens) do
    parse_object(tokens, %{})
  end

  @spec parse_object(token_list(), json_object()) ::
          {json_object(), token_list()} | {:error, String.t()}
  defp parse_object(tokens, acc) do
    case tokens do
      [%Token{type: :RBRACE} | rest] ->
        {acc, rest}

      [%Token{type: :STRING, value: key} | rest] ->
        case consume_token(rest, :COLON, "Expected ':' after object key") do
          {:error, error} ->
            {:error, error}

          {:ok, rest} ->
            case parse_value(rest) do
              {:error, error} ->
                {:error, error}

              {value, rest} ->
                acc = Map.put(acc, key, value)

                case rest do
                  [%Token{type: :RBRACE} | rest] ->
                    {acc, rest}

                  [%Token{type: :COMMA} | rest] ->
                    parse_object(rest, acc)

                  [unexpected_token | _] ->
                    {:error,
                     "Unexpected token #{unexpected_token.value} at line #{unexpected_token.line} row #{unexpected_token.row}. Expected comma or closing brace in object"}

                  [] ->
                    {:error, "Unexpected end of input"}
                end
            end
        end

      [unexpected_token | _rest] ->
        {:error,
         "Unexpected token #{unexpected_token.value} at line #{unexpected_token.line} row #{unexpected_token.row}"}

      [] ->
        {:error, "Unexpected end of input"}
    end
  end

  @spec parse_array(token_list()) :: {json_array(), token_list()} | {:error, String.t()}
  defp parse_array(tokens) do
    parse_array(tokens, [])
  end

  @spec parse_array(token_list(), json_array()) ::
          {json_array(), token_list()} | {:error, String.t()}
  defp parse_array(tokens, acc) do
    case tokens do
      [%Token{type: :RBRACKET} | rest] ->
        {Enum.reverse(acc), rest}

      _ ->
        case parse_value(tokens) do
          {:error, error} ->
            {:error, error}

          {value, rest} ->
            acc = [value | acc]

            case rest do
              [%Token{type: :RBRACKET} | rest] ->
                {Enum.reverse(acc), rest}

              [%Token{type: :COMMA} | rest] ->
                parse_array(rest, acc)

              [unexpected_token | _] ->
                {:error,
                 "Unexpected token #{unexpected_token.value} at line #{unexpected_token.line} row #{unexpected_token.row}. Expected comma or closing bracket in array"}

              [] ->
                {:error, "Unexpected end of input"}
            end
        end
    end
  end

  @spec consume_token(token_list(), atom(), String.t()) ::
          {:ok, token_list()} | {:error, String.t()}
  defp consume_token([%Token{type: expected_type} | rest], expected_type, _error_message) do
    {:ok, rest}
  end

  defp consume_token([unexpected_token | _], _expected_type, error_message) do
    {:error,
     "#{error_message}. Got #{unexpected_token.value} at line #{unexpected_token.line} row #{unexpected_token.row}"}
  end

  defp consume_token([], _expected_type, error_message) do
    {:error, "#{error_message}. Unexpected end of input"}
  end
end
