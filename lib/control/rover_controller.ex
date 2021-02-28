defmodule TestRover.Control.RoverController do
  @moduledoc """
  Sends a batch of commands to a Rover.

  Each rover will be finished sequentially, i.e in a way that the next rover
  won't move until the prior had executed all commands.

  The Controller will act according to the input setup.
  """
  use GenServer

  defstruct [last_rover_id: -1, grid_size: {0, 0}]

  alias __MODULE__, as: State

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, %State{}}
  @impl true
  def init(:ok) do
    # empty state
    {:ok, %State{}}
  end

  @spec set_grid_size(any) :: :noconnect | :nosuspend | :ok
  @doc """
  Sets allowed (safe) boundary to Rover moves
  """
  def set_grid_size(grid_size) do
    Process.send(__MODULE__, {:grid_size, grid_size}, [:noconnect])
  end

  @impl true
  def handle_info({:grid_size, grid_size}, state) do
    {:noreply, %{state | grid_size: grid_size}}
  end

  @impl true
  def handle_cast({:run_rover, rover_id, command_batch}, state) do
    # TODO: run a rover
    # 1. connect/create rover
    # 2. for each command, validate safety and send it rover
    # 3. write rover output at the end
    {:noreply, state}
  end
end
