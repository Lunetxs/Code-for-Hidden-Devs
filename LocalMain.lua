local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = game.Players.LocalPlayer
local Character = script.Parent

local Camera = workspace.CurrentCamera

local CameraShake = require(game.ReplicatedStorage.Modules.CameraShaker)


local Get : boolean = false

local Object :Part

local Debounce : boolean = false



local function CreateBlocksSphereOutline(point: Vector3, 
	info: { 
		intensity: number, 
		radius: { min: number, max: number }, 
		size: { min: number, max: number }, 
		delaytime: { min: number, max: number } }, 
	callback)



	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Map}

	local ray = workspace:Raycast(point, Vector3.new(0, -20, 0), params)
	if not ray then return end

	local parts = {}

	for angle = 0, 360, 360/info.intensity do

		local smul = math.random(info.size.min*1000, info.size.max*1000)/1000

		local randPos = Vector3.new(
			math.sin(math.rad(angle))*math.random(info.radius.min, info.radius.max),
			0,
			math.cos(math.rad(angle))*math.random(info.radius.min, info.radius.max)
		)

		local part = Instance.new("Part",workspace)
		part.Size = Vector3.new(smul, smul, smul)
		part.CFrame = CFrame.new(ray.Position + randPos, (ray.Position - ray.Normal)) * CFrame.Angles(math.rad(90),0,0)	
		part.Transparency = .2
		part.Color = ray.Instance.Color
		part.Material = ray.Material

		part.Anchored = true

		part.CFrame = part.CFrame + part.CFrame.UpVector * -4
		TweenService:Create(part, TweenInfo.new(.15), { CFrame = part.CFrame + part.CFrame.UpVector * 4 }):Play()



		table.insert(parts, part)

		task.delay(math.random(info.delaytime.min*1000, info.delaytime.max*1000)/1000, function() TweenService:Create(part, TweenInfo.new(1,Enum.EasingStyle.Sine), {Size = Vector3.zero}):Play() wait(1) part:Destroy()  end)

	end


	return parts

end




UserInputService.InputBegan:Connect(function(input, event)
	if input.KeyCode == Enum.KeyCode.Q and not event and not Debounce then
		if Get then
			Debounce = true
			Get = false
			
			
			local Mouse = Player:GetMouse()
			local MousePosition = Mouse.Hit.Position
			
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Include
			params.FilterDescendantsInstances = {workspace.Map:GetDescendants()}
			local raycast = workspace:Raycast(MousePosition + Vector3.new(0,2,0), Vector3.new(0, -20,0), params)
			if raycast then
				
				
				local EndTween = TweenService:Create(Object, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Position = raycast.Position})
				
				EndTween:Play()
				task.delay(.6,function()
					
					Object.EndSound:Play()
					
					local EndEffect = game.ReplicatedStorage.Assets.EndEffect:Clone()
					EndEffect.Parent = workspace
					EndEffect.CFrame = CFrame.new(raycast.Position)
					
					
					for _, v in pairs(EndEffect:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v:Emit(v:GetAttribute("EmitCount"))
						end
					end
					
					
					local CameraShake = CameraShake.new(Enum.RenderPriority.Camera.Value, function(shakecf)
						Camera.CFrame *= shakecf
					end)
					CameraShake:Start()

					CameraShake:Shake(CameraShake.Presets.BumpModded)



					CreateBlocksSphereOutline(raycast.Position  + Vector3.new(0,3,0), {
						intensity =  35, 
						radius =  { min =  4, max = 7 }, 
						size =  { min =  1, max = 2 }, 
						delaytime = {min =  1, max = 3 },
					})
					
				end)
				
				EndTween.Completed:Connect(function()
					
					
					Debounce = false
					
					local LastObject = Object
					
					TweenService:Create(LastObject, TweenInfo.new(.5, Enum.EasingStyle.Sine),{Transparency = 1}):Play()
					
					for _, v in pairs(LastObject:GetDescendants()) do
						task.spawn(function()
							if v:IsA("Beam") then
								for i=1, 10 do
									v.Transparency = NumberSequence.new(i/10)
									task.wait(0.01)
								end
							end
						end)
					end
					task.spawn(function()
						task.wait(2)
						LastObject:Destroy()
					end)

				end)
				
			end
			
		else
			Debounce = true
			Get = true
			local Mouse = Player:GetMouse()
			local MousePosition = Mouse.Hit.Position

			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Include
			params.FilterDescendantsInstances = {workspace:GetDescendants()}
			local raycast = workspace:Raycast(MousePosition + Vector3.new(0,2,0), Vector3.new(0, -20,0), params)
			if raycast then
				
				Object = game.ReplicatedStorage.Assets.Object:Clone()
				Object.Parent = workspace
				Object.CFrame = CFrame.new(raycast.Position - Vector3.new(0,20,0))

				
				local StartEffect = game.ReplicatedStorage.Assets.StartEffect:Clone()
				StartEffect.Parent = Object
				
				StartEffect.CFrame = CFrame.new(raycast.Position + Vector3.new(0,2,0))
				
				for _, v in pairs(StartEffect:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					end
				end
				
				
				local CameraShake = CameraShake.new(Enum.RenderPriority.Camera.Value, function(shakecf)
					Camera.CFrame *= shakecf
				end)
				CameraShake:Start()
				
				CameraShake:Shake(CameraShake.Presets.BumpModded)
				
				Object.StartSound:Play()
				
				task.delay(.1,function()
					
					
					
				CreateBlocksSphereOutline(raycast.Position  + Vector3.new(0,3,0), {
						intensity =  35, 
						radius =  { min =  4, max = 7 }, 
						size =  { min =  1, max = 2 }, 
						delaytime = {min =  1, max = 3 },
					})
				end)
				
				
				task.wait(.1)
				Object.CFrame *= CFrame.Angles(math.rad(75),math.rad(0), math.rad(75))

				
				local StartTween = TweenService:Create(Object, TweenInfo.new(.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = Object.Position + Vector3.new(0,30,0)})
				StartTween:Play()
				StartTween.Completed:Connect(function()
					Debounce = false
				end)
				
				
				while Get  do
					Object.CFrame *= CFrame.Angles(math.rad(1),math.rad(0),math.rad(1))
					task.wait(.01)
				end
				
			end
		end
	end
	
end)

