local C = {}

dkjson = require( "game/dkjson" )
local H  = require(GetScriptDirectory()..'/AuxiliaryScript/HttpServer')

local oneScenario = nil
local oneTriggerScenario = nil
local playerNumber = nil
--当前bot剧本缓存
--[[
    scenario
    缓存结构
    {
        时序剧本
        sequential
        {
            speech    讲话内容
            all       是否公共频道讲话
            interval  距离上一次讲话间隔
            botId     规定讲话的电脑ID 字符串all代表全员讲话 only代表仅第一个触发的电脑讲话
            team      讲话阵容 TEAM_RADIANT（天辉） 或 TEAM_DIRE（夜魇）
        }
        触发剧本
        trigger
        {
            scenarioType        触发类型 []死亡 []杀敌 []逃脱 []反塔 []团灭 []被团灭
            scenarioTimeNeeded  剧本所需时间
            scenario            触发中的时序剧本
            [
                {
                    speech    讲话内容
                    all       是否公共频道讲话
                    interval  距离上一次讲话间隔
                }
            ]
            state               剧本状态 true为运行中，false为等待触发
            handling            结束后处理方式 reset为复位 del为删除
            triggerCD           触发CD
        }
    }
]]

--bot数据
--[[
    scenario 缓存剧本
    speechTime  上一次说话时间
    scenarioTimeNeeded  因触发剧本导致的时序延后时间
    triggerScenario  正在执行的触发剧本
    triggerspeechTime  触发剧本中的上一次说话时间
    TriggerTime 当前脚本触发时间
    inWipe  在团灭中
    inEnemyWipe  在对方团灭中
    inEscape  在逃脱中
]]

