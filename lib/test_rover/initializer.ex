defmodule TestRover.LazyInitializer do
  @moduledoc """
  Process a stream of instructions read from input file and send them
  asynchronously to Controller as list of commands mapped to a Rover.

  This might be extended to other configurations like initial delay,
  interval between commands and rovers or alerting when a dangerous
  rover command is to be executed.
  """
  use GenServer

  alias TestRover.Rover
  alias TestRover.RoverState
  alias TestRover.RoverPosition
  alias TestRover.Control.RoverFactory
  alias TestRover.Control.RoverController
  alias TestRover.Commands.Batch, as: CommandBatch

  defstruct [:grid_size, :initial_state, :command_batch]
  alias __MODULE__, as: RoverSetup

  @direction_domain ["N", "S", "E", "W"]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def test_load_file(filepath, controller_id, id_offset) do
    stream_resource(filepath)
    |> Stream.each(fn %RoverSetup{} = rover_setup ->
      setup_rover(controller_id, rover_setup, id_offset)
    end)
    |> Stream.run()
  end

  def process_file(filepath) do
    GenServer.cast(__MODULE__, {:process_file, filepath})
  end

  def handle_cast({:process_file, filepath}, state) do
    controller_id = RoverController.default_id()

    stream_resource(filepath)
    |> Stream.each(fn %RoverSetup{} = rover_setup ->

      setup_rover(controller_id, rover_setup)

      RoverController.async_run_rover(controller_id, rover_setup.initial_state.id, rover_setup.command_batch)
    end)
    |> Stream.run()

    RoverController.get_execution_sequence(controller_id)
    |> Enum.each(fn rover_id ->
        %{x: x, y: y, direction: direction} = Rover.get_position(rover_id)
        RoverFactory.rover_shutdown(rover_id)
        IO.puts "#{x} #{y} #{direction}"
      end)

    {:noreply, state}
  end

  defp setup_rover(controller_id, rover_setup, id_offset \\ 0) do
    initial_state = get_initial_state(rover_setup.initial_state, id_offset)
    # create Rover
    RoverFactory.rover_boot(initial_state)
    # sets Rover controller parameter(s)
    RoverController.set_grid_size(controller_id, rover_setup.grid_size)
  end

  defp get_initial_state(initial_state, id_offset) do
    # for testability and sharding purposes
    if Mix.env() != :test do
      initial_state
    else
      %{initial_state | id: initial_state.id + id_offset}
    end
  end

  defp stream_resource(filepath) do
    Stream.resource(
      # init resource
      fn -> read_header(filepath) end,
      # iterate resource
      fn {file, grid_size, rover_index} ->
        position_line = IO.read(file, :line)
        commands_line = IO.read(file, :line)

        if position_line == :eof or commands_line == :eof do
          {:halt, file}
        else
          position = parse_position(position_line)
          command_batch = parse_commands(commands_line)

          rover_setup = %RoverSetup{
            grid_size: grid_size,
            command_batch: command_batch,
            initial_state: %RoverState{id: rover_index, position: position}
          }

          # {[element()], next resource state}
          {[rover_setup], {file, grid_size, rover_index + 1}}
        end
      end,
      # terminate resource
      fn file -> File.close(file) end
    )
  end

  # reads grid size
  def read_header(filepath) do
    file = File.open!(filepath)

    grid_size_line = IO.read(file, :line)

    if not is_binary(grid_size_line) or length(String.split(grid_size_line)) != 2 do
      raise_header_exception(grid_size_line)
    else
      [x_str, y_str] = String.split(grid_size_line)

      with {x, ""} <- Integer.parse(x_str),
           {y, ""} <- Integer.parse(y_str) do
        {file, {x, y}, 0}
      else
        _error ->
          raise_header_exception(grid_size_line)
      end
    end
  end

  defp parse_position(position_line) do
    if not is_binary(position_line) or
         not String.printable?(position_line) or
         length(String.split(position_line)) != 3 do
      raise_position_exception(position_line)
    else
      [x_str, y_str, direction] = String.split(position_line)

      with {x, ""} <- Integer.parse(x_str),
           {y, ""} <- Integer.parse(y_str),
           true <- direction in @direction_domain do
        %RoverPosition{x: x, y: y, direction: direction}
      else
        _error ->
          raise_position_exception(position_line)
      end
    end
  end

  defp parse_commands(commands_line) do
    if not is_binary(commands_line) do
      raise_commands_exception(commands_line)
    else
      String.to_charlist(commands_line)
      |> Enum.filter(fn char -> char != ?\n end)
      |> CommandBatch.new!()
    end
  end

  defp raise_header_exception(header_grid_line) do
    # spawn to avoid dyalizer warning
    spawn(fn -> raise TestRover.InvalidHeaderException, header_grid: header_grid_line end)
    :ok
  end

  def raise_position_exception(position_line) do
    # spawn to avoid dyalizer warning
    spawn(fn ->
      raise TestRover.InvalidPositionException,
        position: position_line,
        domain: @direction_domain
    end)

    :ok
  end

  def raise_commands_exception(commands_line) do
    # spawn to avoid dyalizer warning
    spawn(fn -> raise TestRover.InvalidCommandEncodingException, commands: commands_line end)
    :ok
  end
end
