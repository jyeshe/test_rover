defmodule TestRover.RoverState do
  @moduledoc """
  Rover state currently corresponding only to its id and position.
  """
  alias TestRover.RoverPosition

  defstruct id: nil, position: %RoverPosition{}
end
