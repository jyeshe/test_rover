defmodule TestRoverTest do
  use ExUnit.Case

  alias TestRover.Rover
  alias TestRover.RoverState
  alias TestRover.RoverPosition

  alias TestRover.LazyInitializer

  alias TestRover.Control.RoverFactory
  alias TestRover.Control.RoverController
  alias TestRover.Commands.Command
  alias TestRover.Commands.Batch

  @filepath TestRover.Application.filepath()
  @filepath1 "priv/input1.txt"
  @filepath2 "priv/input2.txt"
  @filepath3 "priv/input3.txt"

  @max_grid_size 250

  test "initial state" do
    # rovers 0 and 1 are reserved for process_file/1
    LazyInitializer.test_load_file(@filepath, 0, 2)
    assert Rover.get_position(2) == %RoverPosition{direction: "N", x: 1, y: 2}
    assert Rover.get_position(3) == %RoverPosition{direction: "E", x: 3, y: 3}

    LazyInitializer.test_load_file(@filepath1, 0, 4)
    assert Rover.get_position(4) == %RoverPosition{direction: "W", x: 2, y: 3}
    assert Rover.get_position(5) == %RoverPosition{direction: "S", x: 0, y: 4}

    LazyInitializer.test_load_file(@filepath2, 0, 6)
    assert Rover.get_position(6) == %RoverPosition{direction: "E", x: 21, y: 32}
    assert Rover.get_position(7) == %RoverPosition{direction: "W", x: 53, y: 44}

    LazyInitializer.test_load_file(@filepath3, 0, 8)
    assert Rover.get_position(8) == %RoverPosition{direction: "S", x: 60, y: 51}
    assert Rover.get_position(9) == %RoverPosition{direction: "N", x: 75, y: 87}
  end

  test "final state" do
    final0 = %RoverPosition{direction: "N", x: 1, y: 3}
    final1 = %RoverPosition{direction: "E", x: 5, y: 1}
    process_assert_final_state(@filepath, final0, final1)

    final0 = %RoverPosition{direction: "W", x: 0, y: 3}
    final1 = %RoverPosition{direction: "N", x: 2, y: 2}
    process_assert_final_state(@filepath1, final0, final1)

    final0 = %RoverPosition{direction: "E", x: 45, y: 32}
    final1 = %RoverPosition{direction: "S", x: 41, y: 46}
    process_assert_final_state(@filepath2, final0, final1)

    final0 = %RoverPosition{direction: "S", x: 65, y: 49}
    final1 = %RoverPosition{direction: "N", x: 77, y: 89}
    process_assert_final_state(@filepath3, final0, final1)
  end

  test "360 degrees left" do
    grid_side = 2
    rover_id = "360"
    initial_position = %RoverPosition{x: 0, y: 0, direction: "N"}
    first_commands = [
      Command.new(?L) |> elem(1),
      Command.new(?L) |> elem(1),
      Command.new(?L) |> elem(1),
      Command.new(?L) |> elem(1),
    ]

    test_run(rover_id, initial_position, grid_side, first_commands)

    assert Rover.get_position(rover_id) == %{initial_position | y: grid_side, direction: "N"}
  end

  test "360 degrees right" do
    grid_side = 2
    rover_id = "360"
    initial_position = %RoverPosition{x: 0, y: 0, direction: "N"}
    first_commands = [
      Command.new(?R) |> elem(1),
      Command.new(?R) |> elem(1),
      Command.new(?R) |> elem(1),
      Command.new(?R) |> elem(1),
    ]

    test_run(rover_id, initial_position, grid_side, first_commands)

    assert Rover.get_position(rover_id) == %{initial_position | y: grid_side, direction: "N"}
  end

  test "move up" do
    Stream.each(1..@max_grid_size,
      fn grid_side ->
        rover_id = "move up#{grid_side}"
        initial_position = %RoverPosition{x: 0, y: 0, direction: "N"}

        test_run(rover_id, initial_position, grid_side)

        assert Rover.get_position(rover_id) == %{initial_position | y: grid_side}
      end)
    |> Stream.run()
  end

  test "move down" do
    Stream.each(1..@max_grid_size,
      fn grid_side ->
        rover_id = "move down#{grid_side}"
        initial_position = %RoverPosition{x: 0, y: grid_side, direction: "S"}

        test_run(rover_id, initial_position, grid_side)

        assert Rover.get_position(rover_id) == %{initial_position | y: 0}
      end)
    |> Stream.run()
  end

  test "move left" do
    Stream.each(1..@max_grid_size,
      fn grid_side ->
        rover_id = "move left#{grid_side}"
        initial_position = %RoverPosition{x: grid_side, y: 0, direction: "N"}
        first_commands = [Command.new(?L) |> elem(1)]

        test_run(rover_id, initial_position, grid_side, first_commands)

        assert Rover.get_position(rover_id) == %{initial_position | x: 0, direction: "W"}
      end)
    |> Stream.run()
  end

  test "move right" do
    Stream.each(1..@max_grid_size,
      fn grid_side ->
        rover_id = "move right#{grid_side}"
        initial_position = %RoverPosition{x: 0, y: 0, direction: "N"}
        first_commands = [Command.new(?R) |> elem(1)]

        test_run(rover_id, initial_position, grid_side, first_commands)

        assert Rover.get_position(rover_id) == %{initial_position | x: grid_side, direction: "E"}
      end)
    |> Stream.run()
  end

  #
  # Test Helpers
  #
  defp process_assert_final_state(filepath, final0, final1) do
    LazyInitializer.process_file(filepath)
    Process.sleep(100)
    assert Rover.get_position(0) == final0
    assert Rover.get_position(1) == final1
    RoverFactory.rover_shutdown(0, true)
    RoverFactory.rover_shutdown(1, true)
  end

  defp test_run(rover_id, initial_position, grid_side, first_commands \\ []) do
    controller_id = System.unique_integer()
    RoverController.start_link(controller_id)

    %RoverState{
      id: rover_id,
      position: initial_position
    }
    |> RoverFactory.rover_boot()

    cmd_list = for _i <- 1..grid_side, do: Command.new(?M) |> elem(1)
    batch = %Batch{command_list: first_commands ++ cmd_list}

    RoverController.set_grid_size(controller_id, {grid_side, grid_side})
    RoverController.run_rover(controller_id, rover_id, batch)

    initial_position
  end
end
