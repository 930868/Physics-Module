--[[
	-AUTHOR: FacelessDev
	-LAST CHECK: 28/03/2025
	-PHYSICS/INTERPOLATION MODULE (FINISHED)
--]]

local physics_module = {}


--MATH

function physics_module.RawLerp(pointA,pointB,t)
	return pointA + (pointB-pointA) * t
end
	
function physics_module.Lerp(pointA,pointB,t)
	return pointA * (1-t) + (t*pointB)
end

local function lerp(pointA,pointB,t) --Cleaning quad
	return pointA + (pointB-pointA) * t
end

function physics_module.QuadBezier(a,b,c,t)
	local l1 = lerp(a,b,t)
	local l2 = lerp(b,c,t)
	local quad = lerp(l1,l2,t)
	return quad
end

function physics_module.EaseOutQuad(t)
	return 1 - (1 - t) * (1 - t)
end


--PHYSICS

local function CalculateProperties(part,pos1,pos2)
	part.Position = pos2
	local diff = (pos2 - pos1)
	local angleY = math.atan2(diff.X,diff.Z)*(180/math.pi)

	part.Orientation = Vector3.new(0, angleY, 0)
end

local function CalculatePropertiesModel(model,pos1,pos2)
	local diff = (pos2 - pos1)
	local angleY = math.atan2(diff.X,diff.Z) -- * (180/math.pi) 

	model:SetPrimaryPartCFrame(CFrame.new(pos2) * CFrame.Angles(0, angleY, 0))
end

function physics_module.StopCurve(part)
	if not part.Stop.Value and part.IsPlaying.Value then
		part.Stop.Value = true
		part.Stop.Value = false
	end
end

function physics_module.CreateCurve(part,a: Vector3,b: Vector3,c: Vector3,t: number,last: Vector3,step: number,easingStyle: string)	
	print('Playing curve')
	part.IsPlaying.Value = true
	easingStyle = easingStyle or 'EaseIn'
	local newPos = nil
	
	while t <= 1 do
		if part.Stop.Value then
			part.IsPlaying.Value = false
			break 
		end
		
		--Easing Management
		if easingStyle == 'EaseOut' then
			newPos = physics_module.QuadBezier(a,b,c,physics_module.EaseOutQuad(t))
		else
			newPos = physics_module.QuadBezier(a,b,c,t)
		end

		--Model Detection
		if last then
			if part.ClassName == 'Model' then
				CalculatePropertiesModel(part,last,newPos)
			else
				CalculateProperties(part,last,newPos)
			end
		end

		--Time management
		if easingStyle == 'EaseIn' or easingStyle == 'EaseOut' then
			last = newPos
			t += step
		elseif easingStyle == 'Linear' then
			local vec = t*(2*a-4*b+2*c)
			vec += (-2*a+2*b)
			t += (step) / vec.Magnitude
		else
			warn('There was a problem with the easing style')
			return nil
		end
		
		task.wait(0.005) -- Default 0.005
	end
	
	part.IsPlaying.Value = false
end

return physics_module
