defmodule Jxon do
  @moduledoc """
  Documentation for `Jxon`.
  """

  @doc """
  parse(data) receive binary data and return {:ok, @json_value} | {:error, String}

  ## Examples

      iex> data = ~s({"obj": {"neste": true}})
      iex> Jxon.parse(data)

  """
  @spec parse(binary()) :: {:ok, any()} | {:error, String.t()}
  def parse(data) when is_binary(data) do
    Parser.parse(data)
  end
end
