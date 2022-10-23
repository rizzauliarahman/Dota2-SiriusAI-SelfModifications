-----------------
--英雄：虚无之灵
--技能：异化
--键位：W
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('void_spirit_dissimilate')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 160 --魔法储量
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
    X.Compensation()
	bot:ActionQueue_UseAbility( ability ) --使用技能
	bot:ActionQueue_AttackMove(castTarget)
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
	   or bot:DistanceFromFountain() < 600
       or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	--获取一些参数
	local nManaCost   = ability:GetManaCost();		--魔法消耗
	local nSkillLV    = ability:GetLevel();    	--技能等级 
	local nDamage    = ability:GetAbilityDamage();

	local botTarget = J.GetProperTarget(bot);

	local vEscapeLoc = J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), 500)

	--躲避
	if J.IsNotAttackProjectileIncoming(bot, 460)
	   or ( J.IsWithoutTarget(bot) and J.GetAttackProjectileDamageByRange(bot, 1600) >= bot:GetHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc
	end
	
	--撤退
	if J.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc
	end

	--打架
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		   and J.CanCastOnMagicImmune(botTarget)
		   and not J.IsDisabled(botTarget)
		then
			--追击目标
			local vSecondLoc = J.GetUnitTowardDistanceLocation(bot, botTarget, 500);	
			if nSkillLV >= 4
			   and not J.IsInRange(bot,botTarget,300)
			   and J.IsInRange(bot,botTarget,300)
			   and bot:IsFacingLocation(botTarget:GetLocation(),30)
			   and botTarget:IsFacingLocation(J.GetEnemyFountain(),30)
			then
				return BOT_ACTION_DESIRE_HIGH, vSecondLoc
			end
			
		end
	end

	return BOT_ACTION_DESIRE_NONE;
	
end

return X;