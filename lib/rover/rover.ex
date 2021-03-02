defmodule TestRover.Rover do
  @moduledoc """
  Simple Rover's actor as a single agent.

  It holds only the current position due to rover's device small memory but it will be
  enhanced to keep track of commands history for auditing and quality assurance purposes.
  """
  use Agent, restart: :transient, shutdown: 10_000

  require Logger

  alias TestRover.RoverPosition
  alias TestRover.RoverState

  @doc """
  Allow multiple instances (for parallel testing and expansion purposes).
  """
  def child_spec(initial_state) do
    %{
      id: initial_state.id |> process_name(true),
      start: {__MODULE__, :start_link, [initial_state]}
    }
  end

  @doc """
  Rover's communication address.
  """
  def process_name(rover_id, is_new? \\ false) do
    name_str = "rover#{rover_id}"

    if is_new? do
      String.to_atom(name_str)
    else
      String.to_existing_atom(name_str)
    end
  end

  @doc """
  Starts the process.
  """
  def start_link(%RoverState{} = initial_state) do
    Logger.info("[Rover] id: #{initial_state.id}, position: #{inspect(initial_state.position)}")
    # giving a name, the rover becomes easily addressable
    Agent.start_link(fn -> initial_state end, name: process_name(initial_state.id))
  end

  @doc """
  Returns Rover current position after 1 or N moves.
  """
  def get_position(rover_id) do
    process_name(rover_id)
    |> Agent.get(fn state -> state.position end)
  end

  @doc """
  Informs the Rover its new position.
  """
  def set_position(rover_id, %RoverPosition{} = new_position) do
    process_name(rover_id)
    |> Agent.update(fn state -> %{state | position: new_position} end)
  end
end
