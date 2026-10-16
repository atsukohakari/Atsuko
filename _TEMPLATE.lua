-- template, files starting with _ dont show up in the hub
-- copy it, rename it, put it in Scripts/<folder>/

-- @desc what it does
-- @author atsukohakari

-- script here


-- runs when you press stop (optional)
if AtsukoHub and AtsukoHub.Path then
	AtsukoHub.OnStop(function()

	end)
end

-- for -run / -stop scripts:
-- _G.MyScriptCommands = { run = runCmd, stop = stopCmd, kill = killAll }
