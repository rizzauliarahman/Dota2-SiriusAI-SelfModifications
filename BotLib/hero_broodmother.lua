local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,1,1,2,2,1,1,2,6,3,6,3,3,3,6},
	['Buy'] = {
		"item_tango",
		"item_enchanted_mango",
		"item_enchanted_mango",
		"item_quelling_blade",
		"item_magic_wand",
		"item_soul_ring",
		"item_power_treads",
		"item_orchid",
		"item_black_king_bar",
		"item_sange_and_yasha",
		"item_assault",
		"item_sheepstick",
		"item_bloodthorn",
	},
	['Sell'] = {
		"item_octarine_core",
		"item_quelling_blade",
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

local MoveDesire = 0;
local AttackDesire = 0;

function X.MinionThink(hMinionUnit)

	if not hMinionUnit:IsNull() 
	   and hMinionUnit ~= nil 
	   and ( hMinionUnit:GetUnitName() == 'npc_dota_broodmother_spiderling' 
	       or hMinionUnit:IsIllusion() ) 
	then 
		AttackDesire, AttackTarget = ConsiderAttacking(hMinionUnit); 
		MoveDesire, Location = ConsiderMove(hMinionUnit);
		if (AttackDesire > 0)
		then
			hMinionUnit:Action_AttackUnit( AttackTarget, true );
			return
		end
		if (MoveDesire > 0)
		then
			hMinionUnit:Action_MoveToLocation( Location );
			return
		end
	end

end

function ConsiderAttacking(hMinionUnit)
	
	local target = bot:GetTarget();
	local AR = hMinionUnit:GetAttackRange();
	local AD = hMinionUnit:GetAttackDamage();
	
	if target == nil or target:IsTower() or target:IsBuilding() then
		target = bot:GetAttackTarget();
	end
	
	if target ~= nil and GetUnitToUnitDistance(hMinionUnit, bot) <= 1300 then
		return BOT_ACTION_DESIRE_MODERATE, target;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMove(hMinionUnit)
	if not bot:IsAlive() then
		local loc = GetBase()
		return BOT_ACTION_DESIRE_HIGH, loc;
	end

	local target = bot:GetAttackTarget()

	if target == nil or ( target ~= nil and not CanBeAttacked(target) ) or GetUnitToUnitDistance(hMinionUnit, bot) > 1300 then
		return BOT_ACTION_DESIRE_MODERATE, J.Site.GetXUnitsTowardsLocation(bot, GetAncient(GetOpposingTeam()):GetLocation(), 200);
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function CanBeAttacked( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function GetBase()
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	if GetTeam( ) == TEAM_DIRE then
		return DB;
	elseif GetTeam( ) == TEAM_RADIANT then
		return RB;
	end
end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X