--游戏实时状态记录
--[[
    实现功能
    1、实时记录英雄死亡和击杀数量√
    2、根据实时变化获取击杀者√
    3、获取场上我方英雄等级、装备和价格总和，敌方最近看到的英雄等级、装备和价格总和√
    4、根据上一项获取的数据判断当前优势劣势
    5、根据场上装备数据判断双方物抗、魔抗、物攻、魔攻、控制、逃生、影身等能力值
    6、获取场上塔的状态、兵线的状态、敌人最后的位置、我方英雄的位置、状态（血量、魔量、tpcd、买活状态）
    7、根据场上状态获取3路危险程度、双方野区危险程度
]]

--作弊检查标准
--[[
    聊天输入作弊指令
    金钱突然增加超过1000
        在检查周期内未发生死亡事件
        背包内物品数量总价值未减少（增加金额的50%）
    背包内物品价格突然增加超过5000
        玩家金币未减少（增加物品价值的70%）
    英雄的技能cd超过10秒突然清空且背包内刷新球没进入cd（或没有刷新球）
    英雄是否在死亡读秒时突然复活且买活未进入cd
    英雄技能是否均无冷却
]]

local L = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local H  = require(GetScriptDirectory()..'/AuxiliaryScript/HttpServer')
local json = require "game/dkjson"

local isInit = false
--数据
local nArreysTeam = GetTeamPlayers(GetTeam())
local nEnemysTeam = GetTeamPlayers(GetOpposingTeam())
local nArreysData = {}
local nEnemysData = {}
local consecutivekills = 0

--计时
local killInTime = 0 --上一次击杀时间
local dieInTime = 0 --上一次死亡时间
local countTime = 0

--击杀、死亡
local evenKillStatistics = 0
local evenDeathStatistics = 0

--数据发送
local data = {}
local lastUpdate = -1000.0
L.GameEND = false
L.DataUpload = false
L.DataUploadPlayerList = {}

--发言冷却

