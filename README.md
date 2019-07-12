# AOI (Area Of Interest) algorithm (Use Game Server)

  A simple AOI(Area Of Interest) library by a pure Lua language implementation.

  It applies to two-dimensional arrays and unordered Linked-lists (`table` simulations).

## API Introduce

#### Import libraries

  Use them to include the `class.lua` and `map.lua` files, which have the necessary data structures inside.

  Copy them from the `lib` folder to the corresponding location and import them : `local Map = require "map"`.

#### Map:new(opt)

  `opt` is a dictionary of type `table`.

  `opt.x` represents the maximum range of the x-axis.

  `opt.y` represents the maximum range of the y-axis.

  `opt.radius` indicates the radius range.

  This method returns an initialized `Map` object.

#### Map:enter(unit, x, y)

  `x` and `y` represent the two-dimensional coordinates of the map. Their values cannot be negative or `nil` and need to be greater than `map.x` and `map.y`.

  This method will return the list of `x` and `y` coordinates of the surrounding units based on the `opt.radius` defined when initializing `Map`.

  Note: The range means: `x - radius` to `x + radius` and `y - radius` to `y + radius`.

#### Map:move(unit, x, y)

  Move `unit` to the `x` and `y` positions.

  This method returns an array of `unit` collections containing `x` and `y` in the `radius` range of other `units`

#### Map:leave(unit)

  Remove a `unit` from `Map`.

  This method returns the `units` array in the `radius` range of `unit`.

#### Map:get_pos_by_unit(unit)

  This method returns the `x` and `y` corresponding to the `unit`.

#### Map:dumps()

  Print the location of all units and units in the map. This method has no return value.

#### Usage

  There are some usage examples in the `test.lua` file:

  ```lua
  local Map = require "map"
  local m = Map:new {
  	x = 512,
  	y = 512,
  	radius = 10,
  }

  print("-----")

  print("10000 enter [1], [1], The number of units within the radius is: "..#m:enter(10000, 1, 1))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10001 enter [10], [10], The number of units within the radius is: "..#m:enter(10001, 10, 10))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10002 enter [25], [25], The number of units within the radius is: "..#m:enter(10002, 25, 25))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10001 move to [15], [15], The number of units within the radius is: "..#m:move(10001, 15, 15))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10001 leave from [1], [1], The number of units within the radius is: "..#m:leave(10000))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10001 leave from [15], [15], The number of units within the radius is: "..#m:leave(10001))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")

  print("10002 leave from [25], [25], The number of units within the radius is: "..#m:leave(10002))

  print("The total number of people in the map is: "..m:members())m:dumps()

  print("-----")
  ```

  You can create multiple `Map` objects that can be used for different `scene`.

#### Note

  * `X`、`Y`、`opt.x`、`opt.y`、`opt.radius` must be integer.

  * `X` and `Y` must satisfy these conditions: `0 <= (X or Y)<= 65535`.

  * The array items returned by `enter`, `move`, `leave` contain the following contents: `unit`, `x`, `y`.

  * `unit` can be `String`、`Number`、`Table` type, but these requirements must be met: `unit1 == unit1` and `unit1 == unit2`.

#### Algorithm complexity

  * Positioning a `unit` is generally O(1). (use hash table).

  * The complexity of adding a `unit` to `Map` is: O(Log(x)).

  * Depending on the regional `unit` density: dense areas are less than `2ms` and sparse areas are less than `1ms`.

#### License

  [MIT](https://github.com/CandyMi/aoi/blob/master/LICENSE)
