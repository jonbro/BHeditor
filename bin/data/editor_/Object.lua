OVERLAP_BIAS = 1

Object = class(Rectangle, function(o, x, y, width, height)
  Rectangle.init(o, x, y, width, height)
  o.last = Vec2(o.pos.x, o.pos.y)
  o.alive = true
  o.exists = true
  o.scrollFactor = Vec2(1, 1)
  o.offset = Vec2(0,0)
  o.immovable = true
  o.moves = false
  o.velocity = Vec2(0,0)
  o.acceleration = Vec2(0,0)
  o.drag = Vec2(0,0)
  o.touching = {}
  o.elasticity = 0
  o.allowCollisions = {LEFT=true, RIGHT=true, UP=true, DOWN=true}
  o.tint = {r=255, g=255, b=255, a=255}
  o.layer = 0
  o.sheet = sheets['tiles']
end)
function Object:setScrollFactor(scrollFactor)
  self.scrollFactor = scrollFactor
end
function Object:setColor(r,g,b,a)
  self.tint.r = r;
  self.tint.g = g;
  self.tint.b = b;
  self.tint.a = a or 255
end
function Object:setLayer(layer)
  self.layer = layer
end
function Object:draw()
  local cameras = self.cameras or bludG.cameras
  if not self.cam then
    self.cam = Rectangle(0, 0, bludG.camera.w, bludG.camera.h)
  end
  if self.drawType and self.drawType == "stretched" then
    return self:drawStretched()
  end
  local flip = 0
  if self.flip then flip = self.flip end
  if self.sprite then
    -- loop through all the cameras
    for i,camera in pairs(cameras) do
      local px, py = self.pos.x, self.pos.y
      self.pos.x, self.pos.y = self:getCameraOffset(camera)
      -- draw the sprite if it is on the current camera
      if self:doesRectangleTouch(self.cam) or self.forceDraw then
        -- calculate the position on the current camera
        self.sheet:addTile(self.sprite, self.pos.x, self.pos.y, self.layer, flip, self.tint.r, self.tint.g, self.tint.b, self.tint.a)
      end
      self.pos.x, self.pos.y = px, py
    end
  else
    Rectangle.draw(self)
  end
end
function Object:center()
  return Vec2(self.pos.x+self.w/2, self.pos.y+self.h/2)
end

function Object:drawStretched(asLine, w)
  -- print(self)
  local cameras = self.cameras or bludG.cameras
  if not self.cam then
    self.cam = Rectangle(0, 0, bludG.camera.w, bludG.camera.h)
  end
  local flip = 0
  if self.flip then flip = self.flip end

  if self.sprite then
  -- loop through all the cameras
    -- print(bludG.camera.scale)
    for i,camera in pairs(cameras) do
      -- print(camera.scale)
      local px, py, pw, ph = self.pos.x, self.pos.y, self.w, self.h
      self.pos.x, self.pos.y, self.w, self.h = Object.getCameraOffsetZoom(self, camera)
      -- self.pos.x, self.pos.y = self.pos.x*camera.scale, self.pos.y*camera.scale
      -- draw the sprite if it is on the current camera
      local cam = Rectangle(0, 0, camera.w, camera.h)
      -- don't want to manage a culling system for lines just yet. May deal with this soon.
      if self:doesRectangleTouch(camera) or asLine or self.forceDraw then
        -- calculate the position on the current camera
        local c = {self.pos.x, self.pos.y, self.w, self.h}
        local tl = {c[1], c[2]}
        local tr = {c[1]+c[3], c[2]}
        local bl = {c[1], c[2]+c[4]}
        local br = {c[1]+c[3], c[2]+c[4]}
        if asLine then
          self.sheet:addCornerTile(self.sprite, tl[1],tl[2], tl[1]+w,tl[2]+w, br[1],br[2], br[1]+w,br[2]+w, self.layer, flip, self.tint.r, self.tint.g, self.tint.b, self.tint.a)
        else
          self.sheet:addCornerTile(self.sprite, tl[1],tl[2], tr[1],tr[2], br[1],br[2], bl[1],bl[2], self.layer, flip, self.tint.r, self.tint.g, self.tint.b, self.tint.a)
        end
      end
      self.pos.x, self.pos.y, self.w, self.h = px, py, pw, ph
    end
  end  