function L.init()

    if not isInit then
    -- HTTP SYSTEM INIT
    --local postData = {
    --    operation = '"init"',
    --}
    --H.HttpPost(postData, 'api.alcedo.top:3001')

    for i,aData in pairs(nArreysTeam)
    do
        local botid = aData
		local member = GetTeamMember(i);
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = 0

            --物品
            for t = 0, 5 do
                local item = member:GetItemInSlot(t)
                if item ~= nil then
                    heroItem[t] = item:GetName()
                    heroItemCost = heroItemCost + GetItemCost(heroItem[t])
                end
            end
            nArreysData[botid] = {
                ['hero'] = member,--指向英雄单位
                ['player'] = botid,--玩家id
                ['name'] = GetSelectedHeroName(botid),--英雄名称
                ['bot'] = IsPlayerBot(botid),--是否是电脑
                ['kill'] = GetHeroKills(botid),--击杀数
                ['death'] = GetHeroDeaths(botid),--死亡数
                ['assist'] = GetHeroAssists(botid),--助攻数
                ['level'] = GetHeroLevel(botid),--英雄等级
                ['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
                ['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
                ['location'] = member:GetLocation(),--当前位置
                ['item'] = heroItem,--当前装备
                ['itemCost'] = heroItemCost,--装备总值
                ['gold'] = member:GetGold(),--当前金钱
                ['buyback'] = member:HasBuyback(),--买活状态
                ['killhero'] = '',
                ['herokill'] = '',
            }

            data["heroinfo"] = {
                player = botid,--玩家id
                name = GetSelectedHeroName(botid),--英雄名称
                kill = GetHeroKills(botid),--击杀数
                death = GetHeroDeaths(botid),--死亡数
                assist = GetHeroAssists(botid),--助攻数
                level = GetHeroLevel(botid),--英雄等级
                health = member:GetHealth()/member:GetMaxHealth(),--当前血量
                mana = member:GetMana()/member:GetMaxMana(),--当前魔法
                itemCost = heroItemCost,--装备总值
                gold = member:GetGold(),--当前金钱
            }
            --InstallDamageCallback(botid ,function ( tChat ) print(tChat.player_id..'---damage'..tChat.damage) end);
        end
        
    end
    for i,eData in pairs(nEnemysTeam)
    do
        local botid = eData
        local member = GetTeamMember(i);
        
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = 0
            local info = GetHeroLastSeenInfo(botid)

            --物品,有待确认能否生效
            for t = 0, 5 do
                local item = member:GetItemInSlot(t)
                if item ~= nil then
                    heroItem[t] = item:GetName()
                    heroItemCost = heroItemCost + GetItemCost(heroItem[t])
                end
            end

            --位置
            local botLocation = member:GetLocation()
            local botSeenTime = 0
            if botLocation == nil then
                local dInfo = info[1];
                if dInfo ~= nil then
                    botLocation = dInfo.location --单位曾经的位置
                    botSeenTime = dInfo.time_since_seen --上次看到的时间
                end
            end

            nEnemysData[botid] = {
                ['hero'] = member,--指向英雄单位
                ['player'] = botid,--玩家id
                ['name'] = GetSelectedHeroName(botid),--英雄名称
                ['bot'] = IsPlayerBot(botid),--是否是电脑
                ['kill'] = GetHeroKills(botid),--击杀数
                ['death'] = GetHeroDeaths(botid),--死亡数
                ['assist'] = GetHeroAssists(botid),--助攻数
                ['level'] = GetHeroLevel(botid),--英雄等级
                ['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
                ['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
                ['location'] = botLocation,--位置
                ['seentime'] = botSeenTime,--丢失时间
                ['item'] = heroItem,--当前装备
                ['itemCost'] = heroItemCost,--装备总值
            }
        end

    end
    end

    isInit = true
end

function L.Update()
    
    local bot = GetBot()

    --游戏结束
	local win = nil
    if GetAncient(GetTeam()):GetHealth()/GetAncient(GetTeam()):GetMaxHealth() < 0.15 then
        win = GetOpposingTeam()
    elseif GetAncient(GetOpposingTeam()):GetHealth()/GetAncient(GetOpposingTeam()):GetMaxHealth() < 0.15 then
        win = GetTeam()
    end

    if win ~= nil 
       and not L.GameEND 
       and L.DataUpload 
    then
        local data = {
            operation = 'gameEnd',
            gameData = {}
        }
                
        local Team = GetTeamPlayers(GetTeam())

        for i,aTeam in pairs(nArreysTeam)
        do
            local memberData = {}
            local member = GetTeamMember(i)
            local winTeam = 'true'
            if win ~= GetTeam() then winTeam = 'false' end
            local isBot = 'false'
            if IsPlayerBot(aTeam) then isBot = 'true' end
            memberData.Team       = GetTeam() == TEAM_DIRE and '夜魇' or '天辉'  --阵营
            memberData.Win        = winTeam                                     --是否胜利
            memberData.Hero       = J.Chat.GetNormName(member)                  --英雄
            memberData.Level      = member:GetLevel()                           --等级
            memberData.MaxHealth  = member:GetMaxHealth()                       --最大生命值
            memberData.MaxMana    = member:GetMaxMana()                         --最大魔法值
            memberData.Gold       = member:GetGold()                            --金钱
            memberData.kill       = GetHeroKills(member:GetPlayerID())          --击杀数
            memberData.Death      = GetHeroDeaths(member:GetPlayerID())         --死亡数
            memberData.Assist     = GetHeroAssists(member:GetPlayerID())        --助攻数
            memberData.Bot        = isBot                                       --是否为电脑
            for i=0,5 do                                                        --装备
                local item = member:GetItemInSlot(i);
                if item ~= nil then
                    memberData['Item'..i] = J.Chat.GetItemName(item:GetName())
                else
                    memberData['Item'..i] = '"none"'
                end
            end
            if member.kits ~= nil then
                memberData.kits = json.encode(member.kits)
            end
            table.insert(data.gameData,json.encode(memberData))
            L.GameEND = true
        end

        H.HttpPost(data, 'api.alcedo.top:3010',
            function (res, par)
                print(par..'数据已上报')
            end
        , data.Hero, true);
    end

    --每30秒执行一次
    --if DotaTime() > countTime + 30.0
    --then
    --    countTime  = DotaTime();
    --    local postData = {
    --        operation = '"heartbeat"',
    --    }
    --    H.HttpPost(postData, 'api.alcedo.top:3001')
    --end

    for i,data in pairs(nArreysData)
    do
        local heroItem = {}
        local heroItemCost = 0
        local botid = data['player']
        local member = data['hero']

        --物品
        for t = 0, 5 do
            local item = member:GetItemInSlot(t)
            if item ~= nil then
                heroItem[t] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[t])
            end
        end

        --击杀了哪个敌人
        if GetHeroKills(botid) ~= data['kill'] then
            print(J.Chat.GetNormName(data['hero'])..'击杀了敌人')
            --local postData = {
            --    operation = '"kill"',
            --    hero = '"'..J.Chat.GetNormName(data['hero'])..'"',
            --}
            --H.HttpPost(postData, 'api.alcedo.top:3001')
            L.Chatwheel(true, data)
            --bug了
            --for _,eData in pairs(nEnemysData) do
            --    print(GetHeroDeaths(eData['player']) ..' - '.. eData['death'])
            --    if GetHeroDeaths(eData['player']) > eData['death'] then
            --        nArreysData[i]['killhero'] = eData['name']
            --        local postData = {
            --            operation = '"击杀信息"',
            --            hero = '"'..J.Chat.GetNormName(data['hero'])..'"',
            --            kill = '"'..J.Chat.GetNormName(eData['hero'])..'"',
            --        }
            --        H.HttpPost(postData, 'api.alcedo.top:3002')
            --        print(J.Chat.GetNormName(data['hero'])..'击杀了'..J.Chat.GetNormName(eData['hero']))
            --        L.Chatwheel(true, nArreysData[i])
            --    end
            --end
            --for l = 1, #nEnemysTeam do
            --    if GetHeroDeaths(nEnemysTeam[l]) > nEnemysData[nEnemysTeam[l]]['death'] then
            --        nArreysData[i]['killhero'] = nEnemysData[nEnemysTeam[l]]['name']
            --        print(J.Chat.GetNormName(data['hero'])..'击杀了'..J.Chat.GetNormName(nEnemysData[nEnemysTeam[l]]['hero']))
            --        L.Chatwheel(true, nArreysData[i])
            --    end
            --end

        end

        --被哪个敌人击杀
        if GetHeroDeaths(botid) > data['death'] then
            print(J.Chat.GetNormName(data['hero'])..'被敌人击杀了')
            --local postData = {
            --    operation = '"death"',
            --    hero = '"'..J.Chat.GetNormName(data['hero'])..'"',
            --}
            --H.HttpPost(postData, 'api.alcedo.top:3001')
            --同样bug了
            --被击杀后检查双方装备差距
            --local situation = L.Situation()
            --print('装备差:'..situation['itemDifference'])
            --if situation['itemDifference'] < -0.4 then
            --    --data['hero']:ActionImmediate_Chat('小心了，敌人的装备比我们强大！', false)
            --    bot:ActionImmediate_Chat('小心了，敌人的装备比我们强大！', false)
            --end
            --for _,eData in pairs(nEnemysData) do
            --    if eData['itemCost'] / (situation['enemyItemCost'] / 5) > 0.5
            --        and  eData['itemCost'] > situation['arreyItemCost'] / 5 
            --    then
            --        --数据统计
            --        print(J.Chat.GetNormName(eData['hero']))
            --        --data['hero']:ActionImmediate_Chat('谨慎对待 '..J.Chat.GetNormName(eData['hero'])..' ，他的装备远远强于他的队友，并且比我们的装备平均强度要高。', false)
            --        --bot:ActionImmediate_Chat('谨慎对待 '..J.Chat.GetNormName(eData['hero'])..' ，他的装备远远强于他的队友，并且比我们的装备平均强度要高。', false)
            --    end
            --end

        end

        nArreysData[i]['kill'] = GetHeroKills(botid)--击杀数
        nArreysData[i]['death'] = GetHeroDeaths(botid)--死亡数
        nArreysData[i]['assist'] = GetHeroAssists(botid)--助攻数
        nArreysData[i]['level'] = GetHeroLevel(botid)--英雄等级
        nArreysData[i]['health'] = member:GetHealth()/member:GetMaxHealth()--当前血量
        nArreysData[i]['mana'] = member:GetMana()/member:GetMaxMana()--当前魔法
        nArreysData[i]['location'] = member:GetLocation()--当前位置
        nArreysData[i]['item'] = heroItem--当前装备
        nArreysData[i]['itemCost'] = heroItemCost--装备总值
        nArreysData[i]['gold'] = member:GetGold()--当前金钱
        nArreysData[i]['buyback'] = member:HasBuyback()--买活状态

        nArreysData[i]['alive'] = member:IsAlive()--是否存活
        
    end

    for i,data in pairs(nEnemysData)
    do
        local heroItem = {}
        local heroItemCost = 0
        local botid = data['player']
        local member = data['hero']

        --物品
        for t = 0, 5 do
            local item = member:GetItemInSlot(t)
            if item ~= nil then
                heroItem[t] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[t])
            end
        end

        --位置
        local botLocation = member:GetLocation()
        local botSeenTime = 0
        if botLocation == nil then
            local dInfo = info[1];
            if dInfo ~= nil then
                botLocation = dInfo.location --单位曾经的位置
                botSeenTime = dInfo.time_since_seen --上次看到的时间
            end
        end

        nEnemysData[i]['kill'] = GetHeroKills(botid)--击杀数
        nEnemysData[i]['death'] = GetHeroDeaths(botid)--死亡数
        nEnemysData[i]['assist'] = GetHeroAssists(botid)--助攻数
        nEnemysData[i]['level'] = GetHeroLevel(botid)--英雄等级
        nEnemysData[i]['health'] = member:GetHealth()/member:GetMaxHealth()--当前血量
        nEnemysData[i]['mana'] = member:GetMana()/member:GetMaxMana()--当前魔法
        nEnemysData[i]['location'] = botLocation--位置
        nEnemysData[i]['seentime'] = botSeenTime--丢失时间
        nEnemysData[i]['item'] = heroItem--当前装备
        nEnemysData[i]['itemCost'] = heroItemCost--装备总值

        nEnemysData[i]['alive'] = member:IsAlive()--是否存活
        
    end

    --清除过长时间的击杀数据
    if killInTime - DotaTime() > 15 then
        evenKillStatistics = 0
    end
    --清除过长时间的死亡数据
    if dieInTime - DotaTime() > 15 then
        evenDeathStatistics = 0
    end
end

--场上局势判断
--winRate 胜率
--itemDifference 装备差
function L.Situation()
    local itemDifference = 0

    local arreyItemCost = 0
    local enemyItemCost = 0
    
    for _,data in pairs(nArreysData)
    do
        arreyItemCost = arreyItemCost + data['itemCost']
    end
    for _,data in pairs(nEnemysData)
    do
        enemyItemCost = enemyItemCost + data['itemCost']
    end

    itemDifference = (arreyItemCost / enemyItemCost) - 1

    local data = {
        ['arreyItemCost'] = arreyItemCost,
        ['enemyItemCost'] = enemyItemCost,
        ['itemDifference'] = itemDifference,
    }
    return data
    
    
end

--我方受到伤害类型强度
--contrast 比例
--types 强类型
function L.DamageTypeStatistics()

end

--轮盘嘲讽
function L.Chatwheel(kill, bot)
    local mocking = {
        ['doublekill'] = {--连杀
            '消灭完毕',
            '脸都秀歪啦',
            'Ceee~eeb',
            '再见了宝贝',
            '干嘛呢兄弟',
            '漂~亮',
            '头部撞击',
            '猢狲把戏',
        },
        ['ace'] = {--团灭
            '消灭完毕',
            '脸都秀歪啦',
            'Ceee~eeb',
            '再见了宝贝',
            '干嘛呢兄弟',
            '漂~亮',
            '你气不气？',
            '头部撞击',
            'what are you cooking？boom！',
        },
        ['buyace'] = {--买活团灭
            '消灭完毕',
            '脸都秀歪啦',
            'Ceee~eeb',
            '再见了宝贝',
            '干嘛呢兄弟',
            '漂~亮',
            '你气不气？',
            '头部撞击',
            '这波不亏666',
            'what are you cooking？boom！',
        },
        ['gank'] = {--单抓
            '消灭完毕',
            '脸都秀歪啦',
            'Ceee~eeb',
            '再见了宝贝',
            '干嘛呢兄弟',
            '漂~亮',
            '你气不气？',
            'what are you cooking？boom！',
            '猢狲把戏',
            '好走，不送',
        }
    }
    if kill then 
        if killInTime - DotaTime() <= 5 then -- 3秒内击杀 连杀
            evenKillStatistics = evenKillStatistics + 1
        else
            evenKillStatistics = 1
        end
        speech(true, mocking['buyace'], bot)
        if evenKillStatistics >= 6 
            and evenDeathStatistics < 5 --我方没被团灭
        then --买活团灭
            speech(true, mocking['buyace'], bot)
        elseif evenKillStatistics == 5 
            and evenDeathStatistics < 5 --我方没被团灭
        then --团灭
            speech(true, mocking['ace'], bot)
        elseif evenKillStatistics >= 3 
            and evenDeathStatistics < evenKillStatistics --我方死的没对方多
        then --大规模团
            speech(true, mocking['doublekill'], bot)
        elseif evenKillStatistics > 1 
            and evenDeathStatistics < evenKillStatistics --我方死的没对方多
        then --多人死亡
            speech(true, mocking['doublekill'], bot)
        elseif evenKillStatistics == 1 
            and evenDeathStatistics == 0 --我方没死
        then --抓单击杀
            speech(true, mocking['gank'], bot)
        end

        killInTime = DotaTime()
    else
        if dieInTime - DotaTime() <= 5 then  -- 3秒内击杀 连杀
            evenDeathStatistics = evenDeathStatistics + 1
        else
            evenDeathStatistics = 1
        end

        if evenDeathStatistics == 1 
            and evenKillStatistics == 0
        then --抓单击杀
            speech(true, mocking['gank'], bot)
        end

        dieInTime = DotaTime()
    end
end

function speech(team, mocking, bot)
    local text = mocking[RandomInt(1, #mocking)]
    local spbot = GetBot()
    local heroname = J.Chat.GetNormName(bot['hero'])
    local killname = J.Chat.GetCnName(bot['killhero'])
    --spbot:ActionImmediate_Chat(killname..' '..text, team)
    spbot:ActionImmediate_Chat(text, team)
    evenDeathStatistics = 0
    evenKillStatistics = 0
end

return L