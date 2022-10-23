local X = {}

local visionRad = 1800;
local sentryRad = 1000;

-- OBSERVERS
-- RADIANT
-- Radiant top
local RADIANT_OBS_TOP1 = Vector(-5375.000000, 2300.000000, 0.000000);
local RADIANT_OBS_TOP2 = Vector(-4539.000000, 500.000000, 0.000000);
local RADIANT_OBS_TOP3 = Vector(-3300.000000, 660.000000, 0.000000);
local RADIANT_OBS_TOP4 = Vector(-5190.000000, -1570.000000, 0.000000);
local RADIANT_OBS_TOP5 = Vector(-3441.000000, -1541.000000, 0.000000);
local RADIANT_OBS_TOP6 = Vector(-4368.000000, -1022.000000, 0.000000);

-- Radiant mid
local RADIANT_OBS_MID1 = Vector(-1555.000000, 254.000000, 0.000000);
local RADIANT_OBS_MID2 = Vector(-287.000000, -1045.000000, 0.000000);
local RADIANT_OBS_MID3 = Vector(770.000000, -2287.000000, 0.000000);

-- Radiant bot
local RADIANT_OBS_BOT1 = Vector(5200.000000, -3700.000000, 0.000000);--
local RADIANT_OBS_BOT2 = Vector(4000.000000, -3350.000000, 0.000000);
local RADIANT_OBS_BOT3 = Vector(3400.000000, -5150.000000, 0.000000);

-- Radiant forest
local RADIANT_OBS_FOREST1 = Vector(2100.000000, -3350.000000, 0.000000);
local RADIANT_OBS_FOREST2 = Vector(1025.000000, -4100.000000, 0.000000);
local RADIANT_OBS_FOREST3 = Vector(-1800.000000, -4871.000000, 0.000000);

-- DIRE
-- Dire bot
local DIRE_OBS_BOT1 = Vector(4880.000000, -2300.000000, 0.000000);
local DIRE_OBS_BOT2 = Vector(5129.000000, 768.000000, 0.000000);
local DIRE_OBS_BOT3 = Vector(3963.000000, -1070.000000, 0.000000);
local DIRE_OBS_BOT4 = Vector(3200.000000, 0.000000, 0.000000);

-- Dire mid
local DIRE_OBS_MID1 = Vector(2035.000000, -750.000000, 0.000000);
local DIRE_OBS_MID2 = Vector(782.000000, -470.000000, 0.000000);
local DIRE_OBS_MID3 = Vector(-642.000000, 1000.000000, 0.000000);

-- Dire top
local DIRE_OBS_TOP1 = Vector(-5333.000000, 3867.000000, 0.000000);
local DIRE_OBS_TOP2 = Vector(-5281.000000, 4616.000000, 0.000000);
local DIRE_OBS_TOP3 = Vector(-3700.000000, 3363.000000, 0.000000);--

-- Dire forest
local DIRE_OBS_FOREST1 = Vector(-257.000000, 2050.000000, 0.000000);
local DIRE_OBS_FOREST2 = Vector(-3384.000000, 4312.000000, 0.000000);
local DIRE_OBS_FOREST3 = Vector(1032.000000, 4863.000000, 0.000000);
local DIRE_OBS_FOREST4 = Vector(-2043.000000, 4867.000000, 0.000000);

-- SENTRIES
-- RADIANT
-- Radiant top
local RADIANT_SENTRY_TOP1 = Vector(-4787.000000, 1225.000000, 0.000000);
local RADIANT_SENTRY_TOP2 = Vector(-3530.000000, -1177.000000, 0.000000);

local RADIANT_SENTRY_BOT1 = Vector(5727.000000, -3748.000000, 0.000000);
local RADIANT_SENTRY_BOT2 = Vector(3544.000000, -5247.000000, 0.000000);
local RADIANT_SENTRY_BOT3 = Vector(3759.000000, -3396.000000, 0.000000);

local RADIANT_SENTRY_BOT_SHRINE = Vector(1595.000000, -4190.000000, 0.000000);

local COMMON_SENTRY_BOT1 = Vector(-400.000000, -400.000000, 0.000000);

