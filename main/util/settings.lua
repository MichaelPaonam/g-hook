local M = {}
local KEY = "g_hook_save"

function M.load()
	local d = sys.load(KEY)
	return {
		best_times   = d.best_times   or {},
		music_volume = d.music_volume or 0.7,
		music_muted  = d.music_muted  or false,
	}
end

function M.get_best_time(level_index)
	local d = sys.load(KEY)
	local bt = d.best_times or {}
	return bt[level_index] or 0
end

function M.save_best_time(level_index, t)
	local d = sys.load(KEY)
	local bt = d.best_times or {}
	bt[level_index] = t
	d.best_times = bt
	sys.save(KEY, d)
end

function M.save(data)
	local d = sys.load(KEY)
	if data.music_volume ~= nil then d.music_volume = data.music_volume end
	if data.music_muted  ~= nil then d.music_muted  = data.music_muted  end
	sys.save(KEY, d)
end

return M
