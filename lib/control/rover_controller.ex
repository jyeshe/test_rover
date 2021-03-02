defmodule TestRover.Control.RoverController do
  @moduledoc """
  Sends a batch of commands to a Rover and validates movements.

  Rover movements will be finished sequentially, i.e in a way that all
  commands to a Rover is executed before switching to to another Rover.
  """
  use GenServer

  defstruct grid_size: {0, 0}, rover_id_sequence: []

  alias __MODULE__, as: State
  alias TestRover.Rover
  alias TestRover.RoverPosition
  alias TestRover.Commands.Command

  @default_id 0
  def default_id(), do: @default_id

  @doc """
  Allow multiple instances (for parallel testing and expansion purposes).
  """
  def child_spec(controller_idx \\ @default_id) do
    instance_id = controller_idx |> process_name(true)
    %{
      id: instance_id,
      start: {__MODULE__, :start_link, [controller_idx]}
    }
  end
  @doc """
  Creates a new Controller.
  """
  def start_link(id \\ @default_id) do
    GenServer.start_link(__MODULE__, :ok, name: process_name(id, true))
  end

  @doc """
  Controllers's communication address.
  """
  def process_name(controller_idx, is_new? \\ false) do
    name_str = "control#{controller_idx}"

    if is_new? do
      String.to_atom(name_str)
    else
      String.to_existing_atom(name_str)
    end
  end

  @spec init(:ok) :: {:ok, %State{}}
  @impl true
  def init(:ok) do
    # empty state
    {:ok, %State{}}
  end

  @spec set_grid_size(non_neg_integer, {pos_integer, pos_integer}) :: :noconnect | :nosuspend | :ok
  @doc """
  Sets allowed (safe) boundary to Rover moves
  """
  def set_grid_size(id, grid_size) do
    process_name(id)
    |> GenServer.cast({:grid_size, grid_size})
  end

  @doc """
  Starts a Rover movement.
  """
  def async_run_rover(id, rover_id, command_batch) do
    process_name(id)
    |> GenServer.cast({:run_rover, rover_id, command_batch})
  end

  def run_rover(id, rover_id, command_batch) do
    process_name(id)
    |> GenServer.call({:run_rover, rover_id, command_batch})
  end

  @doc """
  Gets Rover execution sequence of ids.
  """
  def get_execution_sequence(id) do
    process_name(id)
    |> GenServer.call(:id_sequence)
  end

  #
  # Callbacks
  #

  @impl true
  def handle_call(:id_sequence, _from, %{rover_id_sequence: rover_id_sequence} = state) do
    {:reply, rover_id_sequence, state}
  end

  @impl true
  def handle_call({:run_rover, rover_id, command_batch}, _from, state) do
    {:reply, nil, do_run_rover(rover_id, command_batch, state)}
  end

  @impl true
  def handle_cast({:grid_size, grid_size}, state) do
    {:noreply, %{state | grid_size: grid_size}}
  end

  @impl true
  def handle_cast({:run_rover, rover_id, command_batch}, state) do
    {:noreply, do_run_rover(rover_id, command_batch, state)}
  end

  defp do_run_rover(rover_id, command_batch, state) do
    %{
      grid_size: grid_size,
      rover_id_sequence: rover_id_sequence
    } = state
    initial_position = Rover.get_position(rover_id)

    Enum.reduce(command_batch.command_list, initial_position, fn command, position ->
      next_position(command, position, grid_size)
      |> change_rover_state(rover_id)
    end)

    %{state | rover_id_sequence: rover_id_sequence ++ [rover_id]}
  end

  defp next_position(command, position, grid_size) do
    case command do
      %Command{raw_code: ?M} -> handle_move(position, grid_size)
      %Command{raw_code: ?L} -> handle_left(position)
      %Command{raw_code: ?R} -> handle_right(position)
    end
  end

  defp handle_move(position, {max_x, max_y}) do
    case position do
      %RoverPosition{direction: "N", y: y} ->
        %{position | y: Enum.min([y + 1, max_y])}

      %RoverPosition{direction: "S", y: y} ->
        %{position | y: Enum.max([y - 1, 0])}

      %RoverPosition{direction: "E", x: x} ->
        %{position | x: Enum.min([x + 1, max_x])}

      %RoverPosition{direction: "W", x: x} ->
        %{position | x: Enum.max([x - 1, 0])}
    end
  end

  defp handle_left(position) do
    case position do
      %RoverPosition{direction: "N"} ->
        %{position | direction: "W"}

      %RoverPosition{direction: "W"} ->
        %{position | direction: "S"}

      %RoverPosition{direction: "S"} ->
        %{position | direction: "E"}

      %RoverPosition{direction: "E"} ->
        %{position | direction: "N"}
    end
  end

  defp handle_right(position) do
    case position do
      %RoverPosition{direction: "N"} ->
        %{position | direction: "E"}

      %RoverPosition{direction: "E"} ->
        %{position | direction: "S"}

      %RoverPosition{direction: "S"} ->
        %{position | direction: "W"}

      %RoverPosition{direction: "W"} ->
        %{position | direction: "N"}
    end
  end

  defp change_rover_state(new_position, rover_id) do
    Rover.set_position(rover_id, new_position)
    new_position
  end
end
