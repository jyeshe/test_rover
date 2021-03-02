# TestRover

A squad of robotic rovers are to be landed by NASA on a plateau on
Mars. This plateau, which is curiously rectangular, must be navigated
by the rovers so that their on-board cameras can get a complete view
of the surrounding terrain to send back to Earth.
A rover's position and location is represented by a combination of x
and y co-ordinates and a letter representing one of the four cardinal
compass points. The plateau is divided up into a grid to simplify
navigation. An example position might be 0, 0, N, which means the
rover is in the bottom left corner and facing North.
In order to control a rover, NASA sends a simple string of letters.
The possible letters are 'L', 'R' and 'M'. 'L' and 'R' makes the
rover spin 90 degrees left or right respectively, without moving from
its current spot. 'M' means move forward one grid point, and maintain
the same heading.

Assume that the square directly North from (x, y) is (x, y+1).

## Modules

* TestRover.Application: Elixir supervised Aplication
* TestRover.LazyInitializer: Reads input and initializes Rovers and Controller

* TestRover.Rover: Agent that acts like a Rover accepting commands
* TestRover.RoverPosition: Typed position (with direction)
* TestRover.RoverState: Encapsulates Rover state

* TestRover.Control.RoverController: Sends validated commands to the Rovers 
* TestRover.Control.RoverFactory: Controls Rover lifecycle

* TestRover.Commands.Batch: Batch of validated commands
* TestRover.Commands.Command: Single command

* TestRover.InvalidHeaderException: Raised on invalid grid
* TestRover.InvalidPositionException: Raised on invalid position line
* TestRover.InvalidCommandEncodingException: Raised on invalid commands line
* TestRover.InvalidCommandException: Raised on unknown command

## Installation

After cloning this repo, call `mix run --no-halt` in its root dir.


