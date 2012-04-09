-- an area that handles drags that start within it
DragArea = class(Button, function(o,x,y,w,h)
	Button.init(o,x,y,w,h)
	o.lastPos = {}
  o.fingerCount = 0
end)
function DragArea:touchDown(x, y, id)
  if Rectangle.doesPointTouch(self, Vec2(x, y)) then
    self.fingerDown[id] = true
    self.lastPos[id] = Vec2(x, y)
    self.fingerCount = self.fingerCount + 1
    if self.onStart then return self.onStart(self,x, y, id) end
  end
  -- allow bubbling to continue
  return true
end
function DragArea:touchMoved(x,y,id)
	if self.fingerDown[id] then
    	if self.onMove then
	    	local r_val = self.onMove(self,x,y,id)
	    end
  		self.lastPos[id] = Vec2(x, y)
	    return true
  	end
	return true
end
function DragArea:touchUp(x, y, id)
  -- commit when the finger goes up, even if it is not within the button
  if self.fingerDown[id] then
    self.fingerDown[id] = nil
    self.fingerCount = self.fingerCount - 1
    if self.onPress then return self.onPress(self, x, y, id) end  
    return true
  end
  self.fingerDown[id] = nil
  return true
end
function DragArea:draw()
	-- don't do anything, keep it blank
  if self.sprite then
	 Object.draw(self)
  end
end

CameraDragArea = class(DragArea, function(o, x, y, w, h)
  DragArea.init(o,x,y,w,h)
end)

function CameraDragArea:touchDown(x, y, id)
  local cameras = self.cameras or bludG.cameras
  -- store the starting position of the button
  local pos = Vec2(self.pos.x, self.pos.y)
  for i,v in ipairs(cameras) do
    -- move the position to where the camera has it
    self.pos.x, self.pos.y = self:getCameraOffset(v)
    if Rectangle.doesPointTouch(self, Vec2(x, y)) then
      self.fingerDown[id] = true
      self.lastPos[id] = Vec2(x, y)
      self.fingerCount = self.fingerCount + 1
      if self.onStart then return self.onStart(self,x, y, id) end
    end
    --reset the original position
    self.pos.x, self.pos.y = pos.x, pos.y
    -- allow bubbling to continue    
  end
  return true
end
function CameraDragArea:touchMoved(x,y,id)
  if self.fingerDown[id] then
      if self.onMove then
        local r_val = self.onMove(self,x,y,id)
      end
      self.lastPos[id] = Vec2(x, y)
      return true
    end
  return true
end
function CameraDragArea:touchUp(x, y, id)
  -- commit when the finger goes up, even if it is not within the button
  if self.fingerDown[id] then
    self.fingerDown[id] = nil
    self.fingerCount = self.fingerCount - 1
    if self.onPress then return self.onPress(self, x, y, id) end  
    return true
  end
  self.fingerDown[id] = nil
  return true
end
