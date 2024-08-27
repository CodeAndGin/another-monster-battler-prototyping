math.randomseed(os.time())
Player1 = {["ActionValue"]=0,}
Player2 = {["ActionValue"]=0,}
P1Shield = 0
P2Shield = 0
lastFourMoves={}
turnComplete=true
buttonYOffset=1
--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    TurnOrderText={
        [1] = getObjectFromGUID("e85054"),
        [2] = getObjectFromGUID("aa4dd3"),
        [3] = getObjectFromGUID("98b75f"),
        [4] = getObjectFromGUID("913e2f"),
    }
    initialTurnGen()
end

function initialTurnGen()
    local startRandomP1=math.random(4)
    local startRandomP2=math.random(4)
    while startRandomP2 == startRandomP1 do
        startRandomP2=math.random(4)
    end
    local startRandomM1=math.random(4)
    while startRandomM1 == startRandomP1 or startRandomM1 == startRandomP2 do
        startRandomM1=math.random(4)
    end
    local sum = startRandomP1 + startRandomP2 + startRandomM1
    local startRandomM2=0
    if sum == 6 then startRandomM2=4 elseif sum == 7 then startRandomM2=3 elseif sum==8 then startRandomM2=2 elseif sum==9 then startRandomM2=1 end
    Initial = {
    ["Player1"]=startRandomP1,
    ["Player2"]=startRandomP2,
    ["Mon1"]=startRandomM1,
    ["Mon2"]=startRandomM2,}
    determineTurnOrder(getActionValues())
    printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
    reDrawNumberDisplays()
end

function onUpdate()
    
end


function step()
    if turnComplete then
        turnComplete=false
        executeTurnOrder()
    else
        broadcastToAll("Turn not resolved, please take an action before continuing")
    end
end

function getActiveMons()
    return {
        [1] = getObjectFromGUID("dc1c78").getObjects()[1],
        [2] = getObjectFromGUID("e82344").getObjects()[1],
    }
end

function getInactiveMons(player)
    if player == 1 then
        return {
            [1] = getObjectFromGUID("5c74da").getObjects()[1],
            [2] = getObjectFromGUID("8669c3").getObjects()[1],
        }
    elseif player==2 then
        return {
            [1] = getObjectFromGUID("47dc87").getObjects()[1],
            [2] = getObjectFromGUID("e02e8b").getObjects()[1],
        }
    end
end

function getActionValues()
    local activeMons = getActiveMons()
    return {
        ["Player1"] = Player1["ActionValue"],
        ["Player2"] = Player2["ActionValue"],
        ["Mon1"] = activeMons[1].getVar("ActionValue"),
        ["Mon2"] = activeMons[2].getVar("ActionValue"),
    }
end

function printActionValues()
    AVs = getActionValues()
    for k,v in pairs(AVs) do print(k..": "..v) end
end

function executeTurnOrder()
    local ready = false
    local Order=determineTurnOrder(getActionValues())
    for _,v in pairs(getActionValues()) do
        if v==0 then ready=true end
    end
    if not ready then
        tick(getActiveMons())
        Order=determineTurnOrder(getActionValues())
        printTurnOrder(getActiveMons(), Order)
        reDrawNumberDisplays()
        return
    end
    nextTurn(getActiveMons(), Order)
    ActionValues = getActionValues()
    Order=determineTurnOrder(getActionValues())
    printTurnOrder(getActiveMons(), Order)
    reDrawNumberDisplays()
end

