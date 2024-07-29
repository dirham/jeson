defmodule Token do
  defstruct [:type, :value]

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
          | :ILLEGAL
          | :EOF

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
                   :ILLEGAL,
                   :EOF
                 ]

  @spec new(token(), any()) :: %__MODULE__{} | no_return()
  def new(type, value) when in_type?(type) do
    %__MODULE__{type: type, value: value}
  end
end
