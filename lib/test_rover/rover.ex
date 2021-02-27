defmodule TestRover.Rover do
  @moduledoc """
  Simple Rover's actor as a single agent.

  It holds only the current position due to rovers small memory but it will be
  enhanced to keep track of commands history for auditing and quality assurance purposes.
  """
  use Agent, restart: :transient, shutdown: 10_000

  def start_link(rover_id, initial_position) do
    Agent.start_link(fn -> initial_position end, name: process_name(rover_id, true))
  end

  def get_position(rover_id) do
    process_name(rover_id)
    |> Agent.get(& &1)
  end

  def set_position(rover_id, new_position) do
    process_name(rover_id)
    |> Agent.update(fn _current_position -> new_position end)
  end

  defp process_name(rover_id, is_new? \\ false) do
    name_str = "rover#{rover_id}"
    if is_new? do
      String.to_atom(name_str)
    else
      String.to_existing_atom(name_str)
    end
  end
end