function determineTurnOrder(ActionValues)
    local Order={}
    local conflicts = discoverAVConflicts(ActionValues)
    if tableSize(lastFourMoves)==0 then
        Order[Initial["Player1"]]="Player1"
        Order[Initial["Player2"]]="Player2"
        Order[Initial["Mon1"]]="Mon1"
        Order[Initial["Mon2"]]="Mon2"
        return Order
    elseif tableSize(lastFourMoves)>0 and tableSize(lastFourMoves)<4 then
        fakeAVs={}
        for key,value in pairs(lastFourMoves) do
                fakeAVs[value]=getActionValues()[value]
        end
        if not tableContains(keyValueSwap(fakeAVs), "Player1") then
            fakeAVs["Player1"]=Initial["Player1"]/10
        end
        if not tableContains(keyValueSwap(fakeAVs), "Player2") then
            fakeAVs["Player2"]=Initial["Player2"]/10
        end
        if not tableContains(keyValueSwap(fakeAVs), "Mon1") then
            fakeAVs["Mon1"]=Initial["Mon1"]/10
        end
        if not tableContains(keyValueSwap(fakeAVs), "Mon1") then
            fakeAVs["Mon1"]=Initial["Mon1"]/10
        end
        conflicts = discoverAVConflicts(fakeAVs)
        while tableSize(Order) < 4 do
            local x = 100000000
            for key, value in pairs(getActionValues()) do
                local v = value
                if tableContains(Order, key)==true then goto continue end
                if tableSize(conflicts)==4 then
                    v = keyValueSwap(lastFourMoves)[key]
                elseif tableSize(conflicts)==5 then
                    local a = keyValueSwap(conflicts)[key]
                    if a==1 then b=2 elseif a==2 then b=1
                    elseif a==4 then b=5 elseif a==5 then b=1 end
                    a = conflicts[a]
                    b = conflicts[b]
                    if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then
                        v=v+0.01
                    end
                elseif tableContains(conflicts, key) then
                    local a = conflicts[1]
                    local b = conflicts[2]
                    local c = nil
                    if tableSize(conflicts)==3 then c=conflicts[3] end
                    if c==nil then
                        if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then 
                                if key==a then v = v + 0.01 end
                        else 
                                if key==b then v = v+0.01 end
                        end
                    else
                        if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] and keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[c] then
                            if keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[c] then
                                if key==a then v=v+0.02 elseif key==b then v=v+0.01 end
                            else 
                                if key==a then v=v+0.02 elseif key==c then v=v+0.01 end
                            end
                        elseif keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[a] and keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[c] then
                            if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[c] then
                                if key==b then v=v+0.02 elseif key==a then v=v+0.01 end
                            else 
                                if key==b then v=v+0.02 elseif key==c then v=v+0.01 end
                            end
                        elseif keyValueSwap(lastFourMoves)[c] > keyValueSwap(lastFourMoves)[b] and keyValueSwap(lastFourMoves)[c] > keyValueSwap(lastFourMoves)[a] then
                            if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then
                                if key==c then v=v+0.02 elseif key==a then v=v+0.01 end
                            else 
                                if key==c then v=v+0.02 elseif key==b then v=v+0.01 end
                            end
                        end
                    end
                end         
                if v<x then 
                    x = v
                    next = key
                end
                ::continue::
            end
            Order[tableSize(Order)+1] = next
        end
        return Order
    end
    while tableSize(Order) < 4 do
        local x = 100000000
        for key, value in pairs(getActionValues()) do
            local v = value
            if tableContains(Order, key)==true then goto continue end
            if tableSize(conflicts)==4 then
                v = keyValueSwap(lastFourMoves)[key]
            elseif tableSize(conflicts)==5 then
                local a = keyValueSwap(conflicts)[key]
                if a==1 then b=2 elseif a==2 then b=1
                elseif a==4 then b=5 elseif a==5 then b=1 end
                a = conflicts[a]
                b = conflicts[b]
                if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then
                    v=v+0.01
                end
            elseif tableContains(conflicts, key) then
                local a = conflicts[1]
                local b = conflicts[2]
                local c = nil
                if tableSize(conflicts)==3 then c=conflicts[3] end
                if c==nil then
                    if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then 
                            if key==a then v = v + 0.01 end
                    else 
                            if key==b then v = v+0.01 end
                    end
                else
                    if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] and keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[c] then
                        if keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[c] then
                            if key==a then v=v+0.02 elseif key==b then v=v+0.01 end
                        else 
                            if key==a then v=v+0.02 elseif key==c then v=v+0.01 end
                        end
                    elseif keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[a] and keyValueSwap(lastFourMoves)[b] > keyValueSwap(lastFourMoves)[c] then
                        if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[c] then
                            if key==b then v=v+0.02 elseif key==a then v=v+0.01 end
                        else 
                            if key==b then v=v+0.02 elseif key==c then v=v+0.01 end
                        end
                    elseif keyValueSwap(lastFourMoves)[c] > keyValueSwap(lastFourMoves)[b] and keyValueSwap(lastFourMoves)[c] > keyValueSwap(lastFourMoves)[a] then
                        if keyValueSwap(lastFourMoves)[a] > keyValueSwap(lastFourMoves)[b] then
                            if key==c then v=v+0.02 elseif key==a then v=v+0.01 end
                        else 
                            if key==c then v=v+0.02 elseif key==b then v=v+0.01 end
                        end
                    end
                end
            end         
            if v<x then 
                x = v
                next = key
            end
            ::continue::
        end
        Order[tableSize(Order)+1] = next
    end
    return Order
end

