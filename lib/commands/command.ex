defmodule TestRover.Commands.Command do
  @moduledoc """
  Encapsulates single valid Command.

  Properties:
  raw_code: list of commands
  name: meaning of the code
  """
  defstruct raw_code: nil, name: nil

  @type t :: %__MODULE__{raw_code: String.t() | nil, name: String.t() | nil}

  @code_move "M"
  @code_left "L"
  @code_right "R"
  @names %{
    @code_move => "Move",
    @code_left => "Left",
    @code_right => "Right"
  }
  @unknown "Unknown"

  @spec new(any) :: :error | {:ok, t()}
  def new(raw_code) do
    cmd_name = Map.get(@names, raw_code, @unknown)

    if cmd_name != @unknown do
      {:ok, %__MODULE__{raw_code: raw_code, name: cmd_name}}
    else
      :error
    end
  end

  @spec domain() :: list(String.t())
  def domain(), do: [@code_move, @code_left, @code_right]

  defimpl String.Chars do
    def to_string(%{raw_code: raw_code, name: name}), do: "#{raw_code}:#{name}"
  end
end
