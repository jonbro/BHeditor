local sheets = {{name="tiles", t='png'}, {name="overlayone", t='pvr'}, {name="overlaytwo", t='pvr'}}

for i, v in ipairs(sheets) do
	local extension = 'png'
	local opt = '--extrude 1 '
	if v.t == 'pvr' then
		extension = 'pvr'
		opt = '--opt PVRTC4 --padding 0 '
	end

	local retina = "TexturePacker " .. opt .. "--trim --format corona --data sprite_lists/" .. v.name .. "_list-hd.lua --algorithm MaxRects --maxrects-heuristics best --verbose --sheet assets/" .. v.name .. "@2x." .. extension .." ../../../ungrouped_sprites/".. v.name .. "/*;"
	local non_retina = "TexturePacker " .. opt .. "--trim --format corona --data sprite_lists/" .. v.name .. "_list.lua --algorithm MaxRects --maxrects-heuristics best --verbose --scale 0.5 --sheet assets/" .. v.name .. "." .. extension .." ../../../ungrouped_sprites/".. v.name .. "/*;"
	os.execute(retina)
	os.execute(non_retina)
	
end

-- sed -i"" "/module/d" cute_list.lua;
-- sed -i"" "/module/d" cute_list-hd.lua;