end
function Object:drawLine(p1, p2, w)
  w = w or 1
  local px, py, pw, ph = self.pos.x, self.pos.y, self.w, self.h
  self.pos.x, self.pos.y, self.w, self.h = p1.x, p1.y, p2.x-p1.x, p2.y-p1.y
  Object.drawStretched(self, true, w)
  self.pos.x, self.pos.y, self.w, self.h = px, py, pw, ph
end
function Object:getCameraOffset(camera)
  _x = (self.pos.x - (camera.scroll.x*self.scrollFactor.x) - self.offset.x) + camera.pos.x
  _y = (self.pos.y - (camera.scroll.y*self.scrollFactor.y) - self.offset.y) + camera.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  return _x, _y
end

function Object:getCameraOffsetZoom(camera)
  local scaleDiff = camera.scale-1
  _x = (self.pos.x - (camera.scroll.x*self.scrollFactor.x) - self.offset.x)*(1+scaleDiff*self.scrollFactor.x) + camera.pos.x
  _y = (self.pos.y - (camera.scroll.y*self.scrollFactor.y) - self.offset.y)*(1+scaleDiff*self.scrollFactor.y) + camera.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  local _w = self.w*(1+scaleDiff*self.scrollFactor.x)
  local _h = self.h*(1+scaleDiff*self.scrollFactor.y)
  return _x, _y, _w, _h
end

----------------------------------------
-- this is a physics managing updater --
----------------------------------------
function calcDrag(v, d)
  if v - d > 0 then
    v = v - d
  elseif v + d < 0 then
    v = v + d
  else
    v = 0
  end
  return v
end
function calcMax(v, m)
  if v ~= 0 then
    if v > m then
      v = m
    elseif v<-m then
      v=-m
    end
  end
  return v
end
function computeVelocity(v, a, d, m)
  if a ~= 0 then
    v = v + a * bludG.elapsed
  end
  if d ~= 0 then
    v = calcDrag(v, d*bludG.elapsed)
  end
  if v ~= 0 and m then
    v = calcMax(v, m)
  end
  return v
end

function Object:update()
  self.touching = {}
  if self.moves then
    self.last = Vec2(self.pos.x, self.pos.y)
    local dx = nil 
    local dy = nil 
    local mx, my = nil, nil
    if self.drag then dx, dy = self.drag.x, self.drag.y end
    if self.maxVelocity then mx, my = self.maxVelocity.x, self.maxVelocity.y end

    -- compute x component
    local vc = (computeVelocity(self.velocity.x, self.acceleration.x, dx, mx)-self.velocity.x)/2
    self.velocity.x = self.velocity.x + vc
    local xd = self.velocity.x*bludG.elapsed
    self.velocity.x = self.velocity.x + vc

    -- compute y component
    vc = (computeVelocity(self.velocity.y, self.acceleration.y, dy, my)-self.velocity.y)/2
    self.velocity.y = self.velocity.y + vc
    local yd = self.velocity.y*bludG.elapsed
    self.velocity.y = self.velocity.y + vc

    self.pos.x = self.pos.x + xd
    self.pos.y = self.pos.y + yd
  end
end

function Object:overlap(other, ...)
  local arg = {...}
  notifyCallback = arg[1]
  processCallback = arg[2]
  if other:is_a(Group) then
    return other:overlap(self, unpack(arg))
  else
    if self.alive then
      -- check to see if we are doing circle circle collision
      if self:is_a(CenteredObject) and other:is_a(CenteredObject) then
        -- check the distance between the centers
        if self.pos:distance(other.pos) < self.w/2+other.w/2 then
          if processCallback then processCallback(self, other) end
          if notifyCallback then notifyCallback(self, other) end
          return true
        end
      elseif Rectangle.doesRectangleTouch(self, other) then
        if processCallback then processCallback(self, other) end
        if notifyCallback then notifyCallback(self, other) end
        return true
      end
    end
  end
  return false
end
function Object:kill()
  self.alive = false
  self.exists = false
end
function Object:setCamera(camera)
  self.cameras = {camera}
end

---------------------
-- PHYSICS HELPERS --
---------------------

function Object.separate(Object1, Object2)
  local separatedY = Object.separateY(Object1, Object2)
  local separatedX = Object.separateX(Object1, Object2)
  return separatedX or separatedY;
