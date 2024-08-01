defmodule LexerTest do
  use ExUnit.Case

  describe "lexing literals" do
    test "string" do
      input = """
        "some"
      """

      expect = [Token.new(:STRING, "some", 1, 3), Token.new(:EOF, "", 2, 1)]
      actual = Lexer.scan(input)

      assert length(expect) == length(actual)
      Enum.zip(expect, actual) |> Enum.each(fn {ex, ac} -> assert ex == ac end)
    end

    test "invalid string" do
      input = """
        "some" d
      """

      assert {:error, msg} = Lexer.scan(input)
      IO.puts(msg)
    end

    test "number" do
      input = """
        124
      """

      expect = [Token.new(:NUMBER, 124, 1, 3), Token.new(:EOF, "", 2, 1)]
      actual = Lexer.scan(input)
      assert length(expect) == length(actual)
      Enum.zip(expect, actual) |> Enum.each(fn {ex, ac} -> assert ex == ac end)
    end

    test "exponent number" do
      input = """
        1.0E+2
      """

      expect = [Token.new(:NUMBER, 100.0, 1, 3), Token.new(:EOF, "", 2, 1)]
      actual = Lexer.scan(input)
      assert length(expect) == length(actual)
      Enum.zip(expect, actual) |> Enum.each(fn {ex, ac} -> assert ex == ac end)
    end

    test "invalid exponent number" do
      input = """
        1.0E+e-2
      """

      assert {:error, msg} = Lexer.scan(input)
      IO.inspect(msg)
    end
  end

  describe "full json" do
    test "valid" do
      input = """
        {"some": [1, 1.2, false, null, true]}
      """

      expect = [
        Token.new(:LBRACE, "{", 1, 3),
        Token.new(:STRING, "some", 1, 4),
        Token.new(:COLON, ":", 1, 10),
        Token.new(:LBRACKET, "[", 1, 12),
        Token.new(:NUMBER, 1, 1, 13),
        Token.new(:COMMA, ",", 1, 14),
        Token.new(:NUMBER, 1.2, 1, 16),
        Token.new(:COMMA, ",", 1, 19),
        Token.new(:FALSE, false, 1, 21),
        Token.new(:COMMA, ",", 1, 26),
        Token.new(:NULL, nil, 1, 28),
        Token.new(:COMMA, ",", 1, 32),
        Token.new(:TRUE, true, 1, 34),
        Token.new(:RBRACKET, "]", 1, 38),
        Token.new(:RBRACE, "}", 1, 39),
        Token.new(:EOF, "", 2, 1)
      ]

      actual = Lexer.scan(input)
      assert length(expect) == length(actual)
      Enum.zip(expect, actual) |> Enum.each(fn {ex, ac} -> assert ex == ac end)
    end
  end
end