local DIRE_SENTRY_BOT1 = Vector(4365.000000, -1884.000000, 0.000000);
local DIRE_SENTRY_BOT_SHRINE = Vector(3469.000000, 450.000000, 0.000000);




--[[

---RADIANT WARDING SPOT
local RADIANT_T3TOPFALL = Vector(-6600.000000, -3072.000000, 0.000000);
local RADIANT_T3MIDFALL = Vector(-4314.000000, -3887.000000, 0.000000);
local RADIANT_T3BOTFALL = Vector(-3586.000000, -6131.000000, 0.000000);

local RADIANT_T2TOPFALL = Vector(-4340.000000, -1015.000000, 0.000000);
local RADIANT_T2MIDFALL = Vector(-1023.000000, -4605.000000, 0.000000);
local RADIANT_T2BOTFALL = Vector(1010.000000, -5321.000000, 0.000000);

local RADIANT_T1TOPFALL = Vector(-5117.000000, 2068.000000, 0.00000);
local RADIANT_T1MIDFALL = Vector(991.000000, -1574.000000, 0.000000);
local RADIANT_T1BOTFALL = Vector(5093.000000, -3722.000000, 0.000000);

local RADIANT_MANDATE1 = Vector(-1582.000000, 216.000000, 0.000000);
local RADIANT_MANDATE2 = Vector(1973.000000, -2450.000000, 0.000000);

local RADIANT_AGGRESSIVETOP  = Vector(-1221.000000, 4833.000000, 0.000000);
local RADIANT_AGGRESSIVEMID1 = Vector(-55.000000, 2685.000000, 0.000000);
local RADIANT_AGGRESSIVEMID2 = Vector(3568.000000, 1027.000000, 0.000000);
local RADIANT_AGGRESSIVEBOT  = Vector(5115.000000, -764.000000, 0.000000);

---DIRE WARDING SPOT
local DIRE_T3TOPFALL = Vector(3087.000000, 5690.000000, 0.000000);
local DIRE_T3MIDFALL = Vector(4024.000000, 3445.000000, 0.000000);
local DIRE_T3BOTFALL = Vector(6354.000000, 2606.000000, 0.000000);

local DIRE_T2TOPFALL = Vector(1022.000000, 4868.000000, 0.000000);
local DIRE_T2MIDFALL = Vector(1012.000000, 2247.000000, 0.000000);
local DIRE_T2BOTFALL = Vector(5113.000000, 773.000000, 0.000000);

local DIRE_T1TOPFALL = Vector(-5697.000000, 3212.000000, 0.000000);
local DIRE_T1MIDFALL = Vector(1031.000000, -736.000000, 0.000000);
local DIRE_T1BOTFALL = Vector(5096.000000, -760.000000, 0.000000);

local DIRE_MANDATE1 = Vector(-826.000000, 1186.000000, 0.000000);
local DIRE_MANDATE2 = Vector(3543.000000, -1467.000000, 0.000000);
local DIRE_MANDATE3 = Vector(3800.000000, -2242.000000, 0.000000);

local DIRE_AGGRESSIVETOP  = Vector(-4625.000000, 738.000000, 0.000000);
local DIRE_AGGRESSIVETOP2 = Vector(-4530.000000, 144.000000, 0.000000);
local DIRE_AGGRESSIVETOP3 = Vector(-3500.000000, -1600.000000, 0.000000);
local DIRE_AGGRESSIVETOP4 = Vector(-2800.000000, 800.000000, 0.000000);
local DIRE_AGGRESSIVEMID1 = Vector(-4348.000000, -1014.000000, 0.000000);
local DIRE_AGGRESSIVEMID2 = Vector(-1305.000000, -2889.000000, 0.000000);
local DIRE_AGGRESSIVEBOT  = Vector(1826.000000, -4266.000000, 0.000000);
]]

local Towers = {
	TOWER_TOP_1,
	TOWER_MID_1,
	TOWER_BOT_1,
	TOWER_TOP_2,
	TOWER_MID_2,
	TOWER_BOT_2,
	TOWER_TOP_3,
	TOWER_MID_3,
	TOWER_BOT_3
}


