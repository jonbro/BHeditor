-- local pvrtss = bludPVRtoSpriteSheet();
local loadSheet = function(sheet_name, t)
  local arg = {}
  local sheet, sprites
  spriteSize = 72
  sheetWidth = arg[width] or 1024
  sheetHeight = arg[height] or 1024
  sheetSize = sheetWidth
  sheet_list = sheet_name .. "_list"
  if retina then
    spriteSize = spriteSize*2
    sheetSize = sheetSize*2
    sheetWidth = sheetWidth*2
    sheetHeight = sheetHeight*2
    sheet_name = sheet_name .. "@2x"
    sheet_list = sheet_list .. "-hd"
  end
  if sheet == nil then
    -- setup a new sprite sheet with 5 layer, 1000 tiles per layer, default layer of 0, tile size of 32
    sheet = bludSpriteSheet(5, 1000, 0, spriteSize);

    if t == 'pvr' then
      sheet.pvrtss = bludPVRtoSpriteSheet();
      -- this one loads pvrs!
      -- you also need the local from up above to make it work

      sheet.pvrtss:load(sheet, blud.bundle_root .. "/editor_/assets/".. sheet_name ..".pvr")
    else
      -- load the texture onto the sheet
      -- takes the following parameters `(filename, sheetsize)`. The sheet must be a power of 2, and square.
      sheet:loadTexture(blud.bundle_root .. "/editor_/assets/".. sheet_name ..".png", sheetWidth, sheetHeight)      
      sheet:setupTexture()
    end

    -- this one loads pvrs!
    -- you also need the local from up above to make it work
    -- pvrtss:load(sheet, blud.bundle_root .. "/editor_/assets/".. sheet_name ..".pvr")
    
    sheet:setupTexture()
    sprites = {}

    -- load in the list
      list = dofile(blud.bundle_root ..  "editor_/sprite_lists/" .. sheet_list .. ".lua")

    -- load sprites from the list
    list = list.getSpriteSheetData()
    for i, v in ipairs(list.frames) do
      sprite = bludSprite();
      sprite:setTotalFrames(1)
      
      sprite:setWidth(v.spriteSourceSize.width/spriteSize)
      sprite:setHeight(v.spriteSourceSize.height/spriteSize)
      
      -- determine the index based on the position in the sheet
      index = (v.textureRect.x/spriteSize)+math.floor(sheetSize/spriteSize)*v.textureRect.y/spriteSize
      sprite:setIndex(index)
      
      -- the new way just sets the sprite positioning based on x y offsets
      sprite:setTexX(v.textureRect.x)
      sprite:setTexY(v.textureRect.y)
      sprite:setTexWidth(v.textureRect.width)
      sprite:setTexHeight(v.textureRect.height)
      sprite:setWidth(v.spriteSourceSize.width)
      sprite:setHeight(v.spriteSourceSize.height)
      sprite:setSpriteX(v.spriteColorRect.x)
      sprite:setSpriteY(v.spriteColorRect.y)

      sprite:setLoops(-1)
      sprites[v.name] = sprite
      -- print(v.name, index)
    end
  end
  return sheet, sprites
end
return loadSheet