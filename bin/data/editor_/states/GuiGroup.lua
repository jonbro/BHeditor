GuiGroup = class(Group, function(o, x, y, w, h, p)
	Group.init(o)
	x = x or 0
	y = y or 0
	w = w or bludG.camera.w
	h = h or bludG.camera.h
	o.paddingL = p or 20
	o.paddingR = o.paddingL
	o.bg = o:add(OverlayObj(x,y,w,h))
	o.bg:setColor(0,0,0,100)
	o.lastPos = Rectangle(x, y, 0, 0)
	o.controls = o:add(Group())
end)
function GuiGroup:draw()
	Group.draw(self)
	-- bg:drawRect(0,0,20, 20)
end
function GuiGroup:addDown(obj)
	obj:setPosition(self.lastPos.pos.x+self.paddingL, self.lastPos.pos.y+self.lastPos.h+self.paddingL)
	local c = self.controls:add(obj)
	self:setLastObj(obj)
	return c
end
function GuiGroup:setLastObj(obj)
	self.lastPos.pos.x, self.lastPos.pos.y, self.lastPos.w, self.lastPos.h = obj.pos.x-self.paddingL, obj.pos.y, obj.w, obj.h
end
function GuiGroup:slider(h, min, max, value, label)
	return Slider(0,0,self.bg.w-(self.paddingL+self.paddingR), h, min, max, value, label, function(l, v)
		if self.valueChange then self:valueChange(l, v) end
	end)
end
function GuiGroup:label(label)
	local s_obj = StringObject(0,0,label)
	s_obj:setLayer(1)
	return s_obj
end
function GuiGroup:button(h, label)
	local s_obj = UIButton(0,0,self.bg.w-(self.paddingL+self.paddingR), h, label, function(l, v)
		if self.valueChange then self:valueChange(l, v) end
	end)
	s_obj:setLayer(1)
	return s_obj
end
function GuiGroup:textInput(h, label, default)
	local s_obj = UITextInput(0,0,self.bg.w-(self.paddingL+self.paddingR), h, label, default, function(l, v)
		if self.valueChange then self:valueChange(l, v) end
	end)
	s_obj:setLayer(1)
	return s_obj
end
function GuiGroup:load(data)
	-- this is where magic happens, call the 'normal behaivor'
	-- for each of the values in the datafile, find the corrosponding control, and set its value
	for k,v in pairs(data) do
		for i,c in ipairs(self.controls.members) do
			if c.getName and c:getName() == k then
				if c.setValue then 
					c:setValue(v)
				end
				break;
			end
		end
	end
end
function GuiGroup:save()
	local rData = {}
	for i,c in ipairs(self.controls.members) do
		if c.getName and c.getValue then
			rData[c:getName()] = c:getValue()
		end
	end	
	return rData
end
ScrollableGuiGroup = class(GuiGroup, function(o, x, y, w, h, p)
	GuiGroup.init(o, x, y, w, h, p)
	o.paddingR = o.paddingL+20
	o.bounds = Rectangle(x, y, w, h)
	o.camera = Camera(x, y, w, h)
	-- add a VSlider on the side
	o.scrollSlider = o:add(VSlider(x+w-20,0,20,h,0,1,0,nil,function(l,v)
		o:scroll(v)
	end))
	o.scrollSlider.bgColor = {0,0,0,100}
end)

function ScrollableGuiGroup:addDown(obj)
	obj = GuiGroup.addDown(self,obj)
	obj:setCamera(self.camera)
	self.bounds.h = obj.pos.y+obj.h-self.bounds.pos.y
	return obj
end
function ScrollableGuiGroup:scroll(value)
	self.camera.scroll.y = value*(self.bounds.h-self.bounds.pos.y-self.bg.h+self.paddingL)
end
-- mainState = WrapperState(ScrollableGuiGroup(0,0,bludG.camera.w/3, bludG.camera.h));
