-----------------
--英雄：育母蜘蛛
--技能：孵化蜘蛛
--键位：Q
--类型：指向目标
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('broodmother_spawn_spiderlings')
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
	
		-- Get some of its values
	local nCastRange = ability:GetCastRange();
	local nDamage = ability:GetSpecialValueInt("damage");
	local level = ability:GetLevel();
	local mana = bot:GetMana() / bot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = bot:GetTarget();
	if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   J.IsInRange(npcTarget, bot, nCastRange + 200)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end

	-- If we're going after someone
	if  bot:GetActiveMode() == BOT_MODE_LANING or
		J.IsDefending(bot) or J.IsPushing(bot) 
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps ( nCastRange + 200, true );
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL) and mana > .45 then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;