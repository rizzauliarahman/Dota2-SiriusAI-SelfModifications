local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local illuOrbLoc = nil

local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'Misunderstand锦囊内容',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0,10},
			['t15'] = {10,0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 1, 2, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"智力斗篷",
			"两个圆环",
			"魔法芒果",
			"树之祭祀",
			"魔瓶",
			"空灵挂件",
			"两个魔法芒果",
			"净化药水",
			"闪烁匕首",
			"净化药水",
			"Eul的神圣法杖",
			"达贡之神力",
			"林肯法球",
			"阿哈利姆神杖",
			"达贡之神力2",
			"漩涡",
			"阿哈利姆神杖2",
			"雷神之锤",
			"达贡之神力3",
			"达贡之神力5",
			"远行鞋2",
			"银月之晶",
		},
		--出售
		['Sell'] = {
			"闪烁匕首",
			"圆环",

			"林肯法球",
			"魔瓶",
			
			"阿哈利姆神杖",
			"空灵挂件",

			"远行鞋",
			"动力鞋",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,1,2,2,6,1,2,1,2,6,3,3,3,6},
	['Buy'] = {
		"树之祭祀",
		"治疗药膏",
		"两个铁树枝干",
		"魔法芒果",
		"净化药水",
		"魔杖" ,
		"速度之靴",
		"纷争面纱",
		"闪烁匕首",
		"Eul的神圣法杖",
		"阿哈利姆神杖",
		"邪恶镰刀",
		"玲珑心",
	},
	['Sell'] = {
		"远行鞋",
		"速度之靴",
	}
}

local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData, true)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

function X.SkillsComplement()

	if X.ConsiderStop() == true 
	then 
		bot:Action_ClearActions(true);
		return; 
	end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','D','E','W','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

function X.ConsiderStop()
	
	if bot:HasModifier("modifier_puck_phase_shift")
	then
		local tableEnemyHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local tableAllyHeroes  = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if #tableEnemyHeroes >= 0
		then
			return true;
		end

		local incProj = bot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(bot, p.location) >= 0 and ( p.is_attack or p.is_dodgeable ) then
				return true;
			end
		end
	end
	return false;

end

return X
-- dota2jmz@163.com QQ:2462331592
