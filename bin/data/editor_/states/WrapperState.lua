-- shows the players number of coins, etc
-- also manages switching between the states (I think it should?)
WrapperState = class(Group, function(o, state)
	Group.init(o)
	-- o.bg = o:add(Object(0,0,bludG.camera.w, bludG.camera.h))
	-- o.bg.sprite = sprites["tiles"]["white.png"]
	-- o.bg.drawType = 'stretched'
	-- o.bg:setColor(142, 213, 205)
	-- o.bg.scrollFactor = Vec2(0,0)

	-- this is where all of the substates live. They used to live in a place called substate, but that was harder to manage passing touches through in a drop through manner, i.e. everything needed to be hardcoded.
	-- also, it didn't allow for states to be stacked without custom code... so yeah, fuck that
	o.substates = o:add(Group())
	o.substate = o.substates:add(state)

	o.player = _player
	if retina then
		o.closeButton = Button(261*2, 423*2, 64*2, 64*2, sprites["close_button.png"])
	else
		o.closeButton = Button(261, 423, 64, 64, sprites["close_button.png"])
	end
	o.closeButton.onPress = function()
		o:hideHelp()
	end

	o.tutorial = nil

	local bottomOffset = 54; if not retina then bottomOffset = bottomOffset*0.5 end
	o.bottomBg = Rectangle(0, bludG.camera.h-bottomOffset, bludG.camera.w, bottomOffset)
	o.bottomBg:setColor(225, 223, 216)
	o.bottomBg.layer = 3

	local beetCounterOffset = Vec2(58, 2)
	if not retina then beetCounterOffset:mult(0.5) end

	local statSize = Vec2(200, 100)
	if not retina then statSize:mult(0.5) end
	o.lastPlayerSync = 0
end)
function WrapperState:update()
	Group.update(self)
end

function WrapperState:draw()
	-- draw the top bar
	Group.draw(self)
end
function WrapperState:changeState(newState)
	-- because the old way of managing this only had one state, we are just going to swap out the bottom state in the chain... this should maintain compatibility for this function

	-- this leaves the interface bar at the top of the stack
	self.substates.members[1] = newState
	self.substate = newState
end

-- loops through the group of substates and removes one. This is just a helper function for the Group:remove function
function WrapperState:removeState(stateToRemove)
	self.substates:remove(stateToRemove)
end

-- adds a state to the stack above the specified state
function WrapperState:addStateAbove(existingState, stateToAdd)
	-- find the state
	local existingPosition
	for i,v in ipairs(self.substates.members) do
		if v == existingState then existingPosition = i end
	end
	if existingPosition then
		table.insert(self.substates.members, existingPosition+1, stateToAdd)
	else
		print("could not find state to insert above")
	end
end
function WrapperState:replaceState(existingState, stateToAdd)
	-- find the state
	local existingPosition
	for i,v in ipairs(self.substates.members) do
		if v == existingState then existingPosition = i end
	end
	if existingPosition then
		self.substates.members[existingPosition] = stateToAdd
		-- call the after removal
		if existingState.afterRemove then existingState:afterRemove() end
	else
		print("could not find state to replace")
	end
end
-- adds a state at the top of the stack
function WrapperState:addState(newState)
	return self.substates:add(newState)
end
function WrapperState:displayHelp(helpModel)
  self.displayingHelp = true;
  self.helpModel = helpModel;
  ho:show(helpModel.image)
end
function WrapperState:hideHelp()
  self.displayingHelp = false;
  ho:hide()
end
function WrapperState:displayModal(modalModel, addAbove)
	-- for compatibility with the new system
	-- todo: go into all the places that add a modal model and make them add above themselves, rather than on the top layer
	if addAbove then
		print("adding modal above")
		self.modalModel = modalModel
		self:addStateAbove(addAbove, modalModel)
	else
		self.modalModel = self.substates:add(modalModel)
	end
end
function WrapperState:hideModal()
	self.substates:remove(self.modalModel)
end
function WrapperState:touchDown(x, y, id)
	if self.friend then
		self.fBack:touchDown(x, y, id)
	end
	self.substates:touchDown(x, y, id)
end
function WrapperState:touchMoved(x, y, id)
	self.substates:touchMoved(x, y, id)
end
function WrapperState:touchUp(x, y, id)
	if self.friend then
		self.fBack:touchUp(x, y, id)
	end
	self.substates:touchUp(x, y, id)
end
function WrapperState:keyPressed(key)
	self.substates:keyPressed(key)
end
