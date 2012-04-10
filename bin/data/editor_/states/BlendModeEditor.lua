BlendModeEditor = class(ScrollableGuiGroup, function(o, x, y, w, h)
	ScrollableGuiGroup.init(o, x, y, w, h)

	o:addDown(o:slider(15, 0, 255, 128, "R TOP"))
	o:addDown(o:slider(15, 0, 255, 128, "G TOP"))
	o:addDown(o:slider(15, 0, 255, 128, "B TOP"))
	o:addDown(o:slider(15, 0, 255, 128, "A TOP"))
	for i,v in ipairs({"R", "G", "B", "A"}) do
		o:addDown(o:slider(15, 0, 255, 128, v .. " TOP2"))
	end

	o:addDown(o:slider(15, 0, 6, 1, "BLEND OVER"))
	o:addDown(o:slider(15, 0, 6, 1, "BLEND 2"))

	-- load in the two images
	o.bottom = bludImage()
	o.bottom:load("editor_/assets/underlay_test.png")
	o.bottomSmall = bludImage()
	o.bottomSmall:load("editor_/assets/underlay_test_small.png")
	o.top = bludImage()
	o.top:load("editor_/assets/overlay_test.png")
	o.endColor = {128, 128, 128, 128}
	o.over2Color = {128, 128, 128, 128}
	o.blendOver = 1
	o.blend2 = 1
end)
function BlendModeEditor:draw()
	Group.draw(self)
	bg:setColor(255, 255, 255)
	self.bottom:draw(bludG.camera.w/3, 0)
	bg:setColor(self.endColor[1], self.endColor[2], self.endColor[3], self.endColor[4])
	bg:setBlendMode(self.blendOver)
	self.top:draw(bludG.camera.w/3, 0)
	bg:setBlendMode(self.blend2)
	bg:setColor(self.over2Color[1], self.over2Color[2], self.over2Color[3], self.over2Color[4])
	self.bottomSmall:drawScale(bludG.camera.w/3, 0, 640, 960)
	bg:setBlendMode(1)
end
function BlendModeEditor:valueChange(l, v)
	if l == "R TOP" then
		self.endColor[1] = v
	end
	if l == "G TOP" then
		self.endColor[2] = v
	end
	if l == "B TOP" then
		self.endColor[3] = v
	end
	if l == "A TOP" then
		self.endColor[4] = v
	end
	for i,j in ipairs({"R", "G", "B", "A"}) do
		if l == j .. " TOP2" then
			self.over2Color[i] = v
			break;
		end
	end
	if l == "BLEND OVER" then
		self.blendOver = v
	end
	if l == "BLEND 2" then
		self.blend2 = v
	end
end
mainState = WrapperState(BlendModeEditor(0,0,bludG.camera.w/3, bludG.camera.h));