

local function load(filename)
	local tilemap = Sprite.new()
-- Bits on the far end of the 32-bit global tile ID are used for tile flags (flip, rotate)
local FLIPPED_HORIZONTALLY_FLAG = 0x80000000;
local FLIPPED_VERTICALLY_FLAG = 0x40000000;
local FLIPPED_DIAGONALLY_FLAG = 0x20000000;

	local map = loadfile(filename)()

	for i=1, #map.tilesets do
		local tileset = map.tilesets[i]
		
		tileset.sizex = math.floor((tileset.imagewidth - tileset.margin + tileset.spacing) / (tileset.tilewidth + tileset.spacing))
		tileset.sizey = math.floor((tileset.imageheight - tileset.margin + tileset.spacing) / (tileset.tileheight + tileset.spacing))
		tileset.lastgid = tileset.firstgid + (tileset.sizex * tileset.sizey) - 1

		tileset.texture = Texture.new(tileset.image)
	end

	local function gid2tileset(map, gid)
		for i=1, #map.tilesets do
			local tileset = map.tilesets[i]
		
			if tileset.firstgid <= gid and gid <= tileset.lastgid then
				return tileset
			end
		end
	end	
	
	for i=1, #map.layers do
    
    local tileset = map.tilesets[i]
    
		local layer = map.layers[i]

		local tilemaps = {}
		local group = Sprite.new()

		for y=1,layer.height do
			for x=1,layer.width do
        -- Variables to let us know if the tile is flipped or rotated
				local flipHor, flipVer, flipDia = 0, 0, 0
        
				local i = x + (y - 1) * layer.width
				local gid = layer.data[i]
        -- If not empty tile
			local flipHor
			local flipVer
			local flipDia
				if gid ~= 0 then
					-- Read flipping flags
					flipHor = gid & FLIPPED_HORIZONTALLY_FLAG
					flipVer = gid & FLIPPED_VERTICALLY_FLAG
					flipDia = gid & FLIPPED_DIAGONALLY_FLAG
					-- Convert flags to gideros style
					if(flipHor ~= 0) then flipHor = 4 end --TileMap.FLIP_HORIZONTAL end
					if(flipVer ~= 0) then flipVer = 2 end --TileMap.FLIP_VERTICAL end
					if(flipDia ~= 0) then flipDia = 1 end --TileMap.FLIP_DIAGONAL end
					-- Clear the flags from gid so other information is healthy
					gid = gid & ~ (FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG)
				end
        
				local tileset = gid2tileset(map, gid)
				
				if tileset then
					local tilemap = nil
					if tilemaps[tileset] then
						tilemap = tilemaps[tileset]
					else
						tilemap = IsometricTileMap.new(layer.width, 
													   layer.height,
													   tileset.texture,
													   tileset.tilewidth,
													   tileset.tileheight,
													   tileset.spacing,
													   tileset.spacing,
													   tileset.margin,
													   tileset.margin,
													   map.tilewidth,
													   map.tileheight)
						tilemaps[tileset] = tilemap
						group:addChild(tilemap)
					end
					
					local tx = (gid - tileset.firstgid) % tileset.sizex + 1
					local ty = math.floor((gid - tileset.firstgid) / tileset.sizex) + 1
					
          -- Set the tile with flip info
					tilemap:setTile(x, y, tx, ty, flipHor| flipVer| flipDia)
					-- Reset vars, so they dont confuse us in the next iteration
					flipHor, flipVer, flipDia = 0, 0, 0
          
				end
			end
		end

		group:setAlpha(layer.opacity)
		
		tilemap:addChild(group)
	end
	
	return tilemap
end

local tilemap = load("iso-test-vertexz.lua")
stage:addChild(tilemap)

local dragging, startx, starty

local function onMouseDown(event)
	dragging = true
	startx = event.x
	starty = event.y
end

local function onMouseMove(event)
	if dragging then
		local dx = event.x - startx
		local dy = event.y - starty
		tilemap:setX(tilemap:getX() + dx)
		tilemap:setY(tilemap:getY() + dy)
		startx = event.x
		starty = event.y
	end
end

local function onMouseUp(event)
	dragging = false
end

stage:addEventListener(Event.MOUSE_DOWN, onMouseDown)
stage:addEventListener(Event.MOUSE_MOVE, onMouseMove)
stage:addEventListener(Event.MOUSE_UP, onMouseUp)


