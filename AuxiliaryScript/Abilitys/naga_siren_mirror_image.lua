-----------------
--英雄：娜迦海妖
--技能：镜像
--键位：Q
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('naga_siren_mirror_image')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 280 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	bot:ActionQueue_UseAbility( ability ) --使用技能
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = bot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  J.IsDefending(bot) or J.IsPushing(bot)
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 600, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers  ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 400)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;