function discoverAVConflicts(AVs)
    local conflicts = {}
    for k, v in pairs(AVs) do
        for key, val in pairs(AVs) do
            if v == val and k ~= key then
                if conflicts[k]~=nil then conflicts[k]=key end
            end
        end
    end
    if tableSize(conflicts)<=3 then
        local newcon = {}
        local i = 1
        for k,_ in pairs(conflicts) do
            newcon[i] = k
            i=i+1
        end
        return newcon
    elseif tableSize(conflicts)==4 then
        if tableContains(conflicts, "Player1") and
           tableContains(conflicts, "Player2") and
           tableContains(conflicts, "Mon1") and
           tableContains(conflicts, "Mon2") then
                local newcon = {}
                local i = 1
                newcon[3]="split"
                for k,v in pairs (conflicts) do
                    if i==3 then i=i+1 end
                    if not tableContains(newcon, k) then
                        newcon[i] = k
                        i=i+1
                        newcon[i] = v
                    end
                end
                return newcon
        end
        return conflicts
    end
end

function tick(activeMons)
    broadcastToAll ("AVs above zero, ticking")
    Player1["ActionValue"] = Player1["ActionValue"] - 1
    Player2["ActionValue"] = Player2["ActionValue"] - 1
    activeMons[1].setVar("ActionValue", activeMons[1].getVar("ActionValue") - 1)
    activeMons[2].setVar("ActionValue", activeMons[2].getVar("ActionValue") - 1)
    turnComplete=true
end

function nextTurn(activeMons, Order)
    if Order[1] == "Player1" then
        playerTurn(1)
    elseif Order[1] == "Player2" then
        playerTurn(2)
    elseif Order[1] == "Mon1" then
        monsterTurn(1)
    elseif Order[1] == "Mon2" then
        monsterTurn(2)
    end
    recordMove(Order[1])
end

function playerTurn(who)
    if who==1 then
        broadcastToAll("Player 1's turn")
        activatePlayerButtons(who)
        --Player1["ActionValue"] = Player1["ActionValue"] + math.random(5)
    else
        broadcastToAll("Player 2's turn")
        activatePlayerButtons(who)
        --Player2["ActionValue"] = Player2["ActionValue"] + math.random(5)
    end
end

function playerButtonSwapMonster(player, valuePassedOrClickType, id)
    if id=="P1S1" then
        swapMonster(1, 1)
        deactivatePlayerButtons(1)
        Player1["ActionValue"] = Player1["ActionValue"] + 3
        printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
        reDrawNumberDisplays()
        turnComplete = true
    elseif id=="P1S2" then
        swapMonster(1, 2)
        deactivatePlayerButtons(1)
        Player1["ActionValue"] = Player1["ActionValue"] + 3
        printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
        reDrawNumberDisplays()
        turnComplete = true
    elseif id=="P2S1" then
        swapMonster(2, 1)
        deactivatePlayerButtons(2)
        Player2["ActionValue"] = Player2["ActionValue"] + 3
        printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
        reDrawNumberDisplays()
        turnComplete = true
    elseif id=="P2S2" then
        swapMonster(2, 2)
        deactivatePlayerButtons(2)
        Player2["ActionValue"] = Player2["ActionValue"] + 3
        printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
        reDrawNumberDisplays()
        turnComplete = true

    end
end

function swapMonster(player, slot)
    local activeZone = nil
    local benchZone = nil
    if player==1 then
        activeZone = getObjectFromGUID("dc1c78")
        if slot==1 then benchZone = getObjectFromGUID("5c74da") else benchZone = getObjectFromGUID("8669c3") end
    else
        activeZone = getObjectFromGUID("e82344")
        if slot==1 then benchZone = getObjectFromGUID("47dc87") else benchZone = getObjectFromGUID("e02e8b") end
    end
    local active = getActiveMons()[player]
    local toSwap = getInactiveMons(player)[slot]
    if player==1 then recordMove("Mon1") else recordMove("Mon2") end
    active.setPosition(benchZone.getPosition())
    toSwap.setPosition(activeZone.getPosition())
    Wait.time(function()    
        printTurnOrder(getActiveMons(), determineTurnOrder(getActionValues()))
        reDrawNumberDisplays()
    end, 0.3)
end

--for testing--
function activatePlayerButtonsHandler(player, valuePassedOrClickType, id)
    local attributes = getObjectFromGUID("009072").UI.getAttributes(id)
    if attributes.playerNumber=="1" then
        activatePlayerButtons(1)
    else
        activatePlayerButtons(2)
    end
end
--end--

