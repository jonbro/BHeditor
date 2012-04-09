-- a camera button with a bit of text on it
UIButton = class(CameraTextButton, function(o, x, y, w, h, text, callback)
  CameraTextButton.init(o, x, y, w, h, text)
  if callback then
    o.onPress = function()
      callback(text)
    end
  end
end)
function UIButton:setPosition(x,y)
  CameraTextButton.setPosition(self,x,y)
  if self.text then
    self.text:setPosition(self.pos.x+self.w/2-self.text.w/2, self.pos.y+self.h/2-self.text.h/2)
  end
end
function UIButton:setCamera(camera)
  Object.setCamera(self, camera)
  if self.text then self.text:setCamera(camera) end
end