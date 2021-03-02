defmodule TestRover.Control.RoverFactory do
  @moduledoc """
  Controls a Rover lifecycle (boots up and terminates).
  """
  use DynamicSupervisor

  alias TestRover.Rover
  alias TestRover.RoverState
  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def rover_boot(%RoverState{} = initial_state) do
    spec = {Rover, initial_state}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def rover_shutdown(rover_id, terminate \\ false) do
    if terminate do
      rover_pid =
        Rover.process_name(rover_id)
        |> Process.whereis()

      DynamicSupervisor.terminate_child(__MODULE__, rover_pid)
    end
  end

  @impl true
  def init(opts) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: opts
    )
  end
end
