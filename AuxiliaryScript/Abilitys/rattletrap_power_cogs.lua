-----------------
--英雄：发条技师
--技能：能量齿轮
--键位：W
--类型：无目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('rattletrap_power_cogs')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, castCogsTime;

nKeepMana = 240 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友
castCogsTime = -90;

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	X.Compensation() 
	bot:Action_ClearActions(false)
	bot:ActionQueue_UseAbility( ability ) --使用技能
	castCogsTime = DotaTime();
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

    local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = ability:GetSpecialValueInt('cogs_radius');
	local nColSize	 = 80;
	
	local nDuration = ability:GetSpecialValueFloat('duration');
	
	if DotaTime() < castCogsTime + nDuration then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if ( J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local allies = bot:GetNearbyHeroes(nRadius+2*nColSize, false, BOT_MODE_NONE);
		if #allies <= 1 then
			local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
			if #enemies > 0 then
				local enemies2 = bot:GetNearbyHeroes(nRadius+2*nColSize, true, BOT_MODE_NONE);
				if #enemies2 == 0 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if J.IsValidHero(target) 
			and J.CanCastOnMagicImmune(target) == true 
			and J.IsInRange(target, bot, nRadius) == true
		then
			local allies = bot:GetNearbyHeroes(nRadius+2*nColSize, false, BOT_MODE_NONE);
			if #allies <= 2 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;