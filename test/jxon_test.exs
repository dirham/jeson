defmodule JxonTest do
  use ExUnit.Case
  doctest Jxon

  test "greets the world" do
    assert {:ok, _} = Jxon.parse(~s({"some": 12, "arr": [true]}))
  end
end
