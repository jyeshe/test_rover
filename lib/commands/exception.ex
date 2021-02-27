defmodule TestRover.InvalidCommandException do
  defexception [:raw_code, :message]

  alias TestRover.Commands.Command

  def exception(raw_code) do
    %__MODULE__{
      message: "#{raw_code} is invalid. Allowed values: #{inspect(Command.domain())}",
      raw_code: raw_code
    }
  end
end