local EarlyObsSpots = {
	RADIANT_OBS_BOT1,
	RADIANT_OBS_BOT2,
	RADIANT_OBS_MID1,
	RADIANT_OBS_MID2,
	RADIANT_OBS_MID3,
	RADIANT_OBS_TOP1,
	DIRE_OBS_TOP3,
	DIRE_OBS_MID1,
	DIRE_OBS_MID2,
	DIRE_OBS_MID3
}

local SentrySpots = {
	RADIANT_SENTRY_TOP1,
	RADIANT_SENTRY_TOP2,
	RADIANT_SENTRY_BOT1,
	RADIANT_SENTRY_BOT2,
	RADIANT_SENTRY_BOT3,
	COMMON_SENTRY_BOT1,
	RADIANT_SENTRY_BOT_SHRINE,
	DIRE_SENTRY_BOT_SHRINE,
	DIRE_SENTRY_BOT1
}



local WardSpotTowerFallRadiant = {--[[
	RADIANT_T1TOPFALL,
	RADIANT_T1MIDFALL,
	RADIANT_T1BOTFALL,
	RADIANT_T2TOPFALL,
	RADIANT_T2MIDFALL,
	RADIANT_T2BOTFALL,
	RADIANT_T3TOPFALL,
	RADIANT_T3MIDFALL,
	RADIANT_T3BOTFALL]]
}	

local WardSpotTowerFallDire = {--[[
	DIRE_T1TOPFALL,
	DIRE_T1MIDFALL,
	DIRE_T1BOTFALL,
	DIRE_T2TOPFALL,
	DIRE_T2MIDFALL,
	DIRE_T2BOTFALL,
	DIRE_T3TOPFALL,
	DIRE_T3MIDFALL,
	DIRE_T3BOTFALL]]
}

function X.GetDistance(s, t)
    --print("S1: "..s[1]..", S2: "..s[2].." :: T1: "..t[1]..", T2: "..t[2]);
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function X.GetMandatorySpot()
	local MandatorySpotRadiant = {
		RADIANT_OBS_TOP2,
		RADIANT_OBS_TOP3,
		RADIANT_OBS_TOP4,
		RADIANT_OBS_TOP5,
		RADIANT_OBS_FOREST1,
		RADIANT_OBS_FOREST2,
		RADIANT_OBS_FOREST3
	}

	local MandatorySpotDire = {
		DIRE_OBS_BOT1,
		DIRE_OBS_BOT2,
		DIRE_OBS_BOT3,
		DIRE_OBS_BOT4,
		DIRE_OBS_MID1,
		DIRE_OBS_MID2,
		DIRE_OBS_MID3,
		DIRE_OBS_TOP1,
		DIRE_OBS_TOP2,
		DIRE_OBS_TOP3,
		DIRE_OBS_FOREST1,
		DIRE_OBS_FOREST2,
		DIRE_OBS_FOREST3,
		DIRE_OBS_FOREST4
	}
	if GetTeam() == TEAM_RADIANT then
		return MandatorySpotRadiant;
	else
		return MandatorySpotDire
	end	
end

function X.GetWardSpotWhenTowerFall()
	local wardSpot = {};
	for i = 1, #Towers
	do
		local t = GetTower(GetTeam(),  Towers[i]);
		if t == nil then
			if GetTeam() == TEAM_RADIANT then
				table.insert(wardSpot, WardSpotTowerFallRadiant[i]);
			else
				table.insert(wardSpot, WardSpotTowerFallDire[i]);
			end
		end
	end
	return wardSpot;
end

function X.GetAggressiveSpot()
	local AggressiveDire = {
		RADIANT_OBS_TOP1,
		RADIANT_OBS_TOP2,
		RADIANT_OBS_TOP3,
		RADIANT_OBS_TOP4,
		RADIANT_OBS_TOP5,
		RADIANT_OBS_TOP6,
		RADIANT_OBS_MID1,
		RADIANT_OBS_MID2,
		RADIANT_OBS_MID3,
		RADIANT_OBS_BOT1,
		RADIANT_OBS_BOT2,
		RADIANT_OBS_BOT3,
		RADIANT_OBS_FOREST1,
		RADIANT_OBS_FOREST2,
		RADIANT_OBS_FOREST3
	}

	local AggressiveRadiant = {
		DIRE_OBS_BOT1,
		DIRE_OBS_BOT2,
		DIRE_OBS_BOT3,
		DIRE_OBS_BOT4,
		DIRE_OBS_MID1,
		DIRE_OBS_MID2,
		DIRE_OBS_MID3,
		DIRE_OBS_TOP1,
		DIRE_OBS_TOP2,
		DIRE_OBS_TOP3,
		DIRE_OBS_FOREST1,
		DIRE_OBS_FOREST2,
		DIRE_OBS_FOREST3,
		DIRE_OBS_FOREST4
	}
	if GetTeam() == TEAM_RADIANT then
		return AggressiveRadiant;
	else
		return AggressiveDire
	end	
