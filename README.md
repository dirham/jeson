# Jason

**Simple Json parser for elixir**

## TODO
- More test cases

## Documentations
Full documentation can be found at [Hexdocs](https://hexdocs.pm/jeson).
## Installation

```elixir
def deps do
  [
    {:jeson, "~> 0.1.0"}
  ]
end
```

## Usage
- From file
```elixir
case File.read("path_to_file") do
  {:ok, data} -> Jeson.parse(data)
  {:error, reason} -> reason
end
```

- from string
```elixir
data = ~s({"some": 1, "data": [true]})
case Jeson.parse(data) do
  {:ok, value} -> value # will return json object representation as a Map %{"data" => [true], "some" => 1}
  {:error, reason} -> reason
end
```
