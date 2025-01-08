iteratePresets = function(filePath)
	return coroutine.create(function()
		local playerPos = ActivityMan:GetActivity():GetControlledActor(0).Pos - Vector(0, FrameMan.PlayerScreenHeight / 4);
		local cache = {};

		local iteratePresets = function(filePath)
			return coroutine.create(function() 
				local file = LuaMan:FileOpen(filePath, "r");
				local prevLine = nil;
				local theOnePrior = nil;

				while not LuaMan:FileEOF(file) do
					local line = LuaMan:FileReadLine(file);
					coroutine.yield(line, prevLine, theOnePrior);
					theOnePrior = prevLine;
					prevLine = line;
				end

				LuaMan:FileClose(file);
			end); 
		end;

		local co = iteratePresets(filePath);
		local r = {coroutine.resume(co)};

		while r[1] do
			local redo = false;
			local type = false;
			local name = false;

			if r[2] then
				presetPos = r[2]:find("PresetName = ");

				if presetPos then
					local presetName = r[2]:sub(presetPos + 13, -2);
					local typeName = nil;
					local typeLine = r[3];

					if r[3] and r[3]:find("CopyOf = ") then
						typeLine = r[4]
					end

					typeName = typeLine:sub(typeLine:find(" = ") + 3, -2);
					print(presetName);
					print(typeName);

					if not r[5] then
						cache[typeName] = cache[typeName] or {};
						cache[typeName][presetName] = {r[1], r[2], r[3], r[4], true};
					end

					local thing = _G["Create" .. typeName](presetName, "Base.rte");
					thing.Pos = playerPos;
					MovableMan:AddParticle(thing);
					redo, name, type = coroutine.yield("Running");
				end
			end

			if not redo then
				r = {coroutine.resume(co)}; 
			else
				r[5] = true;
				if name and type then
					r = cache[type][name];
				end
			end
		end
	end)
end
--"Base.rte/Effects/Pyro.ini"