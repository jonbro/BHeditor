UITextInput = class(CameraTextButton, function(o, x, y, w, h, label, value, callback)
	CameraTextButton.init(o, x, y, w, h, "")
	o.hasFocus = false
	
	o.labelText = label
  	if o.labelText then
  		o.label = StringObject(x, y+h, label)
  		o.label:setLayer(1)
  	end
  	o.callback = callback
	o:setColor(255, 255, 255, 200)
	-- this control should probably have a label
end)
function UITextInput:draw()
	CameraTextButton.draw(self)
	if self.label then self.label:draw() end
end
function UITextInput:setValue(nval)
	self.value = nval
	self.text:setValue(nval)
	if self.callback then
		self.callback(self.labelText, self.value)
	end
end
function UITextInput:setPosition(x, y)
	CameraTextButton.setPosition(self,x, y)
	if self.label then self.label:setPosition(x, y+self.h) end
end
function UITextInput:getName(nval)
	return self.labelText
end
function UITextInput:touchDown(x, y, id)
	self.hasFocus = false
	self:setColor(255, 255, 255, 200)
	CameraTextButton.touchDown(self, x, y, id)
end
function UITextInput:onPress(x, y, id)
	self.hasFocus = true
	self:setColor(200, 200, 255, 200)
	-- should place the cursor based on the position here
	-- this is when we support cursors of course
end
function UITextInput:setCamera(camera)
	CameraTextButton.setCamera(self, camera)
	if self.label then self.label:setCamera(camera) end
	if self.text then 
		print('setting camera')
		self.text:setCamera(camera)
	end
end
function UITextInput:keyPressed(key)
	if self.hasFocus then
		-- backspace
		if key == 127 then
			self:setValue(string.sub(self.text.string, 1, #self.text.string-1))
		else
			self:setValue(self.text.string .. string.char(key))
		end
	end
end