end


function X.GetItemObserverWard(bot)
	for i = 0,8 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil then 
			if item:GetName() == 'item_ward_observer' or item:GetName() == 'item_ward_dispenser' then 
				return item;
			end
		end
	end
	return nil;
end

function X.GetItemSentryWard(bot)
	for i = 0,8 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == 'item_ward_sentry' then
			return item;
		end
	end
	return nil;
end

function X.IsPingedByHumanPlayer(bot)
	local TeamPlayers = GetTeamPlayers(GetTeam());
	for i,id in pairs(TeamPlayers)
	do
		if not IsPlayerBot(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and GetUnitToUnitDistance(bot, member) <= 1000 then
				local ping = member:GetMostRecentPing();
				local Wslot = member:FindItemSlot('item_ward_observer');
				if GetUnitToLocationDistance(bot, ping.location) <= 600 and 
				   GameTime() - ping.time < 5 and 
				   Wslot == -1
				then
					return true, member;
				end	
			end
		end
	end
	return false, nil;
end

function X.GetAvailableObsSpot(bot)
	local temp = {};
	for _,s in pairs(X.GetMandatorySpot()) do
		if not X.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	for _,s in pairs(X.GetWardSpotWhenTowerFall()) do
		if not X.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	if DotaTime() > 5*60 then
		for _,s in pairs(X.GetAggressiveSpot()) do
			if GetUnitToLocationDistance(bot, s) <= 3000 and not X.CloseToAvailableWard(s) then
				table.insert(temp, s);
			end
		end
	end
	if DotaTime() < 10*60 then
		for _,s in pairs(EarlyObsSpots) do
			if GetUnitToLocationDistance(bot, s) <= 2000 and not X.CloseToAvailableWard(s) then
				table.insert(temp, s);
			end
		end
	end
	return temp;
end

function X.GetAvailableSentrySpot(bot)
	local temp = {};
	
	if DotaTime() > 0 then
		for _,s in pairs(SentrySpots) do
			if GetUnitToLocationDistance(bot, s) <= 3000 and not X.CloseToAvailableSentryWard(s) then
				table.insert(temp, s);
			end
		end
	end
	return temp;
end

function X.CloseToAvailableWard(wardLoc)
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
	for _,ward in pairs(WardList) do
		if X.IsObserver(ward) and GetUnitToLocationDistance(ward, wardLoc) <= visionRad then
			return true;
		end
	end
	return false;
end

function X.CloseToAvailableSentryWard(wardLoc)
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
	for _,ward in pairs(WardList) do
		if X.IsSentry(ward) and GetUnitToLocationDistance(ward, wardLoc) <= sentryRad then
			return true;
		end
	end
	return false;
end

function X.GetClosestSpot(bot, spots)
	local cDist = 100000;
	local cTarget = nil;
	for _, spot in pairs(spots) do
		local dist = GetUnitToLocationDistance(bot, spot);
		if dist < cDist then
			cDist = dist;
			cTarget = spot;
		end
	end
	return cTarget, cDist;
end

function X.IsObserver(wardUnit)
	return wardUnit:GetUnitName() == "npc_dota_observer_wards";
end

function X.IsSentry(wardUnit)
	return wardUnit:GetUnitName() == "npc_dota_sentry_wards";
end

function X.GetHumanPing()
	local teamIDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(teamIDs)
	do
		local hUnit = GetTeamMember(i);
		if hUnit ~= nil and not hUnit:IsBot() then
			return hUnit:GetMostRecentPing();
		end
	end
	return nil;
end


return X