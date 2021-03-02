defmodule TestRover.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @filepath "priv/input.txt"
  def filepath(), do: @filepath

  @default_controller_id TestRover.Control.RoverController.default_id()

  def start(_type, _args) do
    children = [
      {TestRover.Control.RoverFactory, []},
      {TestRover.Control.RoverController, @default_controller_id},
      {TestRover.LazyInitializer, []}
    ]

    opts = [strategy: :one_for_one, name: TestRover.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    # async file processing
    if Mix.env() != :test do
      TestRover.LazyInitializer.process_file(@filepath)
    end

    start_result
  end
end