end
function Object.separateX(Object1, Object2)
  -- if both of the objects are immovable, then we can't separate them
  if Object1.immovable and Object2.immovable then
    return false
  end
  local overlap = 0
  local obj1Delta = Object1.pos.x - Object1.last.x
  local obj2Delta = Object2.pos.x - Object2.last.x
  if obj1Delta ~= obj2Delta then
    local obj1DeltaAbs = math.abs(obj1Delta)
    local obj2DeltaAbs = math.abs(obj2Delta)
    -- build the xHulls using the sizes produced by the deltas... should account for tunneling
    local obj1Rect = Rectangle( Object1.pos.x - math.max(0, obj1Delta), Object1.last.y, Object1.w+obj1DeltaAbs, Object1.h )
    local obj2Rect = Rectangle( Object2.pos.x - math.max(0, obj2Delta), Object2.last.y, Object2.w+obj2DeltaAbs, Object2.h )
    -- check to see if the hulls overlap
    if (obj1Rect.pos.x + obj1Rect.w > obj2Rect.pos.x) and (obj1Rect.pos.x < obj2Rect.w + obj2Rect.pos.x) and (obj1Rect.pos.y + obj1Rect.h > obj2Rect.pos.y) and (obj1Rect.pos.y < obj2Rect.h + obj2Rect.pos.y) then
      local maxOverlap = obj1DeltaAbs + obj2DeltaAbs + OVERLAP_BIAS
      -- if object1 is moving to the right
      if obj1Delta > obj2Delta then
        overlap = Object1.pos.x + Object1.w - Object2.pos.x
        if overlap > maxOverlap or Object1.allowCollisions.RIGHT ~= true or Object2.allowCollisions.LEFT ~= true then
          overlap = 0
        else
          Object1.touching.RIGHT = true
          Object2.touching.LEFT = true
          if not Object1.touching.other then Object1.touching.other = {} end
          if not Object2.touching.other then Object2.touching.other = {} end
          table.insert(Object1.touching.other, Object2)
          table.insert(Object2.touching.other, Object1)
        end
      elseif obj1Delta < obj2Delta then
        -- if obect 1 is moving to the left
        overlap = Object1.pos.x - Object2.w - Object2.pos.x
        if -overlap > maxOverlap or Object2.allowCollisions.RIGHT ~= true or Object1.allowCollisions.LEFT ~= true then
          overlap = 0
        else
          Object1.touching.LEFT = true
          Object2.touching.RIGHT = true
          if not Object1.touching.other then Object1.touching.other = {} end
          if not Object2.touching.other then Object2.touching.other = {} end
          table.insert(Object1.touching.other, Object2)
          table.insert(Object2.touching.other, Object1)
        end
      end

    end
  end

  -- adjust the objects positions and velocities to account for the overlap
  if overlap ~= 0 then
    local obj1v = Object1.velocity.x
    local obj2v = Object2.velocity.x
    if Object1.immovable ~= true and Object2.immovable ~= true then
       overlap = overlap*0.5
       Object1:setPosition(Object1.pos.x-overlap, Object1.pos.y)
       Object2:setPosition(Object2.pos.x+overlap, Object1.pos.y)
    elseif Object1.immovable ~= true then
      Object1:setPosition(Object1.pos.x-overlap, Object1.pos.y)
      Object1.velocity.x = obj2v - obj1v*Object1.elasticity
    elseif Object2.immovable ~= true then
      Object2:setPosition(Object2.pos.x+overlap, Object2.pos.y)
      Object2.velocity.x = obj1v - obj2v*Object2.elasticity
    end
    return true
  else
    return false
  end
end

