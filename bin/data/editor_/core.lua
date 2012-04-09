
dofile(blud.bundle_root .. "/editor_/imports.lua")
bludG = bludGlobal()

sheetsToLoad = {{name="tiles", t='png'}}
sheets = {}
sprites = {}
function loadSprites()
  spriteLoader = dofile(blud.bundle_root ..  "/editor_/setupSprites.lua")
  for i,v in ipairs(sheetsToLoad) do
    sheets[v.name], sprites[v.name] = spriteLoader(v.name, v.t)
  end
end
loadSprites();
render = bludRenderer();
render:setSpriteSheet(sheets['tiles'])

if oscRec == nil then
  oscRec = Receiver();
  oscSender = bludOsc();
  oscSender:setup("localhost", 9002)
  oscPrint = function(s)
    local m = bludOscMessage();
    m:setAddress("/print")
    m:addStringArg(s)
    oscSender:sendMessage(m)
  end
end

mainState = WrapperState(WaveEditState(0,0,bludG.camera.w/3, bludG.camera.h));

function blud.draw()
  if not webview then
    mainState:draw();
    bludG:draw();
    bg:setColor(0,0,0,255);
  end
end
function blud.update(t)
  for i,v in ipairs(sheetsToLoad) do
    if sheets[v.name] then
      sheets[v.name]:clear()
    end
  end
  if not webview then
    Tweener:update();
    for i,v in ipairs(sheetsToLoad) do
      if sheets[v] then
        sheets[v]:update(t)
      end
    end
    mainState:update();
    bludG:update(t);
  end
  if oscRec then
    oscRec:update();
  end
end
function blud.touch.down(x, y, id)
end
function blud.touch.moved(x, y, id)
end
function blud.touch.up(x, y, id)
end
function blud.mouse.moved(x, y)
-- print(mouse moved)
-- do nothing when initially launching
end
function blud.mouse.dragged(x, y, button)
-- print(mouse dragged)
-- do nothing when initially launching
  mainState:touchMoved(x, y, button)
end
function blud.mouse.pressed(x, y, button)
  mainState:touchDown(x, y, button)
-- print(mouse pressed)
-- do nothing when initially launching
end
function blud.mouse.released(x, y, button)
  mainState:touchUp(x, y, button)
-- print(mouse released)
-- do nothing when initially launching
end
function blud.gotFocus()
end
function blud.exit()
end
function blud.key.pressed(key)
  mainState:keyPressed(key)
end