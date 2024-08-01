defmodule Token do
  defstruct [:type, :value, :line, :row]

  @type token ::
          :STRING
          | :NUMBER
          | :COMMA
          | :COLON
          | :LBRACE
          | :RBRACE
          | :LBRACKET
          | :RBRACKET
          | :TRUE
          | :FALSE
          | :NULL
          | :EOF

  @type t :: %__MODULE__{
          type: token(),
          value: any(),
          line: non_neg_integer(),
          row: non_neg_integer()
        }

  defguardp in_type?(char)
            when char in [
                   :STRING,
                   :NUMBER,
                   :COMMA,
                   :COLON,
                   :LBRACE,
                   :RBRACE,
                   :LBRACKET,
                   :RBRACKET,
                   :TRUE,
                   :FALSE,
                   :NULL,
                   :EOF
                 ]

  @spec new(token(), any(), number(), number()) :: t() | no_return()
  def new(type, value, line, row) when in_type?(type) do
    %__MODULE__{type: type, value: value, line: line, row: row}
  end
end
