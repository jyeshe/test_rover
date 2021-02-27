defmodule TestRover.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias TestRover.Control.InputSetup

  @filepath "priv/input.txt"

  def start(_type, _args) do
    input_setup = load_input(@filepath)

    children = [
      {TestRover.Control.RoverController, [input_setup]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestRover.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp load_input(file) do
    # TODO:
    # 1. read input file
    # 2. create id for each rover
    # 3. create command batch (skip rover on unknown command)
    %InputSetup{}
  end
end
