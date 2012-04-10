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

mainState = WrapperState(ParticleEdit(0,0,bludG.camera.w/3, bludG.camera.h));