function Object.separateY(Object1, Object2)
  -- if both of the objects are immovable, then we can't separate them
  if Object1.immovable and Object2.immovable then
    return false
  end
  local overlap = 0
  local obj1Delta = Object1.pos.y - Object1.last.y
  local obj2Delta = Object2.pos.y - Object2.last.y
  if obj1Delta ~= obj2Delta then
    local obj1DeltaAbs = math.abs(obj1Delta)
    local obj2DeltaAbs = math.abs(obj2Delta)
    -- build the xHulls using the sizes produced by the deltas... should account for tunneling
    local obj1Rect = Rectangle( Object1.pos.x, Object1.pos.y - math.max(obj1Delta, 0), Object1.w, Object1.h+obj1DeltaAbs)
    local obj2Rect = Rectangle( Object2.pos.x, Object2.pos.y - math.max(obj2Delta, 0), Object2.w, Object2.h+obj2DeltaAbs)
    -- check to see if the y hulls overlap
    if (obj1Rect.pos.x + obj1Rect.w > obj2Rect.pos.x) and (obj1Rect.pos.x < obj2Rect.w + obj2Rect.pos.x) and (obj1Rect.pos.y + obj1Rect.h > obj2Rect.pos.y) and (obj1Rect.pos.y < obj2Rect.h + obj2Rect.pos.y) then
      local maxOverlap = obj1DeltaAbs + obj2DeltaAbs + OVERLAP_BIAS
      -- if object1 is moving to the right
      if obj1Delta > obj2Delta then
        overlap = Object1.pos.y + Object1.h - Object2.pos.y
        if overlap > maxOverlap or Object1.allowCollisions.DOWN ~= true or Object2.allowCollisions.UP ~= true then
          overlap = 0
        else
          Object1.touching.DOWN = true
          Object2.touching.UP = true
          if not Object1.touching.other then Object1.touching.other = {} end
          if not Object2.touching.other then Object2.touching.other = {} end
          table.insert(Object1.touching.other, Object2)
          table.insert(Object2.touching.other, Object1)
        end
      elseif obj1Delta < obj2Delta then
        -- if obect 1 is moving to the left
        overlap = Object1.pos.y - Object2.h - Object2.pos.y
        if -overlap > maxOverlap or Object2.allowCollisions.DOWN ~= true or Object1.allowCollisions.UP ~= true then
          overlap = 0
        else
          Object2.touching.DOWN = true
          Object1.touching.UP = true
          if not Object1.touching.other then Object1.touching.other = {} end
          if not Object2.touching.other then Object2.touching.other = {} end
          table.insert(Object1.touching.other, Object2)
          table.insert(Object2.touching.other, Object1)
        end
      end

    end
  end
  -- adjust the objects positions and velocities to account for the overlap
  if overlap ~= 0 then
    local obj1v = Object1.velocity.y
    local obj2v = Object2.velocity.y
    if Object1.immovable ~= true and Object2.immovable ~= true then
       overlap = overlap*0.5
       Object1:setPosition(Object1.pos.x, Object1.pos.y-overlap)
       Object2:setPosition(Object2.pos.x, Object1.pos.y+overlap)
    elseif Object1.immovable ~= true then
      Object1:setPosition(Object1.pos.x, Object1.pos.y-overlap)
      Object1.velocity.y = obj2v - obj1v*Object1.elasticity
    elseif Object2.immovable ~= true then
      Object2:setPosition(Object2.pos.x, Object2.pos.y+overlap)
      Object2.velocity.y = obj1v - obj2v*Object2.elasticity
    end
    return true
  else
    return false
  end
end


---------------------
-- CENTERED OBJECT --
---------------------
-- for all intents, this behaves as a rectangle with the physics
-- it may be interesting to add some physics to manage this
-- but I am not sure, due to complexity spiraling out of control

CenteredObject = class(Object, function(o, x, y, width, height)
  Object.init(o, x, y, width, height)
  o.scale = 1
  o.rot = 0
end)
function CenteredObject:draw()
  local flip = 0
  if self.flip then flip = self.flip end
  if self.sprite then
    local cameras = self.cameras or bludG.cameras

    -- loop through all the cameras
    for i,camera in pairs(cameras) do
      local pos = Vec2(self.pos.x, self.pos.y)
      self.pos.x, self.pos.y = self:getCameraOffset(camera)
      -- draw the sprite if it is on the current camera
      if self:doesRectangleTouch(camera) or self.forceDraw then
        -- calculate the position on the current camera
        self.sheet:addCenterRotatedTile(self.sprite, self.pos.x, self.pos.y, self.layer, flip, self.scale, self.rot, self.tint.r,self.tint.g,self.tint.b, self.tint.a)
      end
      self.pos.x, self.pos.y = pos.x, pos.y
    end
  else
    Rectangle.draw(self)
  end
end