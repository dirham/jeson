defmodule LexerTest do
  use ExUnit.Case

  describe "lexing literals" do
    test "string" do
      input = """
        "some"
      """

      expect = [Token.new(:STRING, "some"), Token.new(:EOF, "")]
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

      expect = [Token.new(:NUMBER, 124), Token.new(:EOF, "")]
      actual = Lexer.scan(input)
      assert length(expect) == length(actual)
      Enum.zip(expect, actual) |> Enum.each(fn {ex, ac} -> assert ex == ac end)
    end

    test "exponent number" do
      input = """
        1.0E+2
      """

      expect = [Token.new(:NUMBER, 100.0), Token.new(:EOF, "")]
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
        Token.new(:LBRACE, "{"),
        Token.new(:STRING, "some"),
        Token.new(:COLON, ":"),
        Token.new(:LBRACKET, "["),
        Token.new(:NUMBER, 1),
        Token.new(:COMMA, ","),
        Token.new(:NUMBER, 1.2),
        Token.new(:COMMA, ","),
        Token.new(:FALSE, false),
        Token.new(:COMMA, ","),
        Token.new(:NULL, nil),
        Token.new(:COMMA, ","),
        Token.new(:TRUE, true),
        Token.new(:RBRACKET, "]"),
        Token.new(:RBRACE, "}"),
        Token.new(:EOF, "")
      ]

      actual = Lexer.scan(input)
      assert length(expect) == length(actual)
    end
  end
end
