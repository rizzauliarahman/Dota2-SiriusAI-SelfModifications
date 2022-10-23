-----------------
--英雄：军团指挥官
--技能：压倒性优势
--键位：Q
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('legion_commander_overwhelming_odds')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 120 --魔法储量
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
		bot:Action_UseAbilityOnLocation( ability, castTarget );
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

	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint( );
	local nDamage = ability:GetSpecialValueInt("damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if J.IsRetreating(bot) then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes ) do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = bot:GetTarget();
	if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) 
		and J.IsInRange(npcTarget, bot, nCastRange+200) and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL)
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  ( J.IsDefending(bot) or J.IsPushing(bot) ) and bot:GetMana() / bot:GetMaxMana() > 0.6
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;