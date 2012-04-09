Slider = class(CameraDragArea, function(o, x, y, w, h, min, max, value, label, callback)
	DragArea.init(o, x, y, w, h)
	o.bgColor = {255,255,255,100}
	o.color = {255, 255, 255, 190}
	o.sprite = sprites['tiles']['white.png']
  	o.drawType = 'stretched'
  	o.min = min or 0
  	o.max = max or 1
  	o.value = value or (o.max-o.min)*0.5+o.min
  	Object.setLayer(o, 1)
  	o.labelText = label
  	if o.labelText then
  		o.label = StringObject(x, y+h, label..": "..o.value)
  		o.label:setLayer(1)
  	end
  	o.callback = callback
end)
function Slider:draw()
	local ow = self.w
	self:setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
	Object.draw(self)
	self:setColor(self.color[1], self.color[2], self.color[3], self.color[4])
	self.w = (self.value-self.min)/(self.max-self.min)*self.w
	Object.draw(self)
	self.w = ow
	if self.label then
		self.label:draw()
	end
end
function Slider:setLayer(layer)
	self:setLayer(layer)
	self.label:setLayer(layer)
end
function Slider:onMove(x, y, id)
	if self.fingerDown[id] then
		x = x - self.pos.x
		self:setValue(math.min(self.max, math.max(self.min, x/self.w * (self.max-self.min)+self.min)))
	end
end
function Slider:getName()
	return self.labelText
end
function Slider:setPosition(x, y)
	Rectangle.setPosition(self,x, y)
	if self.label then self.label:setPosition(x, y+self.h) end
end
function Slider:setCamera(camera)
	Object.setCamera(self, camera)
	if self.label then self.label:setCamera(camera) end
end
function Slider:setValue(nVal)
	self.value = nVal
	if self.label then
		self.label:setValue(self.labelText..": "..self.value)
	end
	if self.callback then
		self.callback(self.labelText, self.value)
	end
end
VSlider = class(CameraDragArea, function(o, x, y, w, h, min, max, value, label, callback)
	Slider.init(o, x, y, w, h, min, max, value, label, callback)
end)
function VSlider:draw()
	local oh = self.h
	self:setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
	Object.draw(self)
	self:setColor(self.color[1], self.color[2], self.color[3], self.color[4])
	self.h = (self.value-self.min)/(self.max-self.min)*self.h
	Object.draw(self)
	self.h = oh
	if self.label then
		self.label:draw()
	end
end
function VSlider:setLayer(layer)
	self:setLayer(layer)
	self.label:setLayer(layer)
end
function VSlider:onMove(x, y, id)
	if self.fingerDown[id] then
		y = y - self.pos.y
		self.value = math.min(self.max, math.max(self.min, y/self.h * (self.max-self.min)+self.min))
		if self.label then
			self.label:setValue(self.labelText..": "..self.value)
		end
		if self.callback then
			self.callback(self.labelText, self.value)
		end
	end
end