function activatePlayerButtons(who)
    if who==1 then
        local buttons={
        ["swapMon1"] = getObjectFromGUID("ee5ed6"),
        ["swapMon2"] = getObjectFromGUID("4d6f81"),
        }
        for button,object in pairs(buttons) do
            object.translate(Vector(0,buttonYOffset,0))
        end
    else
        local buttons={
        ["swapMon1"] = getObjectFromGUID("916381"),
        ["swapMon2"] = getObjectFromGUID("d57c0f"),
        }
        for button,object in pairs(buttons) do
            object.translate(Vector(0,buttonYOffset,0))
        end
    end
end

--for testing--
function deactivatePlayerButtonsHandler(player, valuePassedOrClickType, id)
    local attributes = getObjectFromGUID("f34a2a").UI.getAttributes(id)
    if attributes.playerNumber=="1" then
        deactivatePlayerButtons(1)
    else
        deactivatePlayerButtons(2)
    end
end
--end--

function deactivatePlayerButtons(who)
    if who==1 then
        local buttons={
        ["swapMon1"] = getObjectFromGUID("ee5ed6"),
        ["swapMon2"] = getObjectFromGUID("4d6f81"),
        }
        for button,object in pairs(buttons) do
            object.translate(Vector(0,-buttonYOffset,0))
        end
    else
        local buttons={
        ["swapMon1"] = getObjectFromGUID("916381"),
        ["swapMon2"] = getObjectFromGUID("d57c0f"),
        }
        for button,object in pairs(buttons) do
            object.translate(Vector(0,-buttonYOffset,0))
        end
    end
end

function monsterTurn(who)
    local activeMons = getActiveMons()
    if who==1 then
        broadcastToAll(activeMons[1].getName().."'s turn")
        executeGambit(who)
        --activeMons[1].setVar("ActionValue", activeMons[1].getVar("ActionValue")+math.random(5))
        turnComplete=true
    else
        broadcastToAll(activeMons[2].getName().."'s turn")
        activeMons[2].setVar("ActionValue", activeMons[2].getVar("ActionValue")+math.random(5))
        turnComplete=true
    end
end

function executeGambit(who)
    local conditions = {}
    local moves = {}
    if who==1 then
        who = "Mon1"
    else who = "Mon2" end
    if who=="Mon1" then
        conditions [1] = getObjectFromGUID("c08cc0").getObjects()[1]
        moves [1] = getObjectFromGUID("2a2fbb").getObjects()[1]
    end
    for i,condition in pairs(conditions) do
        if condition.call("Condition") then
            moves[i].call("Move", who)
            break
        end
    end
end

function recordMove(move)
    if tableSize(lastFourMoves) < 4 then
        lastFourMoves[tableSize(lastFourMoves)+1]=move
    elseif lastFourMoves[4]==move then 
        return 
    elseif lastFourMoves[3]==move then
        lastFourMoves[3] = lastFourMoves[4]
        lastFourMoves[4] = move
        return
    elseif lastFourMoves[2]==move then
        lastFourMoves[2]=lastFourMoves[3]
        lastFourMoves[3]=lastFourMoves[4]
        lastFourMoves[4]=move
    else
        lastFourMoves[1] = lastFourMoves[2]
        lastFourMoves[2] = lastFourMoves[3]
        lastFourMoves[3] = lastFourMoves[4]
        lastFourMoves[4] = move
    end     
end

--Text update functions--

function printTurnOrder(activeMons, Order)
    for key,value in pairs(Order) do
        if value == "Mon1" then
            TurnOrderText[key].setValue(activeMons[1].getName() .. " (1), AV: "..getActionValues()[value])
        elseif value == "Mon2" then
            TurnOrderText[key].setValue(activeMons[2].getName() .. " (2), AV: "..getActionValues()[value])
        else
            TurnOrderText[key].setValue(value.." AV: "..getActionValues()[value])
        end
    end
end

