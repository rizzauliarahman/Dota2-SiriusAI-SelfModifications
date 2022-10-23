local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local skills = require(GetScriptDirectory() ..  "/AuxiliaryScript/SkillsUtility")
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {4,2,4,1,4,1,4,1,1,6,6,2,2,2,6},
	['Buy'] = {
		"两个item_tango",
		"两个item_circlet",
		"item_magic_stick",
		"两个item_branches",
		"item_magic_wand",
		"两个item_wraith_band",
		"item_power_treads",
		"item_ancient_janggo",
		"item_lifesteal",
		"item_yasha", 
		"item_manta",
		"item_black_king_bar",
		"item_skadi",
		"item_satanic",
	},
	['Sell'] = {
		"item_ethereal_blade",
		"item_yasha",

		"item_sphere",
		"item_ancient_janggo",

		"item_ultimate_scepter2",
		"item_power_treads",
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end


local castFBDesire = 0;
local castFB2Desire = 0;
local castTWDesire = 0;
local castTDDesire = 0;
local castRCDesire = 0;
local castMRADesire = 0;
local castMRSDesire = 0;
local castGhostDesire = 0;
local castEBDesire = 0;
local itemGhost = nil;
local itemEB = nil;
local alreadyCastEB = false;

local abilityFB = nil;
local abilityFB2 = nil;
local abilityTW = nil;
local abilityMRA = nil;
local abilityMRS = nil;
local abilityRC = nil;
local justMorph = true;

local skill1 = nil;
local skill2 = nil;
local skill3 = nil;
local asMorphling = true;
local plusFactor = 0;

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	plusFactor = bot:GetLevel() / 30 * 1.0;	

	if abilityRC == nil then abilityRC = bot:GetAbilityByName( "morphling_replicate" ) end
	
	local Ability1 = bot:GetAbilityInSlot(0);
	
	if Ability1 ~= nil and Ability1:GetName() == 'morphling_waveform' then
		asMorphling = true;
	else
		asMorphling = false;
	end	

	if asMorphling == false then
		if justMorph == false then
			skill1 = bot:GetAbilityInSlot(0);
			skill2 = bot:GetAbilityInSlot(1);
			skill3 = bot:GetAbilityInSlot(2);	
			justMorph = true; 
		end
		if J.CanNotUseAbility(bot) then return end
		skills.CastStolenSpells(skill1);
		skills.CastStolenSpells(skill2);
		skills.CastStolenSpells(skill3);
		if ( (skill1 ~= nil and skill1:IsNull() == false and skill1:IsFullyCastable() == false) and
		     (skill2 ~= nil and skill2:IsNull() == false and skill2:IsFullyCastable() == false) and
		     (skill3 ~= nil and skill3:IsNull() == false and skill3:IsFullyCastable() == false) ) or bot:GetHealth() <= 0.35 * bot:GetMaxHealth()
		then
			bot:Action_UseAbility(bot:GetAbilityByName( "morphling_morph_replicate" ))
			return
		end 
	else

		if justMorph then
			abilityFB = bot:GetAbilityByName( "morphling_adaptive_strike_agi" );
			abilityFB2 = bot:GetAbilityByName( "morphling_adaptive_strike_str" );
			abilityTW = bot:GetAbilityByName( "morphling_waveform" );
			abilityMRA = bot:GetAbilityByName( "morphling_morph_agi" );
			abilityMRS = bot:GetAbilityByName( "morphling_morph_str" ); 
			justMorph = false;
		end
		
		if bot:IsSilenced() == false 
		   and bot:IsHexed() == false 
		   and bot:IsInvulnerable() == false 
		   and bot:HasModifier("modifier_doom_bringer_doom") == false
		then
			castMRADesire = ConsiderMorphAgility();
			castMRSDesire = ConsiderMorphStrength();
			if castMRSDesire > 0 then
				bot:Action_UseAbility( abilityMRS );
				return;
			end
			if castMRADesire > 0 then
				bot:Action_UseAbility( abilityMRA );
				return;
			end
		end
		
		-- Check if we're already using an ability
		if J.CanNotUseAbility(bot) then return end
		
		itemGhost = IsItemAvailable("item_ghost");
		itemEB = IsItemAvailable("item_ethereal_blade");
		
		-- Consider using each ability
		castTWDesire, castTWLocation = ConsiderTimeWalk();
		castFBDesire, castFBTarget = ConsiderFireblast();
		castFB2Desire, castFB2Target = ConsiderFireblast2();
		castRCDesire, castRCTarget = ConsiderReplicate();
		castGhostDesire = ConsiderGhostScepter();
		castEBDesire, castEBTarget = ConsiderEtherealBlade();
		
		
		if ( castTWDesire > 0 ) 
		then
			bot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
			return;
		end	
		
		if ( castEBDesire > 0 ) 
		then
			bot:Action_UseAbilityOnEntity( itemEB, castEBTarget );
			alreadyCastEB = true;
			return;
		end
		
		if ( castFBDesire > 0 ) 
		then
			bot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			alreadyCastEB = false;
			return;
		end
		
		if ( castFB2Desire > 0 ) 
		then
			bot:Action_UseAbilityOnEntity( abilityFB2, castFB2Target );
			return;
		end

		if ( castRCDesire > 0 ) 
		then
			bot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
			return;
		end
		
		
		if castGhostDesire > 0 then
			bot:Action_UseAbility( itemGhost );
			return;
		end
	end
end

function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end
	
function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castEBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nMinAGIX = abilityFB:GetSpecialValueFloat("damage_min");
	local nMaxAGIX =  abilityFB:GetSpecialValueFloat("damage_max");
	local nAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nDamage = 0; 
	
	if nAGI > nSTR and ( nAGI - nSTR ) / nSTR >= 0.5 then
		nDamage = nMaxAGIX * nAGI;
	else
		nDamage = nMinAGIX * nAGI;
	end
	
	if alreadyCastEB then
		-- If we're going after someone
		if J.IsGoingOnSomeone(bot)
		then
			local npcTarget = bot:GetTarget();
			if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = bot:GetTarget();
	if J.IsValidHero(npcTarget) and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL ) and J.CanCastOnMagicImmune(npcTarget) 
	   and J.IsInRange(npcTarget, bot, nCastRange+200) 
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) 
			   and J.IsInRange(npcTarget, bot, nCastRange+200) and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end	

