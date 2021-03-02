defmodule TestRover.RoverPosition do
  @moduledoc """
  Typed Rover position
  """
  @type t() :: %__MODULE__{x: pos_integer, y: pos_integer, direction: String.t()}
  defstruct x: 0, y: 0, direction: "N"
end
