defmodule TestRover.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @filepath "priv/input.txt"

  def start(_type, _args) do
    children = [
      TestRover.Control.RoverController,
      TestRover.LazyInitializer
    ]

    opts = [strategy: :one_for_one, name: TestRover.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    # async file processing
    TestRover.LazyInitializer.process_file(@filepath)

    start_result
  end
end
