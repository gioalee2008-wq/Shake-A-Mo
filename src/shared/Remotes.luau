--!strict
--[[
	Single place that names every remote. The server creates them; the client
	only waits for them.

	Server -> Client: State (Snapshot), Notify (Notice)
	Client -> Server: ClaimDaily (), Activity ()
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "DiscoveryRemotes"
local NAMES = { "State", "Notify", "ClaimDaily", "Activity" }

export type Remotes = {
	State: RemoteEvent,
	Notify: RemoteEvent,
	ClaimDaily: RemoteEvent,
	Activity: RemoteEvent,
}

local cached: Remotes? = nil

local function get(): Remotes
	if cached then
		return cached
	end

	local folder: Instance
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		if existing then
			folder = existing
		else
			local created = Instance.new("Folder")
			created.Name = FOLDER_NAME
			for _, name in NAMES do
				local remote = Instance.new("RemoteEvent")
				remote.Name = name
				remote.Parent = created
			end
			created.Parent = ReplicatedStorage
			folder = created
		end
	else
		folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
	end

	local result: Remotes = {
		State = folder:WaitForChild("State") :: RemoteEvent,
		Notify = folder:WaitForChild("Notify") :: RemoteEvent,
		ClaimDaily = folder:WaitForChild("ClaimDaily") :: RemoteEvent,
		Activity = folder:WaitForChild("Activity") :: RemoteEvent,
	}
	cached = result
	return result
end

return { get = get }