--[[
    聊天剧本核心程序，需要每帧调用
]]
function C.Speech()
    local bot = GetBot()
    local time = DotaTime()

    if bot.scenario ~= nil
    then

        --时序剧本
        if bot.scenario.sequential ~= nil 
           and #bot.scenario.sequential > 0
        then

            local scenario = bot.scenario.sequential[#bot.scenario.sequential]
            local scenarioTimeNeeded = 0

            if bot.speechTime == nil then bot.speechTime = 0 end --如果从未说过话，设置时间为0
            if bot.scenarioTimeNeeded == nil then scenarioTimeNeeded = 0 else scenarioTimeNeeded = bot.scenarioTimeNeeded end --如果正在执行触发型剧本，则延后时序剧本
            if scenario.interval == nil then scenario.interval = 0 end
            if bot.speechTime + scenario.interval + scenarioTimeNeeded < time then --到说话时间了
                if scenario.botId == 'only' then --删除其他人的此条说话数据
                    local numPlayers = GetTeamPlayers(GetTeam())
                    for i,id in pairs(numPlayers) 
                    do
                        local aBot = GetTeamMember(i)
                        if id ~= bot:GetPlayerID() --如果是自己，则不删除
                           and aBot ~= nil
                           and aBot.scenario ~= nil
                           and aBot.scenario.sequential ~= nil
                           and #aBot.scenario.sequential == #bot.scenario.sequential --这个bot第一个执行，删掉其他人的触发，其他人执行的时候，这个触发已经全部删除了，大概
                        then
                            table.remove(aBot.scenario.sequential)
                        end
                    end
                end
                local scenarioContent = nil
                --根据说话内容的类型分配说话内容，类型只能为字符串或数组
                if type(scenario['speech']) == 'table' then
                    scenarioContent = scenario['speech'][RandomInt(1, #scenario['speech'])]
                elseif type(scenario['speech']) == 'string' then
                    scenarioContent = scenario['speech']
                end
                --如果内容类型错误，则不说话
                if scenarioContent ~= nil then
                    bot:ActionImmediate_Chat(scenarioContent, scenario['all'])
                end
                bot.speechTime = time --设置上一次说话时间
                table.remove(bot.scenario.sequential) --删除已说过的剧本内容
            end
        end

        --触发剧本
        if bot.scenario.trigger ~= nil 
           and bot.triggerScenario == nil --有正在执行的触发剧本时，不再触发新的剧本
        then
            --检查所有触发条件
            for i,trigger in pairs(bot.scenario.trigger)
            do
                --根据不同的触发条件，进行检查程序
                C.CheckTrigger(bot, trigger, i)
            end
        end

        --执行触发中的剧本
        if bot.triggerScenario ~= nil then
            --[[
                触发中剧本的属性
                triggerScenarioId  id
                scenario           剧本
                handling           结束处理
            ]]
            local triggerScenario = bot.triggerScenario.scenario --剧本
            local handling = bot.triggerScenario.handling --结束内容
            local triggerId = bot.triggerScenario.triggerScenarioId --剧本id

            --触发中的剧本执行完了，执行结束设定操作
            if #triggerScenario == 0 then
                if handling == 'reset' then --重置
                    bot.scenario.trigger[triggerId].state = false
                else --不是重置就删除
                    table.remove(bot.scenario.trigger, triggerId)
                end
                --通用变量重置
                bot.triggerScenario = nil
                bot.triggerspeechTime = nil
                return
            end

            local scenario = triggerScenario[#triggerScenario] --设置当前要执行的剧本内容

            if bot.triggerspeechTime == nil then bot.triggerspeechTime = time end --如果从未说过话，设置时间为当前时间

            if bot.triggerspeechTime + scenario.interval < time then --到说话时间了
                if scenario.botId == bot:GetPlayerID()
                   or scenario.botId == 'only'
                   or scenario.botId == 'all'
                then
                    if scenario.botId == 'only' then --删除其他人的此条说话数据
                        local numPlayers = GetTeamPlayers(GetTeam())
                        for i,id in pairs(numPlayers) 
                        do
                            local aBot = GetTeamMember(i)
                            if id ~= bot:GetPlayerID() --如果是自己，则不删除
                               and aBot ~= nil
                               and aBot.triggerScenario ~= nil
                               and aBot.triggerScenario.scenario ~= nil
                               and #aBot.triggerScenario.scenario == #triggerScenario --这个bot第一个执行，删掉其他人的触发，其他人执行的时候，这个触发已经全部删除了，大概
                            then
                                table.remove(aBot.triggerScenario.scenario[#triggerScenario])
                            end
                        end
                    end
                    local scenarioContent = nil
                    --根据说话内容的类型分配说话内容，类型只能为字符串或数组
                    if type(scenario['speech']) == 'table' then
                        scenarioContent = scenario['speech'][RandomInt(1, #scenario['speech'])]
                    elseif type(scenario['speech']) == 'string' then
                        scenarioContent = scenario['speech']
                    end
                    --如果内容类型错误，则不说话
                    if scenarioContent ~= nil then
                        bot:ActionImmediate_Chat(scenarioContent, scenario['all'])
                    end
                    bot.triggerspeechTime = time --设置上一次说话时间
                end
                table.remove(bot.triggerScenario.scenario) --删除已说过的剧本内容
            end

        end

    end
end

function C.JoinScenario(bot, scenario)
    if bot.scenario == nil
    then
        bot.scenario = {}
    end
    --时序剧本缓存
    if bot.scenario.sequential == nil then
        bot.scenario.sequential = {}
    end
    for _,sequential in pairs(scenario.sequential)
    do
        local botId = bot:GetPlayerID()
        if sequential.botId ~= nil 
        then 
            botId = sequential.botId
        end --如果指定了bot说话，更改说话id
        --if botId == 'only' and oneScenario == nil then oneScenario = true end --如果指定只说一次则设置状态
        if (botId == bot:GetPlayerID()
           or botId == 'only'
           or botId == 'all'
           --or oneScenario
           )
           and sequential.team == GetTeam()
        then
            --oneScenario = false
            table.insert(bot.scenario.sequential,sequential) --将获取到的剧本全部加入剧本缓存
        end
    end
    --oneScenario = nil

    --触发剧本缓存
    --触发型剧本在触发时进行botid分配，这里不再进行检查
    if bot.scenario.trigger == nil then
        bot.scenario.trigger = {}
    end
    for _,trigger in pairs(scenario.trigger)
    do
        table.insert(bot.scenario.trigger,trigger) --将获取到的剧本全部加入剧本缓存
        --[[
        for i,sequential in pairs(trigger.scenario)
        do
            local botId = bot:GetPlayerID()
            if sequential.botId ~= nil then botId = sequential.botId end --如果指定了bot说话，更改说话id
            if botId == 'only' and oneTriggerScenario == nil then oneTriggerScenario = true end --如果指定只说一次则设置状态
            if botId == bot:GetPlayerID() or botId == 'all' or oneTriggerScenario then
                oneTriggerScenario = false
                trigger.scenario[i].botId = bot:GetPlayerID()
                table.insert(bot.scenario.trigger,trigger) --将获取到的剧本全部加入剧本缓存
            end
        end
        oneTriggerScenario = nil
        ]]
    end
end

function C.GetScenario()
    local bot = GetBot()
    local botId = bot:GetPlayerID()

    --获取玩家数量
    if playerNumber == nil then
        playerNumber = 0
        local nArreysTeam = GetTeamPlayers(GetTeam())
        for i,aTeam in pairs(nArreysTeam)
        do
            if IsPlayerBot(aTeam) then playerNumber = playerNumber + 1 end
        end
    end

    local data = {
        operation = '"getscenario"'
    }

    data.botId = botId
    --默认剧本
    local scenario = {}
    scenario.sequential = {
        {
            speech = {'拖的太久了，快推吧'},
            all = false,
            interval = 600,
            botId = 'only',
            team = TEAM_RADIANT
        },
        {
            speech = {'继续拖下去会不会崩盘啊'},
            all = false,
            interval = 600,
            botId = 'only',
            team = TEAM_DIRE
        },
        {
            speech = {'哼，看我这把打爆你','看你这把能不能超鬼┗|｀O′|┛'},
            all = true,
            interval = 10,
            botId = 'only',
            team = TEAM_RADIANT
        },
        {
            speech = {'又是你，我要一雪前耻','哈哈哈，菜鸟又来了','没想到还能碰上','大家注意了，对面说话的这个人贼菜'},
            all = true,
            interval = -55,
            botId = 'only',
            team = TEAM_DIRE
        },
        {
            speech = {'又见面了','好久不见','真是缘分啊'},
            all = true,
            interval = -60,
            botId = 'only',
            team = TEAM_RADIANT
        },
    }
    scenario.trigger = {
        {
            scenarioType = '被团灭',
            scenarioTimeNeeded = 15,
            scenario = {
                {
                    speech = {'简直没法打', '都是队友太菜', '这锅我不背'},
                    all = true,
                    interval = 10,
                    botId = 'only'
                },
                {
                    speech = {'能不能好好打', '谁背锅？','队友呢队友呢队友呢','这局还能打？'},
                    all = false,
                    interval = 3,
                    botId = 'only'
                },
                {
                    speech = {'你们太狠了', '等我复活干翻你们', '哎~带不动，带不动','我们随时可以翻盘','怎么？做啥啥不行？嘲讽第一名？'},
                    all = true,
                    interval = 2,
                    botId = 'only'
                },
            },
            state = false,
            handling = 'reset'
        },
        {
            scenarioType = '团灭',
            scenarioTimeNeeded = 8,
            scenario = {
                {
                    speech = {'漂亮', '对面太菜了','五杀！厉害啦','大哥牛逼！'},
                    all = false,
                    interval = 3,
                    botId = 'only'
                },
                {
                    speech = {'是你们太菜了', '哈哈哈，你们死也死在一起', '欢迎复仇'},
                    all = true,
                    interval = 5,
                    botId = 'all'
                }
            },
            state = false,
            handling = 'reset'
        },
        {
            scenarioType = '击杀',
            scenarioTimeNeeded = 10,
            scenario = {
                {
                    speech = {'第一个死在我刀下的小伙伴', '第一滴血，哈哈哈'},
                    all = true,
                    interval = 2,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'del'
        },
        {
            scenarioType = '死亡',
            scenarioTimeNeeded = 17,
            scenario = {
                {
                    speech = '(ˉ▽￣～) 切~~',
                    all = true,
                    interval = 5,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'del'
        },
        {
            scenarioType = '击杀',
            scenarioTimeNeeded = 10,
            scenario = {
                {
                    speech = {'哈哈哈', '你好菜哦'},
                    all = true,
                    interval = 2,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'del',
            triggerCD = 1 * 60
        },
        {
            scenarioType = '死亡',
            scenarioTimeNeeded = 17,
            scenario = {
                {
                    speech = '是不是输不起',
                    all = true,
                    interval = 12,
                    botId = 'only'
                },
                {
                    speech = '有什么了不起的',
                    all = true,
                    interval = 5,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'del',
            triggerCD = 1 * 60
        },
        {
            scenarioType = '击杀',
            scenarioTimeNeeded = 10,
            scenario = {
                {
                    speech = '(╯‵□′)╯炸弹！•••*～●',
                    all = true,
                    interval = 2,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'del',
            triggerCD = 1 * 60
        },
        {
            scenarioType = '死亡',
            scenarioTimeNeeded = 17,
            scenario = {
                {
                    speech = {'你等着','该电脑由于言语过激，已被屏蔽','我会回来复仇的','技不如人，甘拜下风'},
                    all = true,
                    interval = 5,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'reset',
            triggerCD = 1 * 60
        },
        {
            scenarioType = '逃脱',
            scenarioTimeNeeded = 5,
            scenario = {
                {
                    speech = {'来啊来啊，来追我啊', '好险好险', '溜了溜了'},
                    all = true,
                    interval = 5,
                    botId = 'only'
                }
            },
            state = false,
            handling = 'reset',
            triggerCD = 2 * 60
        }
    }
    --加载锦囊剧本
    if xpcall(function(loadDir) require( loadDir ) end, function(err) print('未加载剧本，使用默认剧本') end, 'game/AI锦囊/剧本')
    then
        scenario = require( 'game/AI锦囊/剧本' )
    end
    C.JoinScenario(bot, scenario)
    

    --H.HttpPost(data, 'api.alcedo.top:3010',
    --    function (res, par)
    --        local scenario = dkjson.decode(res)
    --        C.JoinScenario(par, scenario)
    --    end
    --, bot, true);
end

--触发型剧本检查函数
function C.CheckTrigger(bot, script, id)
    if script.state then return end --这个脚本正在运行，不再执行检查
    local time = DotaTime() --当前时间，用于检查触发冷却，带冷却的操作触发冷却均为共享操作

    local scenarioTimeNeeded = script.scenarioTimeNeeded
    local handling = script.handling

    if bot.TriggerTime == nil then 
        bot.TriggerTime = time
    end

    if script.scenarioType == '团灭' then
        if C.NumOfAliveHero(true) == 0 and DotaTime() > 0 then 
            --团灭时的操作
            if bot.inWipe == nil then
                bot.inWipe = false
            end
            if not bot.inWipe then
                local operation = {}
                operation.triggerScenarioId = id --触发器id
                operation.scenario = script.scenario --剧本
                operation.handling = handling --结束方式
                bot.triggerScenario = operation --正在执行的触发器配置
                bot.inWipe = true --在团灭触发中
            end
        else
            bot.inWipe = false --设置结束团灭中状态，允许同类再次触发
        end
    end
    if script.scenarioType == '被团灭' then
        if C.NumOfAliveHero(false) == 0 and DotaTime() > 0 then 
            --被团灭时的操作
            if bot.inEnemyWipe == nil then
                bot.inEnemyWipe = false
            end
            if not bot.inEnemyWipe then
                local operation = {}
                operation.triggerScenarioId = id
                operation.scenario = script.scenario
                operation.handling = handling
                bot.triggerScenario = operation
                bot.inEnemyWipe = true
            end
        else
            bot.inEnemyWipe = false
        end
    end
    if script.scenarioType == '击杀' then
        --击杀敌人时的操作
        if script.triggerCD == nil then script.triggerCD = 0 end
        if script.triggerCD + bot.TriggerTime <= time then
            if bot.botKill == nil then
                bot.botKill = GetHeroKills(bot:GetPlayerID())
            end
            if bot.botKill < GetHeroKills(bot:GetPlayerID()) then
                local operation = {}
                operation.triggerScenarioId = id
                operation.scenario = script.scenario
                operation.handling = handling
                bot.triggerScenario = operation
                bot.botKill = GetHeroKills(bot:GetPlayerID())
                bot.TriggerTime = time
            end
        end
    end
    if script.scenarioType == '死亡' then
        --死亡时的操作
        if script.triggerCD == nil then script.triggerCD = 0 end
        if script.triggerCD + bot.TriggerTime <= time then
            if bot.botDeaths == nil then
                bot.botDeaths = GetHeroDeaths(bot:GetPlayerID())
            end
            if bot.botDeaths < GetHeroDeaths(bot:GetPlayerID()) then
                local operation = {}
                operation.triggerScenarioId = id
                operation.scenario = script.scenario
                operation.handling = handling
                bot.triggerScenario = operation
                bot.botDeaths = GetHeroDeaths(bot:GetPlayerID())
                bot.TriggerTime = time
            end
        end
    end
    if script.scenarioType == '逃脱' then
        --逃脱时的操作
        if script.triggerCD == nil then script.triggerCD = 0 end
        if bot.inEscape == nil then
            bot.inEscape = false
        end
        if (not bot:WasRecentlyDamagedByAnyHero(6) --6秒内没受到任何人的攻击
            or bot:DistanceFromFountain() < 800 --在泉水中
           )
           and bot:GetHealth()/bot:GetMaxHealth() < 0.1 --生命低于10%
           and bot:IsAlive()
        then
            if not bot.inEscape then
                local operation = {}
                operation.triggerScenarioId = id
                operation.scenario = script.scenario
                operation.handling = handling
                bot.triggerScenario = operation
                bot.inEscape = true
                bot.TriggerTime = time
            end
        else
            if script.triggerCD + bot.TriggerTime <= time then
                bot.inEscape = false
            end
        end
    end

end

--检查存活英雄
function C.NumOfAliveHero(bEnemy)
	local numPlayers =  GetTeamPlayers(GetTeam());
	if bEnemy then numPlayers =  GetTeamPlayers(GetOpposingTeam()); end
	
	local nCount = 0;
	for i,id in pairs(numPlayers) 
	do
		if IsHeroAlive(id) 
		then
			nCount = nCount + 1;
		end
	end
	return nCount;
end

return C