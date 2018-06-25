local GameTools = class("GameTools")

function GameTools:ctor()
    self.dir_arr = {{0,1},{1,1},{1,0},{1,-1},{0,-1},{-1,-1},{-1,0},{-1,1}}
end

function GameTools:initWidget(widgets , args)
    self.args = args and clone(args) or {}
    self.width  = #widgets
    self.height = #widgets[1]
    self.flagMap = {}
    local flagMap = self.flagMap
    for i = 1, self.width do
        for j = 1, self.height do
            flagMap[i] = flagMap[i] or {}
            flagMap[i][j] = flagMap[i][j] or { }
            flagMap[i][j].itemId = widgets[i][j]:getItemID()
            flagMap[i][j].id = widgets[i][j]:getID() and ( math.floor(widgets[i][j]:getID() / 1000) * 1000) or 0
            flagMap[i][j].isAny = widgets[i][j].LINE_TYPE == "ANY"
        end
    end
end

function GameTools:splitGroup(f_px , f_py)
    local width  = self.width
    local height = self.height
    local flagMap = self.flagMap
    local dir_arr = self.dir_arr
    local group_index = 1
    local group_record = {}

    for i = 1, width do
        for j = 1, height do
            flagMap[i][j].isGroupSplitVisit = nil
            flagMap[i][j].group = nil
        end
    end

    local function bfs( x , y )
        if flagMap[x][y].itemId or flagMap[x][y].isGroupSplitVisit then return end
        flagMap[x][y].isGroupSplitVisit = true
        local cur_id = flagMap[x][y].isAny and 0 or flagMap[x][y].id
        local stack = {}
        table.insert(stack , {x , y})
        local group_info = {info_id = group_index , total_cnt = 1 , items = {} }
        group_index = group_index + 1
        group_info.items[x] = group_info.items[x] or {}
        group_info.items[x][y] = true
        flagMap[x][y].group = group_info
        while(#stack > 0) do
            local top = stack[1]
            table.remove(stack , 1)
            for _,dir in ipairs(dir_arr) do
                local next_p = {top[1] + dir[1] , top[2] + dir[2]}
                if next_p[1] <= width and next_p[1] >= 1 and next_p[2] <= height and next_p[2] >= 1 then
                    --  不在组内
                    if not group_info.items[next_p[1]] or not group_info.items[next_p[1]][next_p[2]] then 
                        local check_id = flagMap[next_p[1]][next_p[2]].id
                        local nxtIsAny = flagMap[next_p[1]][next_p[2]].isAny
                        if (cur_id == 0 or nxtIsAny) or (check_id == cur_id and not flagMap[next_p[1]][next_p[2]].isGroupSplitVisit) then 
                            table.insert(stack , {next_p[1] , next_p[2]})
                            group_info.items[next_p[1]] = group_info.items[next_p[1]] or {}
                            group_info.items[next_p[1]][next_p[2]] = true
                            flagMap[next_p[1]][next_p[2]].isGroupSplitVisit = true
                            flagMap[next_p[1]][next_p[2]].group = group_info
                            if not nxtIsAny and cur_id == 0 then
                                cur_id = check_id
                            end
                            group_info.total_cnt = group_info.total_cnt + 1
                        end
                    end
                end
            end
        end
        local pos_index = #group_record + 1
        for index = #group_record , 1 , -1 do
            if group_record[index].total_cnt < group_info.total_cnt then
                group_record[index + 1] = group_record[index]
            else
                break
            end
            pos_index = index
        end
        group_info.id = cur_id
        group_record[pos_index] = group_info
    end
    if f_px and f_py then
        bfs( f_px , f_py )
    else
        for j = 1, height do
            for i = width, 1, -1 do
                if not self.args.lineId or flagMap[i][j].id == self.args.lineId then
                    bfs( i , j )
                else
                    flagMap[i][j].group = {info_id = 0}
                end
            end
        end
    end
    return group_record
end

function GameTools:getMaxPath(len , spos )
    local width  = self.width
    local height = self.height
    local flagMap = self.flagMap
    local dir_arr = self.dir_arr
    local group_record = self:splitGroup()
--    print("group:")
--    for _ , info in ipairs(group_record) do
--        if info.info_id ~= 0 then
--            print("-----------------" .. info.info_id .. "------------")
--            print("-----------------" .. info.total_cnt .. "------------")
--            for i = width,1,-1  do
--                local ret = ""
--                for j = 1,height do
--                    if info.items[i] and info.items[i][j] then
--                        ret = ret .. "1" .. ","
--                    else
--                        ret = ret .. "0" .. ","
--                    end
--                end
--                print(ret)
--            end
--        end
--    end
    local isVisitMap = {}
    local record = {}
    local maxRecord = {}
    local maxLength = 0
    local is_stop_search = false
    local isVisitTPos = true
    if spos then isVisitTPos = false end
    local function visit( i , j , items)
        if isVisitMap[i] and isVisitMap[i][j] and is_stop_search then return end
        isVisitMap[i] = isVisitMap[i] or {}
        isVisitMap[i][j] = true
        local oldIsVisitTPos = isVisitTPos
        if spos and i == spos.x and j == spos.y then
            isVisitTPos = true
        end
        table.insert(record , {i,j})
        local isEnd = true
        if not len or #record < len or not isVisitTPos then
            for _,dir in ipairs(dir_arr) do
                local next_p = {i + dir[1] , j + dir[2]}
                isVisitMap[next_p[1]] = isVisitMap[next_p[1]] or {}
                if next_p[1] <= width and next_p[1] >= 1 and next_p[2] <= height and next_p[2] >= 1 then
                    if items[next_p[1]] and items[next_p[1]][next_p[2]] and not isVisitMap[next_p[1]][next_p[2]] then
                        visit(next_p[1] , next_p[2] , items)
                        isEnd = false
                    end
                end
            end
        end
        if isVisitTPos and isEnd then
            if #record > maxLength then
                maxLength = #record
                maxRecord = {}
                for _,v in ipairs(record) do
                    table.insert(maxRecord , v)
                end
                if (len and maxLength >= len) then
                    is_stop_search = true
                end
            end
        end
        table.remove(record , #record)
        isVisitTPos = oldIsVisitTPos
        isVisitMap[i][j] = nil
    end
--    print("possible finalResult:" .. finalResult)
    for _ , info in ipairs(group_record) do
        if info.info_id ~= 0 then
            if info.total_cnt <= maxLength then break end
            local isContainPos = true
            if spos then
                isContainPos = false
                for _x , _list in pairs(info.items) do
                    for _y , _ in pairs(_list) do
                        if _x == spos.x and _y == spos.y then
                            isContainPos = true
                            break
                        end
                    end
                end
            end
            if isContainPos then
                if spos then
                    visit(spos.x , spos.y , info.items , isVisitTPos)
                end
                if not is_stop_search then
                    for _x , _list in pairs(info.items) do
                        for _y , _ in pairs(_list) do
                            if not spos or (_x ~= spos.x and spos.y ~= _y) then
                                visit(_x , _y , info.items , isVisitTPos)
                            end
                        end
                    end 
                end
            end 
        end
    end

--    print("max line")
--    for _ ,v in ipairs(maxRecord) do
--        print(v[1].."," .. v[2] .. "->")
--    end
    return maxRecord , maxLength
end

return GameTools