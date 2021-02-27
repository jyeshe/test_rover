defmodule TestRover.Control.Controller do
  @moduledoc """
  Sends commands to the Rovers.

  Each rover will be finished sequentially, i.e in a way that the next rover won't move
  until the prior had executed all commands.

  The Controller will act according to the input setup.
  """
  use GenServer

  def start_link(input_setup) do
    GenServer.start_link(__MODULE__, input_setup, name: __MODULE__)
  end

  @impl true
  def init(input_setup) do
    # TODO: auto-start controller
    first_rover_id = List.first(input_setup.rovers_id_sequence)
    {:ok, %{current_rover_id: first_rover_id, input_setup: input_setup}}
  end

  @impl true
  def handle_info(:rover_run, state) do
    # start next rover
    {:noreply, state}
  end
end
