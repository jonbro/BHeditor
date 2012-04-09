package.path = package.path .. ";"..blud.bundle_root.."editor_/?.lua"
do
  local filesToImport = {
        "class",
        "underscore",
        "Rectangle",
        "Group",
        "Object",
        "Camera",
        "bludGlobal",
        "OscHooks",
        "Particles",
        "Tweener",
        "tablePersistance",

        "objects/Button",
        "objects/DragArea",
        "objects/Slider",
        "objects/StringObject",
        "objects/UIButton",
        "objects/UITextInput",

        "states/WrapperState",
        "states/GuiGroup",
        "states/ParticleEdit",
        "states/WaveEditState",
	}
  for i, v in ipairs(filesToImport) do
    dofile(blud.bundle_root .. "/editor_/".. v ..".lua")
  end
end

_ = require 'underscore'