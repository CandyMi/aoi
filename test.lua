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

print("10000 leave from [1], [1], The number of units within the radius is: "..#m:leave(10000))

print("The total number of people in the map is: "..m:members())m:dumps()

print("-----")

print("10001 leave from [15], [15], The number of units within the radius is: "..#m:leave(10001))

print("The total number of people in the map is: "..m:members())m:dumps()

print("-----")

print("10002 leave from [25], [25], The number of units within the radius is: "..#m:leave(10002))

print("The total number of people in the map is: "..m:members())m:dumps()

print("-----")
