defmodule TestRover.Control.InputSetup do
  @moduledoc """
  Encapsulates all instructions of the mission.

  It associates the commands to the Rovers.

  This might be extended to other configurations on to perform the control like
  initial delay, interval between commands and rovers or alerting when a dangerous
  command is to be executed.

  Properties:
  rovers_id_sequence: list of ids of Rovers
  rover_command_map: map of a command batch for each Rover
  """

  defstruct rovers_id_sequence: [], rover_command_map: Map.new()
end
