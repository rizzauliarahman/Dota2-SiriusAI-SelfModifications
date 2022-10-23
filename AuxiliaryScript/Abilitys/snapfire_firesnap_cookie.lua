-----------------
--英雄：电炎绝手
--技能：龙炎饼干
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('snapfire_firesnap_cookie')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 500 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation() 
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- 获取一些必要参数
	local nCastRange  = ability:GetCastRange() + aetherRange;	--施法范围
	local sCastType = 'unit'	
	local hEffectTarget = nil 
	local nInRangeEnmyList = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE)
		
	local hAllyList = J.GetAlliesNearLoc(bot:GetLocation(),880)
	for _,npcAlly in pairs(hAllyList) 
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.CanCastOnNonMagicImmune(npcAlly)
		then
			if  not npcAlly:IsInvisible()
				and npcAlly:GetActiveMode() == BOT_MODE_RETREAT
				and npcAlly:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),20)
				and npcAlly:DistanceFromFountain() > 600 
			then		
				hEffectTarget = npcAlly
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, 'force_staff-ally_retreat'
			end
			
			if J.IsGoingOnSomeone(npcAlly)
			then
				local hAllyTarget = J.GetProperTarget(npcAlly);
				if J.IsValidHero(hAllyTarget)
					and J.CanCastOnNonMagicImmune(hAllyTarget)
					and GetUnitToUnitDistance(hAllyTarget,npcAlly) > npcAlly:GetAttackRange() + 100
					and GetUnitToUnitDistance(hAllyTarget,npcAlly) < npcAlly:GetAttackRange() + 700
					and npcAlly:IsFacingLocation(hAllyTarget:GetLocation(),20)
					and not hAllyTarget:IsFacingLocation(npcAlly:GetLocation(),90)
					and J.GetEnemyCount(npcAlly,1600) < 3
				then
					hEffectTarget = npcAlly
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget;
				end
			end
			
			if J.IsStuck(npcAlly)
			then
				hEffectTarget = npcAlly
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget;
			end
		end		
		
	end
	
	for _,npcAlly in pairs(hAllyList) 
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
		   and npcAlly:GetUnitName() == "npc_dota_hero_crystal_maiden"
		   and J.CanCastOnNonMagicImmune(npcAlly)
		   and (npcAlly:IsInvisible() or npcAlly:GetHealth()/npcAlly:GetMaxHealth() > 0.8)
		   and (npcAlly:IsChanneling() and not npcAlly:HasModifier("modifier_teleporting") )
		then
			local enemyHeroesNearbyCM = npcAlly:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
			for _,npcEnemy in pairs( enemyHeroesNearbyCM )
			do
				if npcEnemy ~= nil and npcEnemy:IsAlive()
					and J.CanCastOnNonMagicImmune(npcEnemy)
					and GetUnitToUnitDistance(npcEnemy,npcAlly) > 835
					and npcAlly:IsFacingLocation(npcEnemy:GetLocation(),30)
			    then
					hEffectTarget = npcAlly
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget;
				end
			end
		end		
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;