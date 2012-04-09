bludGlobal = class(function(o)
  o.elapsed = 0;
  o.last_t = 0;
  o.fixed_t = 0
  o.fade_alpha = 0;
  -- need to keep a copy of the screen rect around for quick onscreen testing
  o.screen_rect = Rectangle(0,0,bg:getWidth(), bg:getHeight());
  o.camera = Camera(0,0,bg:getWidth(), bg:getHeight()) -- by default, make a camera the size of the screen
  o.cameras = {o.camera}
  o.recordingData = {}
end)
function bludGlobal:playback(table)
  self.playbackData = table
  self.playingback = true
end
function bludGlobal:update(t)
  -- self.fixed_t = self.fixed_t + 1
  -- t = self.last_t*1000 + 1/60 * 1000
  t = t/1000; self.elapsed = t - self.last_t; self.last_t = t;
  -- print(self.elapsed)
  -- handle the flash
  if self.isFlashing then
    self.flash_color[4] = math.max(0,self.flash_color[4] - (self.elapsed/self.flash_duration)*255);
    sheet:addCenteredTile(sprites["white.png"], 0, 0, 2, 1, 200, self.flash_color[1], self.flash_color[2], self.flash_color[3], self.flash_color[4])
    if(self.flash_color[4] <= 0) then
      self.isFlashing = false
      if self.flashOnComplete then self.flashOnComplete() end
    end
  end
  -- handle the fade
  if self.isFading then
    self.fade_alpha = math.min(255,self.fade_alpha + (self.elapsed/self.fade_duration)*255);
    if(self.fade_alpha >= 255) then
      self.isFading = false
      self.fade_alpha = 0;
      if self.fadeOnComplete then self.fadeOnComplete() end
    end
  end
  if(self.fade_alpha > 0) then
    sheet:addCenteredTile(sprites["white.png"], 0, 0, 2, 1, 200, self.fade_color[1], self.fade_color[2], self.fade_color[3], self.fade_alpha)
  end
  for i,v in ipairs(self.cameras) do
    v:update();
  end
  if self.playingback then
    local pdb = self.playbackData[self.fixed_t]
    if pdb then
      for i,v in ipairs(pdb) do
        if v[1] == "touchDown" then
          blud.touch.down(v[2], v[3], v[4])
        elseif v[1] == "touchMoved" then
          blud.touch.moved(v[2], v[3], v[4])
        elseif v[1] == "touchUp" then
          blud.touch.up(v[2], v[3], v[4])
        end
      end
    end
  end
end
function bludGlobal:draw()
end
-- returns a random seed if not playing back, and records a random seed if recording
function bludGlobal:seedRandom()
  local seed = bg:getMillis()
  -- if self.playingback then
  --   seed = self.playbackData["seed_" .. self.seedCount]
  -- end
  -- if self.recording then
  --   self.recordingData["seed_"..self.seedCount] = seed
  -- end
  -- if self.recording or self.playingback then
  --   self.seedCount = self.seedCount + 1
  -- end
  return seed
end
function bludGlobal:startRecording()
    self.recording = true
    self.seedCount = 0
end
function bludGlobal:flash(...)
  local arg = {...}
  self.flash_color = arg[1] or {255,255,255,255}
  self.flash_duration = arg[2] or 1
  self.flashOnComplete = arg[3] or function()end
  self.isFlashing = true
end
function bludGlobal:fade(...)
  local arg = {...}
  self.fade_color = arg[1] or {255,255,255,255}
  self.fade_duration = arg[2] or 1
  self.fadeOnComplete = arg[3] or function()end
  self.fade_alpha = 0
  self.isFading = true
end

function bludGlobal:touchDown(x, y, id)
  if self.recording then
    if not self.recordingData[self.fixed_t] then self.recordingData[self.fixed_t] = {} end
    _.push(self.recordingData[self.fixed_t], {"touchDown", x, y, id})
  end
end

function bludGlobal:touchMoved(x, y, id)
  if self.recording then
    if not self.recordingData[self.fixed_t] then self.recordingData[self.fixed_t] = {} end
    _.push(self.recordingData[self.fixed_t], {"touchMoved", x, y, id})
  end
end

function bludGlobal:touchUp(x, y, id)
  if self.recording then
    if not self.recordingData[self.fixed_t] then self.recordingData[self.fixed_t] = {} end
    _.push(self.recordingData[self.fixed_t], {"touchUp", x, y, id})
  end
end