ParticleEdit = class(ScrollableGuiGroup, function(o, x, y, w, h)
	ScrollableGuiGroup.init(o, x, y, w, h)

	o.particles = ParticleSystem(sprites['tiles']['circle.png'], sheets['tiles'], 100)
	o.particles:start()
	o.particles:setPosition(bludG.camera.w/2, bludG.camera.h/2)
	o.particles:setGravity(1, 20)

	local name = o:addDown(o:textInput(20, "Particle Name"))
	name:setValue(os.time())
	o:addDown(o:button(20,"Save"))

	o:addDown(o:slider(15, 0, 30, 1, "EMISSION"))
	o:addDown(o:slider(15, 0, math.pi*2, 0.5, "SPREAD"))
	o:addDown(o:slider(15, 0, math.pi*2, 0.5, "DIRECTION"))
	o:addDown(o:slider(15, 0, 5, 1, "LIFE MIN"))
	o:addDown(o:slider(15, 0, 5, 1, "LIFE MAX"))

	o:addDown(o:slider(15, 0, 1000, 1, "SPEED MIN"))
	o:addDown(o:slider(15, 0, 1000, 1, "SPEED MAX"))
	o:addDown(o:slider(15, 0, 1000, 1, "GRAVITY MIN"))
	o:addDown(o:slider(15, 0, 1000, 1, "GRAVITY MAX"))

	o:addDown(o:slider(15, 0, 3, 1, "SIZE START"))
	o:addDown(o:slider(15, 0, 3, 1, "SIZE END"))
	
	o:addDown(o:slider(15, 0, 255, 128, "R START"))
	o:addDown(o:slider(15, 0, 255, 128, "G START"))
	o:addDown(o:slider(15, 0, 255, 128, "B START"))
	o:addDown(o:slider(15, 0, 255, 128, "A START"))

	o:addDown(o:slider(15, 0, 255, 128, "R END"))
	o:addDown(o:slider(15, 0, 255, 128, "G END"))
	o:addDown(o:slider(15, 0, 255, 128, "B END"))
	o:addDown(o:slider(15, 0, 255, 128, "A END"))

	o.p_min = 1
	o.p_max = 1
	o.s_min = 1
	o.s_max = 1
	o.g_min = 1
	o.g_max = 1
	o.si_s = 1
	o.si_e = 1
	o.startColor = {128, 128, 128, 128}
	o.endColor = {128, 128, 128, 128}

end)
function ParticleEdit:valueChange(l, v)
	if l == "Save" then
		local s_data = self:save()
		persistence.store(blud.bundle_root .. "/particle_data_".. s_data['Particle Name'] ..".lua", s_data);
	end
	if l == "SPREAD" then
		self.particles:setSpread(v)
	end
	if l == "EMISSION" then
		self.particles:setEmissionRate(v)
	end
	if l == "DIRECTION" then
		self.particles:setDirection(v)
	end
	if l == "LIFE MIN" then
		self.p_min = v
		self.particles:setParticleLife(v, self.p_max)
	end	
	if l == "LIFE MAX" then
		self.p_max = v
		self.particles:setParticleLife(self.p_min, v)
	end
	if l == "GRAVITY MIN" then
		self.g_min = v
		self.particles:setGravity(v, self.g_max)
	end	
	if l == "GRAVITY MAX" then
		self.g_max = v
		self.particles:setGravity(self.g_min, v)
	end
	if l == "SPEED MIN" then
		self.s_min = v
		self.particles:setSpeed(v, self.s_max)
	end	
	if l == "SPEED MAX" then
		self.s_max = v
		self.particles:setSpeed(self.s_min, v)
	end
	if l == "SIZE START" then
		self.si_s = v
		self.particles:setSize(v, self.si_e)
	end	
	if l == "SIZE END" then
		self.si_e = v
		self.particles:setSize(self.si_s, v)
	end
	if l == "R START" then
		self.startColor[1] = v
		self.particles:setStartColor(self.startColor[1], self.startColor[2], self.startColor[3], self.startColor[4])
	end
	if l == "G START" then
		self.startColor[2] = v
		self.particles:setStartColor(self.startColor[1], self.startColor[2], self.startColor[3], self.startColor[4])
	end
	if l == "B START" then
		self.startColor[3] = v
		self.particles:setStartColor(self.startColor[1], self.startColor[2], self.startColor[3], self.startColor[4])
	end
	if l == "A START" then
		self.startColor[4] = v
		self.particles:setStartColor(self.startColor[1], self.startColor[2], self.startColor[3], self.startColor[4])
	end
	if l == "R END" then
		self.endColor[1] = v
		self.particles:setEndColor(self.endColor[1], self.endColor[2], self.endColor[3], self.endColor[4])
	end
	if l == "G END" then
		self.endColor[2] = v
		self.particles:setEndColor(self.endColor[1], self.endColor[2], self.endColor[3], self.endColor[4])
	end
	if l == "B END" then
		self.endColor[3] = v
		self.particles:setEndColor(self.endColor[1], self.endColor[2], self.endColor[3], self.endColor[4])
	end
	if l == "A END" then
		self.endColor[4] = v
		self.particles:setEndColor(self.endColor[1], self.endColor[2], self.endColor[3], self.endColor[4])
	end
end
function ParticleEdit:draw()
	Group.draw(self)
	self.particles:draw(bludG.camera.scroll.x, bludG.camera.scroll.y, bludG.camera.scale)
end
function ParticleEdit:update()
	Group.update(self)
	self.particles:update(bludG.elapsed)
end

-- mainState = WrapperState(ParticleEdit(0,0,bludG.camera.w/3, bludG.camera.h));