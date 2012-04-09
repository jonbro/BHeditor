Button = class(Object, function(o, x, y, w, h, sprite)
  Object.init(o, x, y, w, h)
  o.sprite = sprite
  o.fingerDown = {}
  -- default the buttons up, because most, if not all, draw in front of the clouds
  o.layer = 3
  o.fingerCount = 0
end)
function Button:draw()
  if self.sprite then
    Object.draw(self)
  else
    self.sprite = sprites["tiles"]["white.png"]
    Object.drawStretched(self)
    self.sprite = nil
  end
end
function Button:touchDown(x, y, id)
  if Rectangle.doesPointTouch(self, Vec2(x, y)) then
    self.fingerDown[id] = true
    self.fingerCount = self.fingerCount + 1
    if self.noBubble then
      return false
    end
  end
  -- allow bubbling to continue
  return true
end
function Button:touchUp(x, y, id)
  -- don't actually commit the touch unless it starts and ends within the button
  if Rectangle.doesPointTouch(self, Vec2(x, y)) and self.fingerDown[id] then
    self.fingerDown[id] = nil
    self.fingerCount = self.fingerCount - 1
    if self.onPress then 
      playEffect("click")
      return self:onPress()
    end
  end
  self.fingerDown[id] = nil
  return true
end
function Button:clearTouches()
  for i=0,11 do
    if self.fingerDown[i] then
      self.fingerDown[i] = nil
    end
  end
end
-- a button that actually respects its position on the camera
CameraButton = class(Button, function(o, x, y, w, h, sprite)
  Button.init(o, x, y, w, h, sprite)
end)

function CameraButton:touchDown(x, y, id)
  -- store the starting position of the button
  local pos = Vec2(self.pos.x, self.pos.y)
  -- move the position to where the camera has it
  self.pos.x, self.pos.y = self:getCameraOffset(bludG.camera)

  if Rectangle.doesPointTouch(self, Vec2(x, y)) then
    self.fingerDown[id] = true
  end
  --reset the original position
  self.pos.x, self.pos.y = pos.x, pos.y

  -- allow bubbling to continue
  return true
end
function CameraButton:touchUp(x, y, id)
  -- store the starting position of the button
  local pos = Vec2(self.pos.x, self.pos.y)
  -- move the position to where the camera has it
  -- TODO: should check on all the cameras that are on screen
  self.pos.x, self.pos.y = self:getCameraOffset(bludG.camera)
  -- don't actually commit the touch unless it starts and ends within the button
  if Rectangle.doesPointTouch(self, Vec2(x, y)) and self.fingerDown[id] then
    self.fingerDown[id] = nil
    if self.onPress then 
      -- should pass in the finger up position on the current camera
      -- or maybe the current position on the button
      local rval = self:onPress(x, y, id)
      --reset the original position
      self.pos.x, self.pos.y = pos.x, pos.y
      return rval
    end
  end
    --reset the original position
  self.pos.x, self.pos.y = pos.x, pos.y
  self.fingerDown[id] = nil
  return true
end

CenteredButton = class(CenteredObject, function(o, x, y, w, h, sprite)
  CenteredObject.init(o, x, y, w, h)
  o.scrollFactor = Vec2(0, 0)
  o.sprite = sprite
end)
function CenteredButton:touchDown(x, y, id)
  local rect = Rectangle(self.pos.x-self.w/2, self.pos.y-self.h/2, self.w, self.h)
  if rect:doesPointTouch(Vec2(x, y)) then
    if self.onPress then return self.onPress() end
  end
end

TextButton = class(Button, function(o,x,y,w,h,text)
  Button.init(o,x,y,w,h,nil)
  o.text = text
  o.bgColor = {r=255, g=255, b=255}
end)
function TextButton:setBgColor(_r,_g,_b)
  self.bgColor = {r=_r, g=_g, b=_b}
end
function TextButton:draw()
  bbt:setColor(self.bgColor.r,self.bgColor.g,self.bgColor.b);
  bbt:addRect(self.pos.x, self.pos.y, 0, self.w, self.h)
  bg:setColor(0, 0, 0);  
  tb:addText(self.text, self.pos.x+10, self.pos.y+font:getHeight(self.text)+10)
end

OverlayObj = class(Object, function(o, x, y, w, h)
  Object.init(o, x, y, w, h)
  o:setColor(73, 154, 196)
  o.sprite = sprites['tiles']['white.png']
  o.drawType = 'stretched'
  o:setLayer(1)
end)

CameraTextButton = class(CameraButton, function(o, x, y, w, h, text)
  CameraButton.init(o, x, y, w, h)
  o.text = StringObject(x, y, text)
  o.text:setScrollFactor(Vec2(1,1))
  o.text:setColor(0,0,0)
  o:setLayer(1)
end)
function CameraTextButton:setPosition(x,y)
  if self.text then
    self.text:setPosition(x,y)
  end
  CameraButton.setPosition(self,x,y)
end
function CameraTextButton:draw()
  CameraButton.draw(self)
  self.text:draw()
end
function CameraTextButton:setTextColor(r, g, b, a)
  self.text:setColor(r, g, b, a)
end
function CameraTextButton:setLayer(layer)
  Object.setLayer(self, layer)
  if self.text.setLayer then self.text:setLayer(layer) end
end