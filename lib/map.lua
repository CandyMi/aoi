local class = require "class"

local new_tab = function (asize, hsize) return {} end
local ok, sys = pcall(require, "sys")
if ok and type(sys) == table then
  new_tab = sys.new_tab or function (asize, hsize) return {} end
end

local type = type
local error = error
local pairs = pairs
local print = print
local ipairs = ipairs
local assert = assert

local abs = math.abs
local toint = math.tointeger

local tadd = table.insert
local tremove = table.remove

--** pack与unpack位置信息, 主要用来减少hash表内存占用 **--
local Bit = 16
local xBit, yBit = Bit, Bit - Bit
local function XY_TO_POS (x, y)
  return (x << xBit) | (y << yBit)
end

local function POS_TO_XY (pos)
  return (pos >> xBit) & (2 ^ Bit - 1), (pos >> yBit) & (2 ^ Bit - 1)
end
--** pack与unpack位置信息, 主要用来减少hash表内存占用 **--

--** units管理方法 **--
local function add_unit (units, unit, x, y)
  units[unit] = XY_TO_POS(x, y)
end

local function get_unit (units, unit)
  local pos = units[unit]
  if not pos then
    return
  end
  return POS_TO_XY(pos)
end

local function update_unit (units, unit, x, y)
  units[unit] = XY_TO_POS(x, y)
end

local function remove_unit (units, unit)
  units[unit] = nil
end
--** units管理方法 **--

--** 地图管理: 包括创建、增加对象、删除对象、范围计算与查找 **--
local units = -1

-- 创建地图
local function new_map (X, Y)
  local map = new_tab(Y, 0)
  for y = 0, Y - 1 do
    map[y] = {[units] = 0}
  end
  return map
end

-- 添加单位
local function add_map(map, unit, x, y)
  local xMap = map[y]
  xMap[units] = xMap[units] + 1 -- 计数器增加
  local mesh = xMap[x]
  if mesh then
    return tadd(mesh, unit)
  end
  xMap[x] = {unit}
end

-- 移除单位
local function remove_map(map, unit, x, y)
  local xMap = map[y]
  xMap[units] = xMap[units] - 1 -- 计数器减少
  local mesh = xMap[x]
  if mesh then
    if #mesh == 1 then
      local u = tremove(mesh)
      xMap[x] = nil
      return u
    end
    for index, u in ipairs(mesh) do
      if u == unit then
        return tremove(mesh, index)
      end
    end
  end
  return error("发现一个找不到对象的错误")
end

-- 更新单位
local function update_map (map, unit, oldX, oldY, newX, newY)
  return remove_map(map, unit, oldX, oldY), add_map(map, unit, newX, newY)
end

-- 获取单位半径内列表
local function range_by_unit (self, unit, x, y, r)
  local map = self.map
  local radius = r or self.radius
  local MinX, MaxX = x - radius > 0 and x - radius or 0, x + radius < self.X and x + radius or self.X - 1
  local MinY, MaxY = y - radius > 0 and y - radius or 0, y + radius < self.Y and y + radius or self.Y - 1
  local units = {}
  for Y = MinY, MaxY do
    for X, mesh in pairs(map[Y]) do
      if X >= MinX and X <= MaxX then
        for _, u in ipairs(mesh) do
          if u ~= unit then
            tadd(units, {unit = u, x = X, y = Y})
          end
        end
      end
    end
  end
  return units
end
--** 地图管理: 包括创建、增加对象、删除对象、范围计算与查找 **--

--** 检查是否超出地图取值范围 **--
local function outRange (A, B)
  local a, b = toint(A), toint(B)
  if not a or not b then
    return true
  end
  if a < 0 or a >= b then
    return true
  end
  return false
end

local Map = class("__Map__")

function Map:ctor (opt)
  self.radius = assert(opt and opt.radius and toint(opt.radius) or 15, "Map需要知道radius的整数范围")
  self.X = assert(opt.x and toint(opt.x) and toint(opt.x) > 0 and toint(opt.x), "Map需要知道X轴的整数取值范围")
  self.Y = assert(opt.y and toint(opt.y) and toint(opt.y) > 0 and toint(opt.y), "Map需要知道Y轴的整数取值范围")
  self.units = new_tab(0, 1024)
  self.map = new_map(self.X, self.Y)
end

-- 获取指定单位位置
function Map:get_pos_by_unit (unit)
  if not unit then
    return error("unit必须是一个有效的类型")
  end
  local X, Y = get_unit(self.units, unit)
  if not X or not Y then
    return nil, "试图获取一个不存在单位位置"
  end
  return X, Y
end

-- 获取指定范围内的单位
function Map:get_pos_by_range (x, y, radius)
  if outRange(x, self.X) or outRange(y, self.Y) then
    return error("进入失败: 错误的X或Y值.")
  end
  return range_by_unit(self, nil, x, y, radius)
end

-- 进入
function Map:enter (unit, x, y)
  if outRange(x, self.X) or outRange(y, self.Y) then
    return error("进入失败: 错误的X或Y值.")
  end
  if self.units[unit] then
    return error("进入失败: units中已经存在此单位")
  end
  add_unit(self.units, unit, x, y)
  add_map(self.map, unit, x, y)
  return range_by_unit(self, unit, x, y)
end

-- 移动
function Map:move (unit, newX, newY)
  if outRange(newX, self.X) or outRange(newY, self.Y) then
    return error("移动失败: 错误的X或Y值.")
  end
  local oldX, oldY = get_unit(self.units, unit)
  if not oldX or not oldY then
    return error("移动失败: units中无法找到此单位")
  end
  update_unit(self.units, unit, newX, newY)
  update_map(self.map, unit, oldX, oldY, newX, newY)
  return range_by_unit(self, unit, newX, newY, self.radius + (abs(newX - oldX) > abs(newY - oldY) and abs(newX - oldX) or abs(newY - oldY)))
end

-- 离开
function Map:leave (unit)
  local x, y = get_unit(self.units, unit)
  if not x or not y then
    return error("离开失败: units中无法找到此单位")
  end
  remove_map(self.map, unit, x, y)
  remove_unit(self.units, unit)
  return range_by_unit(self, unit, x, y)
end

-- 地图单位总数量
function Map:members ()
  local count = 0
  local map = self.map
  for index = 0, self.Y - 1 do
    count = count + map[index][units]
  end
  return count
end

-- 打印地图内所有单位的位置
function Map:dumps ()
  local map = self.map
  for Y = 0, self.Y - 1 do
    for X, mesh in pairs(map[Y]) do
      if X > 0 then
        for _, u in ipairs(mesh) do
          print("unit = ["..u.."], Y = ["..Y.."], X = ["..X.."]")
        end
      end
    end
  end
end

return Map
