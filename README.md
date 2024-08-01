# Jxon

**Simple Json parser for elixir**

## TODO
- Publish the package into Hex
- More test cases

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jxon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jxon, "~> 0.1.0"}
  ]
end
```

## Usage
- From file
```elixir
case File.read("path_to_file") do
  {:ok, data} -> Jxon.parse(data)
  {:error, reason} -> reason
end
```

- from string
```elixir
data = ~s({"some": 1, "data": [true]})
case Jxon.parse(data) do
  {:ok, value} -> value # will return represent json object as Map %{"data" => [true], "some" => 1}
  {:error, reason} -> reason
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/jxon>.
