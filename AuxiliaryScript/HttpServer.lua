--[[
    使用说明
        LocalHttpPost为发送数据至本地80端口
        HttpPost为发送数据至远程服务器
        返回参数目前仅在控制台输出

    HttpPost远程连接url格式
        url地址省略http://
        比如服务器api地址为http://123.123.123.123:3000/
        调用方法为H.HttpPost(postData, '123.123.123.123:3000')

    json数据格式
        请注意字符需要额外使用""，示例如下
        输入格式
        {
            init = 'true',
            script = '"Simple AI"',
        }
        输出格式
        {
            "data": {
                "init": true,
                "script": "Simple AI"
            },
            "info": {
                "gameTime": 23（注：当前游戏进行时间）
                "script": "Simple AI"
            }
        }

    UUID参数
        发送远程数据时会默认向服务器获取UUID，如果不需要获取请将第三个参数设为true
        初次获取到UUID后每次发送数据都会附带UUID
        如需更新UUID请执行H.GetUUID(url)
]]

--[[
    示例api服务器
        服务器地址http://api.alcedo.top:3001
        演示页面地址http://api.alcedo.top
]]

local H = {}
local json = require "game/dkjson"

H.UUID = nil
H.USERNAME = nil
H.USERPASSWORD = nil

function H.LocalHttpPost(postData, call, calldata)

    local httpData = jsonFormatting(postData)

    local req = CreateHTTPRequest( '' )
    local req = CreateRemoteHTTPRequest( url )
    req:SetHTTPRequestRawPostBody("application/json", httpData)
    req:Send( function( result )
        for k,v in pairs( result ) do
            if type(v) == 'string'
               and string.find(v, 'res:') ~= nil 
            then 
                local resdata = string.sub(v, 5);
                call(resdata, calldata)
            end
            
        end 
    end )

end

function H.HttpPost(postData, url, call, calldata, notUUID)

    if H.UUID ~= nil or notUUID then

        local httpData = jsonFormatting(postData)
        local req = CreateRemoteHTTPRequest( url )
        req:SetHTTPRequestRawPostBody("application/json", httpData)
        req:Send( function( result )
            for k,v in pairs( result ) do
                if type(v) == 'string'
                   and string.find(v, 'res:') ~= nil 
                then 
                    local resdata = string.sub(v, 5);
                    call(resdata, calldata)
                end
                
            end 
        end )
        
    else 
        H.GetUUID(url)
    end

end

function H.GetUUID(url, call)
    local postData = {
        operation = 'getuuid'
    }
    local httpData = jsonFormatting(postData)
    local req = CreateRemoteHTTPRequest( url )
    req:SetHTTPRequestRawPostBody("application/json", httpData)
    req:Send( function( result )
        for k,v in pairs( result ) do
            if type(v) == 'string'
               and string.find(v, 'UUID:') ~= nil 
            then 
                H.UUID = string.sub(v, 6);
                if call ~= nil then
                    call(H.UUID)
                end
            end
        end
        if H.UUID == nil then 
            print('服务器返回数据错误，无法获取UUID')
        end
    end )
end

function jsonFormatting(obj)

    local objtable = {}
    objtable.data = obj
    local uuid = H.UUID
    if uuid == nil then uuid = 'local' end
    objtable.info = {
        uuid = uuid,
        gameTime = DotaTime(),
        script = 'Sirius AI',
        user = H.USERNAME,
        password = H.USERPASSWORD,
    }
    local string = json.encode(objtable)
    return string
end

return H