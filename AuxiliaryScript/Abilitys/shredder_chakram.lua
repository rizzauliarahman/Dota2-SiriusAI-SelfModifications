-----------------
--英雄：伐木机
--技能：锯齿飞轮
--键位：R
--类型：指向地点
--作者：Меня завут Зона!
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shredder_chakram')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
        bot:Action_UseAbilityOnLocation( ability, castTarget['target'] ) --使用技能
        bot.ultLoc = castTarget['target']
		bot.ultTime1 = DotaTime()
		bot.ultETA1 = castTarget['eta'] + 0.5
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
       or ability:IsHidden()
	then 
		return BOT_ACTION_DESIRE_NONE, {
            ['target'] = 0,
            ['eta'] = 0,
        }; --没欲望
	end

    -- Get some of its values
	local nRadius = ability:GetSpecialValueFloat( "radius" );
	local nSpeed = ability:GetSpecialValueFloat( "speed" );
	local nCastRange = GetProperCastRange(false, bot, ability:GetCastRange());
	local nManaCost = ability:GetManaCost( );
	local nDamage = 2*ability:GetSpecialValueInt("pass_damage");

	--------------------------------------
	-- Mode based usage
	-------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local loc = npcEnemy:GetLocation();
				local eta = GetUnitToLocationDistance(bot, loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, {
                    ['target'] = loc,
                    ['eta'] = eta,
                };
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if J.IsDefending(bot) or J.IsPushing(bot)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and bot:GetMana() / bot:GetMaxMana() > 0.65 ) 
		then
			local loc = locationAoE.targetloc;
			local eta = GetUnitToLocationDistance(bot, loc) / nSpeed;
			return BOT_ACTION_DESIRE_LOW, {
                ['target'] = loc,
                ['eta'] = eta,
            };
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange-200) 
		then
			local Loc = GetUltLoc(bot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(bot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, {
                    ['target'] = Loc,
                    ['eta'] = eta,
                };
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, {
        ['target'] = 0,
        ['eta'] = 0,
    };
	
end

function GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + 200;
	elseif abilityCR + 200 <= 1600 then
		return abilityCR + 200;
	elseif abilityCR > 1600 then
		return 1600;
	else
		return abilityCR;
	end
end

function GetUltLoc(npcBot, enemy, nManaCost, nCastRange, s)

	local v=enemy:GetVelocity();
	local sv=J.Site.GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;

	if GetUnitToLocationDistance(npcBot,dest)>nCastRange or npcBot:GetMana()<100+nManaCost then
		return nil;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not enemy:IsFacingLocation(Fountain(GetOpposingTeam()),60)) ) then
		dest=VectorTowards(y,Fountain(GetOpposingTeam()),180);
	end

	if J.IsDisabled(enemy) then
		dest=enemy:GetLocation();
	end
	
	return dest;
	
end

function Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

function VectorTowards(s,t,d)
	local f=t-s;
	f=f / J.Site.GetDistance(f,Vector(0,0));
	return s+(f*d);
end

return X;