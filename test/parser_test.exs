defmodule ParserTest do
  use ExUnit.Case
  alias Token

  describe "Parsing tokens" do
    test "valid nested json object" do
      input = """
        {"some": 123, "other obj": {"val": 80}, "test": null,}
      """

      tokens = Lexer.scan(input)
      expect = {:ok, %{"some" => 123, "other obj" => %{"val" => 80}, "test" => nil}}
      actual = Parser.parse(tokens)

      assert expect == actual
      IO.inspect(actual)
    end

    test "valid nested json object with array" do
      input = """
        {"some": 123, "other obj": {"val": 80}, "test": [12, false]}
      """

      tokens = Lexer.scan(input)
      expect = {:ok, %{"some" => 123, "other obj" => %{"val" => 80}, "test" => [12, false]}}
      actual = Parser.parse(tokens)

      assert expect == actual
      IO.inspect(actual)
    end
  end
end
