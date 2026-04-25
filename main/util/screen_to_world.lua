local M = {}

local ZOOM = 1.0  -- must match render/game.render_script zoom value

function M.screen_to_world(screen_x, screen_y, camera_id)
	local camera_pos = go.get_position(camera_id)
	local display_w = tonumber(sys.get_config("display.width"))
	local display_h = tonumber(sys.get_config("display.height"))
	local world_x = (screen_x - display_w * 0.5) / ZOOM + camera_pos.x
	local world_y = (screen_y - display_h * 0.5) / ZOOM + camera_pos.y
	return vmath.vector3(world_x, world_y, 0)
end

return M
