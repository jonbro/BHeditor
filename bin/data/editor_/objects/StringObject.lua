StringObject = class(Object, function(o, x, y, string, font)
	o.font = font or "_anonymous_20"
	o.string = tostring(string)
	Object.init(o, x, y, 0, 0)
	-- should build all the subobjs here, and then just loop them in draw... something to do in the future
	StringObject.buildSubs(o)
	o.last = {}	
end)

function StringObject:buildSubs()
	self.subs = {}
	-- print("building subs")
	local o = Object(self.pos.x, self.pos.y, 0, 0)
	local h = 0
	local left = self.pos.x
	for i=1,#self.string do
		o = Object(left, self.pos.y, 0, 0)
		o.tint = self.tint
		o.scrollFactor = self.scrollFactor
		o.layer = self.layer
		o.sprite = sprites["tiles"][self.string:byte(i) .. self.font .. ".png"]
		if self.cameras then o:setCamera(self.cameras[1]) end
		if o.sprite then
			o.w = o.sprite:getWidth()
			o.h = o.sprite:getHeight()
			h = math.max(o.h, h)
			table.insert(self.subs, o)
			left = left + o.w
		elseif self.string:byte(i) == 32 then
			left = left + sprites["tiles"]["88" .. self.font .. ".png"]:getWidth()
		else
			print("missing char: " .. self.string:byte(i) .. self.font .. ".png")
		end
	end
	self.w = o.pos.x + o.w - self.pos.x
	self.h = h
end
-- runs params though the proper updaters if they have changed
function StringObject:update()
	if not self.last or not self.last.tint or not self.last.tint.r or self.last.tint.r ~= self.tint.r or self.last.tint.g ~= self.tint.g or self.last.tint.b ~= self.tint.b or self.last.tint.a ~= self.tint.a then
		self:setColor(self.tint.r, self.tint.g, self.tint.b, self.tint.a)
	end
	if not self.last.pos or self.last.pos ~= self.pos then
		self:setPosition(self.pos.x, self.pos.y)
	end
	if self.subs then
		for i,v in ipairs(self.subs) do
			v:update()
		end
	end
end
function StringObject:setCamera(camera)
	self.cameras = {camera}
	for i,v in ipairs(self.subs) do
		v:setCamera(camera)
	end
end

function StringObject:setPosition(x, y)
	-- we don't need to rebuild the text necessarily, just go through all of it and set it to the new position
	if self.subs then
		local posDiff = Vec2(x, y)
		if self.last and self.last.pos then
			posDiff:sub(self.last.pos)
		else
			posDiff:sub(self.pos)
		end
		for i,v in ipairs(self.subs) do
			v:setPosition(v.pos.x+posDiff.x, v.pos.y+posDiff.y)
		end
		Object.setPosition(self, x, y)
	else
		Object.setPosition(self, x, y)
		self:buildSubs()
	end
	if self.last then
		self.last.pos = Vec2(self.pos.x, self.pos.y)
	end
	-- it appears there is the expectation that this will reset the layer of the string. Rather than refactoring the code, will add a fix here
	self:setLayer(self.layer)
	self:setScrollFactor(self.scrollFactor)
end
function StringObject:setColor(r,g,b,a)
	self.tint.r = r;
	self.tint.g = g;
	self.tint.b = b;
	self.tint.a = a or 255;
	for i,v in ipairs(self.subs) do
		v:setColor(r,g,b,a)
	end
	if not self.last.tint then
		self.last.tint = {r=self.tint.r, r=self.tint.g, b=self.tint.b, a=self.tint.a}
	else
		self.last.tint.r, self.last.tint.g, self.last.tint.b, self.last.tint.a = self.tint.r, self.tint.g, self.tint.b, self.tint.a
	end
end
function StringObject:setLayer(layer)
	self.layer = layer
	if self.subs then
		for i,v in ipairs(self.subs) do
			v.layer = layer
		end
	end
end
function StringObject:setScrollFactor(scrollFactor)
	self.scrollFactor = scrollFactor
	if self.subs then
		for i,v in ipairs(self.subs) do
			v.scrollFactor = scrollFactor
		end
	end
end
function StringObject:draw()
	local ipairs = ipairs
	for i,v in ipairs(self.subs) do
		v:draw()
	end
end
function StringObject:setValue(value)
	self.string = tostring(value)
	self:buildSubs()
end