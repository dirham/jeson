defmodule Jxon do
  @moduledoc """
  Documentation for `Jxon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jxon.hello()
      :world

  """
  def parse(data) when is_binary(data) do
    Parser.parse(data)
  end
end
