defmodule TestRover.Commands.Batch do
  @moduledoc """
  Encapsulates a command batch of one Rover.

  It is represented as a list in this initial version. There are some thoughts
  to put the batch into a timeline separated by a fixed or variable interval between
  each command in order to evaluate better the moment of each move.

  Properties:
  command_list: list of commands
  """
  defstruct command_list: []

  @type t :: %__MODULE__{command_list: list(Command.t())}

  alias TestRover.Commands.Command

  @spec new!(raw_code_list :: list(pos_integer)) :: t()
  def new!(raw_code_list) do
    %__MODULE__{
      command_list: Enum.map(raw_code_list, &valid_command!/1)
    }
  end

  @spec valid_command!(raw_code :: pos_integer) :: Command.t()
  def valid_command!(raw_code) do
    case Command.new(raw_code) do
      {:ok, command} ->
        command

      :error ->
        raise TestRover.InvalidCommandException, raw_code: raw_code
    end
  end
end
