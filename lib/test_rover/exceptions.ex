defmodule TestRover.InvalidHeaderException do
  defexception [:message, :header_grid]

  def exception(header_grid) do
    %__MODULE__{
      message: "Expected format is two positive integers",
      header_grid: header_grid
    }
  end
end

defmodule TestRover.InvalidPositionException do
  defexception [:message, :position]

  def exception(position: position, domain: domain) do
    %__MODULE__{
      message: """
      Invalid position: #{inspect(position)}.
      Expects two positive integers and a direction in #{inspect(domain)}
      """,
      position: position
    }
  end
end

defmodule TestRover.InvalidCommandEncodingException do
  defexception [:message, :commands]

  alias TestRover.Commands.Command

  def exception(commands) do
    %__MODULE__{
      message: """
      Invalid command line: #{inspect(commands)}.
      Allowed values: #{inspect(Command.domain_regex())}
      """,
      commands: commands
    }
  end
end

defmodule TestRover.InvalidCommandException do
  defexception [:message, :raw_code]

  alias TestRover.Commands.Command

  def exception(raw_code) do
    %__MODULE__{
      message: "Allowed values: #{inspect(Command.domain_regex())}",
      raw_code: raw_code
    }
  end
end
