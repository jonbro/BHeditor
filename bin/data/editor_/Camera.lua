-- we continue to half assedly rip stuff from flixel, realizing that we need it slightly after it would have been useful, and requiring backtracking. yay!

Camera = class(Rectangle, function(o, x, y, width, height)
  Rectangle.init(o, x, y, width, height)
  o.scroll = Vec2(0,0)
  o.scale = 1
end)
function Camera:getOffset(x, y)
  _x = x - self.scroll.x + self.pos.x
  _y = y - self.scroll.y + self.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  return _x, _y
end
function Camera:scrollTo(x, y)
  self.scroll.x, self.scroll.y = x, y
end

-- tell if the rectangle is on the screen
function Camera:isPointOnScreen(point)
  _x = point.x + self.scroll.x - self.pos.x
  _y = point.x + self.scroll.y - self.pos.y
  return _x > 0 and _y > 0 and _x < self.w and _y < self.h
end

-- works the opposite of getOffset, gives the actual value in the world being displayed by the camera
function Camera:getPosition(x, y)
  _x = x + self.scroll.x - self.pos.x
  _y = y + self.scroll.y - self.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  return _x, _y
end
function Camera:getPositionZoom(x, y)
  _x = x + self.scroll.x*self.scale - self.pos.x
  _y = y + self.scroll.y*self.scale - self.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  return _x/self.scale, _y/self.scale
end

function Camera:update()
  if self.follow then
    self.scroll.x, self.scroll.y = self.follow.pos.x+self.follow.w/2-self.w/2, self.follow.pos.y+self.follow.h/2-self.h/2
  end
end

