defmodule JesonTest do
  use ExUnit.Case
  doctest Jeson

  test "success parsing valid json" do
    assert {:ok, _} = Jeson.parse(~s({"some": 12, "arr": [true]}))
  end
end
