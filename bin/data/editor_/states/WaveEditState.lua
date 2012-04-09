WaveEditState = class(ScrollableGuiGroup, function(o, x, y, w, h)
	ScrollableGuiGroup.init(o, x, y, w, h)
	o:addDown(o:label("Level Edit"))
	o:addDown(o:textInput(20, "Level Name"))
	o:addDown(o:slider(20,0,10000,0,"Start Money"))
	o:addDown(o:button(20,"Save Level"))
	o:addDown(o:button(20,"Add Wave"))

	o.levelData = {
		money=0,
		waves={

		}
	}
	o.waveControls = Group()
	o.waves = {}
end)
function WaveEditState:valueChange(l, v)
	if l == "Add Wave" then
		table.insert(self.levelData.waves, {time=0, enemies={}})
		local waveCount = #self.levelData.waves
		self:addWaveEditors(waveCount)
	elseif l == "Start Money" then
		self.levelData.money=v
	elseif l == "Level Name" then
		print(v)
		self.levelData.name=v
	elseif l == "Save Level" then
		print("saving level")
		persistence.store(blud.bundle_root .. "/level_data_".. self.levelData.name..".lua", self.levelData);
	else
		-- we are inside a specific wave edit
		-- extract the wave count
		local waveCount, element = string.match(l, "(%d+)_(%a+)")
		waveCount = waveCount+0
		if element == 'time' then
			for i,v in ipairs(self.levelData.waves[waveCount]) do
				print(i,v)
			end
			self.levelData.waves[waveCount].time = v
		elseif element == 'remove' then
			-- remove the wave from the data
			table.remove(self.levelData.waves, waveCount)
			-- remove all the existing controls
			for i,v in ipairs(self.waveControls.members) do
				self.controls:remove(v)
			end
			self.waveControls = Group()
			-- rebuild the editor bounds, so that new edit controls will go in correctly
			self:setLastObj(self.controls.members[#self.controls.members])
			-- load in the data
			self:load(self.levelData)
		else
			-- editing the enemy counts
			-- find the enemy with this name, and remove
			for k,v in pairs(self.levelData.waves[waveCount].enemies) do
				if v.t == element then
					self.levelData.waves[waveCount].enemies[k] = nil
				end
			end
			-- insert the enemy and the new count
			table.insert(self.levelData.waves[waveCount].enemies, {t=element, count=math.floor(v)})
		end
	end
end
function WaveEditState:addWaveEditors(waveCount)
	self.waveControls:add(self:addDown(self:label(waveCount .. "_Wave")))
	self.waveControls:add(self:addDown(self:slider(20,0,100,0,waveCount .. "_time")))
	-- for now just insert sliders for the three enemy types we have. This will need to get more complex eventually
	self.waveControls:add(self:addDown(self:slider(20,0,100,0,waveCount .. "_GullEnemy")))
	self.waveControls:add(self:addDown(self:slider(20,0,100,0,waveCount .. "_KidEnemy")))
	self.waveControls:add(self:addDown(self:slider(20,0,100,0,waveCount .. "_CloudEnemy")))
	self.waveControls:add(self:addDown(self:button(20, waveCount .. "_remove")))
end
function WaveEditState:load(data)
	-- loads in the waves from a datafile. this is not the default behaivor of the guiGroup loader
	-- build out wave editors based on the number of waves in the data file
	for i=1,#data.waves do
		self:addWaveEditors(i)
	end
	-- flatten the datafile into the format normally used by the editor system
	local defaultData = {
		['Start Money']=data.money
	}
	for i,v in ipairs(data.waves) do
		defaultData[i .. "_time"] = v.time
		for j,x in ipairs(v.enemies) do
			defaultData[i .. "_" .. x.t] = x.count
		end
	end
	GuiGroup.load(self, defaultData)
end

-- mainState = WrapperState(WaveEditState(0,0,bludG.camera.w/3, bludG.camera.h));