function reDrawNumberDisplays()
    local activeMons = getActiveMons()
    local inactiveP1Mons = getInactiveMons(1)
    local inactiveP2Mons = getInactiveMons(2)
    local Mon1NameText = {
        [1] = getObjectFromGUID("2becce"),
        [2] = getObjectFromGUID("9acd22"),
    }
    for _,text in pairs(Mon1NameText) do
        text.setValue(activeMons[1].getName())
    end
    local Mon1HPText = {
        [1] = getObjectFromGUID("3ccc71"),
        [2] = getObjectFromGUID("b32da0"),
    }
    for _,text in pairs(Mon1HPText) do
        text.setValue(tostring(activeMons[1].getVar("Health")))
    end
    local Mon1VPText = {
        [1] = getObjectFromGUID("1cfe23"),
        [2] = getObjectFromGUID("3f4df4"),
    }
    for _,text in pairs(Mon1VPText) do
        text.setValue(tostring(activeMons[1].getVar("VulnHealth")))
    end
    local Mon1RVText = {
        [1] = getObjectFromGUID("5d3eb0"),
        [2] = getObjectFromGUID("d0e9a7"),
    }
    for _,text in pairs(Mon1RVText) do
        text.setValue(tostring(activeMons[1].getVar("ReactionValue")))
    end
    local Player1ShieldText = {
        [1] = getObjectFromGUID("b44680"),
        [2] = getObjectFromGUID("2ff96c"),
    }
    for _,text in pairs(Player1ShieldText) do
        text.setValue(tostring(P1Shield))
    end
    local Mon2NameText = {
        [1] = getObjectFromGUID("0e47b3"),
        [2] = getObjectFromGUID("c89151"),
    }
    for _,text in pairs(Mon2NameText) do
        text.setValue(tostring(activeMons[2].getName()))
    end
    local Mon2HPText = {
        [1] = getObjectFromGUID("b46e9a"),
        [2] = getObjectFromGUID("d95010"),
    }
    for _,text in pairs(Mon2HPText) do
        text.setValue(tostring(activeMons[2].getVar("Health")))
    end
    local Mon2VPText = {
        [1] = getObjectFromGUID("f0ed5e"),
        [2] = getObjectFromGUID("8f4646"),
    }
    for _,text in pairs(Mon2VPText) do
        text.setValue(tostring(activeMons[2].getVar("VulnHealth")))
    end
    local Mon2RVText = {
        [1] = getObjectFromGUID("17986d"),
        [2] = getObjectFromGUID("fc47bb"),
    }
    for _,text in pairs(Mon2RVText) do
        text.setValue(tostring(activeMons[2].getVar("ReactionValue")))
    end
    local Player2ShieldText = {
        [1] = getObjectFromGUID("dbb0f0"),
        [2] = getObjectFromGUID("00ec24"),
    }
    for _,text in pairs(Player2ShieldText) do
        text.setValue(tostring(P2Shield))
    end
    local P1Bench1Text = {
        ["Name"] = getObjectFromGUID("36f190"),
        ["HP"] = getObjectFromGUID("4de1ce"),
        ["VP"] = getObjectFromGUID("df8304"),
        ["AV"] = getObjectFromGUID("ff8b66"),
        ["RV"] = getObjectFromGUID("757092"),
    }
    reDrawInactiveNumberDisplays(P1Bench1Text, inactiveP1Mons[1])
    local P1Bench2Text = {
        ["Name"] = getObjectFromGUID("60de3b"),
        ["HP"] = getObjectFromGUID("053837"),
        ["VP"] = getObjectFromGUID("a5ce5e"),
        ["AV"] = getObjectFromGUID("e07f64"),
        ["RV"] = getObjectFromGUID("c79780"),
    }
    reDrawInactiveNumberDisplays(P1Bench2Text, inactiveP1Mons[2])
    local P2Bench1Text = {
        ["Name"] = getObjectFromGUID("5d6079"),
        ["HP"] = getObjectFromGUID("1ba3d0"),
        ["VP"] = getObjectFromGUID("447282"),
        ["AV"] = getObjectFromGUID("8e0f13"),
        ["RV"] = getObjectFromGUID("5bafc7"),
    }
    reDrawInactiveNumberDisplays(P2Bench1Text, inactiveP2Mons[1])
    local P2Bench2Text = {
        ["Name"] = getObjectFromGUID("33c9b7"),
        ["HP"] = getObjectFromGUID("af3c1d"),
        ["VP"] = getObjectFromGUID("e5f45e"),
        ["AV"] = getObjectFromGUID("37c9a8"),
        ["RV"] = getObjectFromGUID("c2e28a"),
    }
    reDrawInactiveNumberDisplays(P2Bench2Text, inactiveP2Mons[2])
end

function reDrawInactiveNumberDisplays(textTable, mon)
    textTable["Name"].setValue(mon.getName())
    textTable["HP"].setValue(tostring(mon.getVar("Health")))
    textTable["VP"].setValue(tostring(mon.getVar("VulnHealth")))
    textTable["AV"].setValue(tostring(mon.getVar("ActionValue")))
    textTable["RV"].setValue(tostring(mon.getVar("ReactionValue")))
end

--Utils--
function tableSize(table)
    size=0
    for key, value in pairs(table) do
        if table[key] == value ~= nil then
            size = size + 1
        end
    end
    return size
end

function tableContains(table, value)
    local set = {}
    for _, l in pairs(table) do set[l] = true end
    return set[value]
end

function keyValueSwap(table)
    local set = {}
    for k,v in pairs(table) do set[v]=k end
    return set
end