function ConsiderFireblast2()

	-- Make sure it's castable
	if ( not abilityFB2:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nCastRange = abilityFB2:GetCastRange();
	local nMinStun = abilityFB2:GetSpecialValueFloat("stun_min");
	local nMaxStun = abilityFB2:GetSpecialValueFloat("stun_max");
	local nAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY); 
	local nSTR = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nStun = 0; 
	
	if nSTR > nAGI and ( nSTR - nAGI ) / nAGI >= 0.5 then
		nStun = nMaxStun;
	else
		nStun = nMinStun;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnMagicImmune(npcEnemy) 
			    and nStun > nMinStun and J.IsDisabled(npcEnemy) == false ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) 
			   and J.IsInRange(npcTarget, bot, nCastRange+200) and nStun > nMinStun and J.IsDisabled(npcTarget) == false 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end	


function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or bot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetCastRange()
	local nCastPoint = abilityTW:GetCastPoint();
	local nSpeed = abilityTW:GetSpecialValueInt("speed");
	local nDamage = abilityTW:GetAbilityDamage();
	local nAttackRange = bot:GetAttackRange();

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation( bot, GetAncient(GetTeam()):GetLocation(), nCastRange );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local loc = J.GetEscapeLoc();
		    	return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation( bot, loc, nCastRange );
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, bot )/ nSpeed ) + nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderMorphAgility()
	
	-- Make sure it's castable
	if ( not abilityMRA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) 
			or bot:WasRecentlyDamagedByAnyHero(2.0) == true or bot:WasRecentlyDamagedByTower(2.0) == true 
		then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget)  and J.IsInRange(npcTarget, bot, 1300)  and bot:GetHealth() < 0.35 * bot:GetMaxHealth() then
			return BOT_ACTION_DESIRE_NONE, 0;
		end
	end	
	
	local nBonusAgi = abilityMRA:GetSpecialValueInt("bonus_attributes");
	local currAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);

	if bot:GetMana() < 1 and abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif bot:GetMana() < 1 and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_NONE;
	end

	if currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) < 2.0 + plusFactor  and not abilityMRA:GetToggleState() then
		--print("start")
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) >= 2.0 + plusFactor and abilityMRA:GetToggleState() then
		--print('stop')
		return BOT_ACTION_DESIRE_LOW;
	elseif bot:DistanceFromFountain() == 0 and currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then	
		return BOT_ACTION_DESIRE_LOW;
	elseif currAGI < currSTRENGTH and not abilityMRA:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMorphStrength()

	-- Make sure it's castable
	if ( not abilityMRS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local currAGI = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
	local currSTRENGTH = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 1300)   then
			if bot:GetHealth() < 0.3 * bot:GetMaxHealth() and  abilityMRS:GetToggleState() == false then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif bot:GetHealth() > 0.3 * bot:GetMaxHealth() and  bot:GetHealth() < 0.35 * bot:GetMaxHealth() and abilityMRS:GetToggleState() == true then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end	
	
	if bot:GetMana() < 1 and abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_LOW;
	elseif bot:GetMana() < 1 and not abilityMRS:GetToggleState() then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and not abilityMRS:GetToggleState() then
			--print("Retreat Active")
			return BOT_ACTION_DESIRE_MODERATE;
		elseif tableNearbyEnemyHeroes == nil and #tableNearbyEnemyHeroes < 1 and abilityMRS:GetToggleState() then 	
			--print("Retreat Non Active")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) <= 2.2 + plusFactor and abilityMRS:GetToggleState() then
		--print("Agi Higher Active")
		return BOT_ACTION_DESIRE_LOW;	
	elseif currAGI >= currSTRENGTH and ( currAGI - currSTRENGTH ) / ( currSTRENGTH / 2 ) > 2.2 + plusFactor and not abilityMRS:GetToggleState() then
		--print("Agi Higher Non Active")
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReplicate()

	-- Make sure it's castable
	if ( not abilityRC:IsFullyCastable() or bot:GetHealth() < 0.4*bot:GetMaxHealth() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityRC:GetCastRange();
	local nCastPoint = abilityRC:GetCastPoint();
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 ) 
		then 
			local nMaxAD = 0;
			local target = nil;
			for _,enemy in pairs(tableNearbyEnemyHeroes)
			do
				local enemyAD = enemy:GetAttackDamage();
				if enemyAD > nMaxAD then
					target = enemy;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200) 
		   and npcTarget:GetHealth()/npcTarget:GetMaxHealth() > 0.75  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end	

function ConsiderGhostScepter()

	-- Make sure it's castable
	if ( itemGhost == nil or not itemGhost:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEtherealBlade()

	-- Make sure it's castable
	if ( itemEB == nil or not itemEB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200)  
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

return X