function AdminConsole:submitCode(code)
    local function queue(name)
        if DinoStats[name] then
            hatchery:addToQueue(name, DinoStats[name].cost / 100)
        end
    end
    
    local function addToRoster(name, mutations)
        local base = DinoStats[name]
        local boost = mutationBoost(mutations or {})
        table.insert(dinos.dinos, {
            name = name,
            level = 1,
            attack = math.floor(base.attack * boost),
            health = math.floor(base.health * boost),
            dupes = 0,
            mutations = mutations or {}
        })
    end
    
    local nameMap = {
        ScorpionT = "Scorpion Full Potential",
        Indom = "Indominus Rex",
        Raptor = "Velociraptor"
    }
    
    local mutationMap = {
        SSS = "Seraphic Grace",
        Apex = "Apex",
        Mythic = "Mythic",
        Omega = "Omega",
        Eternal = "Eternal",
        Divine = "Divine"
    }
    
    if code:find("^-add ") then
        local raw = code:match("^-add%s+(.+)")
        local name, mutation = raw:match("([^%.]+)%.?(%a*)")
        name = nameMap[name] or name
        mutation = mutationMap[mutation] or mutation
        
        if not DinoStats[name] then
            self.input = "❌ Unknown dino: "..name
            return
        end
        
        local mutations = {}
        if mutation == "Seraphic Grace" then
            mutations = {"Seraphic Grace"}
        elseif mutation ~= nil and mutation ~= "" then
            table.insert(mutations, mutation)
        end
        
        addToRoster(name, mutations)
        saveSystem:save()
        self.input = "✅ "..name.." added"..(mutation and " with "..table.concat(mutations, ", ") or "").."!"
        
    elseif code:find("^-level ") then
        local raw = code:match("^-level%s+(.+)")
        local name, mutation, target = raw:match("([^%.]+)%.?([^%.]*)%.?(%d*)")
        name = nameMap[name] or name
        mutation = mutationMap[mutation] or mutation
        local targetLevel = tonumber(target) or 1
        if targetLevel > 100 then targetLevel = 100 end
        
        local dino = nil
        for _, d in ipairs(dinos.dinos) do
            if d.name == name and (mutation == "" or table.contains(d.mutations or {}, mutation)) then
                dino = d
                break
            end
        end
        
        if not dino then
            self.input = "❌ "..name.." with "..(mutation ~= "" and mutation or "no mutation").." not found"
            return
        end
        
        local base = DinoStats[dino.name]
        local boost = mutationBoost(dino.mutations or {})
        dino.level = targetLevel
        dino.attack = math.floor(base.attack * boost * (1 + dino.level * 0.05))
        dino.health = math.floor(base.health * boost * (1 + dino.level * 0.05))
        
        saveSystem:save()
        self.input = "✅ "..dino.name.." Lv "..dino.level.." updated ("..table.concat(dino.mutations or {}, ", ")..")"
        
    elseif code == "-mutate AllDino" then
        for _, d in ipairs(dinos.dinos) do
            d.mutations = {"Seraphic Grace"}
            local base = DinoStats[d.name]
            d.attack = math.floor(base.attack * 8.0)
            d.health = math.floor(base.health * 8.0)
        end
        saveSystem:save()
        self.input = "✅ All dinos mutated to Seraphic Grace!"
        
    elseif code == "-debug :viewer:" then
        for i, d in ipairs(dinos.dinos) do
            print(i, d.name, "Lv", d.level, table.concat(d.mutations or {}, ", "))
        end
        self.input = "✅ Viewer logged to console"
        
        -- 🔁 REPLACED BLOCK BELOW
    elseif code == "-playSSScut" then
        local dino = dinos.dinos[1]
        if dino then
            cinematics:triggerSeraphicPulse(dino)
            self.input = "🎬 Playing Seraphic Pulse: Hello for " .. dino.name
        else
            self.input = "❌ No dino found to play cinematic"
        end
        
    elseif code == "-addDNA inf" then
        player.dna = math.huge
        saveSystem:save()
        self.input = "✅ DNA set to infinite"
        
    elseif code:find("^-addDNA ") then
        local amount = tonumber(code:match("^-addDNA%s+(%d+)"))
        if amount then
            player.dna = player.dna + amount
            saveSystem:save()
            self.input = "✅ Added "..amount.." DNA"
        else
            self.input = "❌ Invalid DNA amount"
        end
        
    elseif code == "-resetDNA" then
        player.dna = 0
        saveSystem:save()
        self.input = "✅ DNA reset to 0"
        
    elseif code:find("^-addGold ") then
        local amount = tonumber(code:match("^-addGold%s+(%d+)"))
        if amount then
            player.gold = player.gold + amount
            saveSystem:save()
            self.input = "✅ Added "..amount.." gold"
        else
            self.input = "❌ Invalid gold amount"
        end
        
    elseif code == "-resetGold" then
        player.gold = 0
        saveSystem:save()
        self.input = "✅ Gold reset to 0"
        
    elseif code == "-admin :player.true:" then
        player.isAdmin = true
        saveSystem:save()
        self.input = "✅ Admin mode enabled"
        
    elseif code == "-admin :player.false:" then
        player.isAdmin = false
        saveSystem:save()
        self.input = "✅ Admin mode disabled"
        
    elseif code == "-boost AllDino" then
        for _, d in ipairs(dinos.dinos) do
            d.attack = d.attack * 10
            d.health = d.health * 10
        end
        saveSystem:save()
        self.input = "✅ All dinos boosted 10×"
        
    elseif code == "-clearMutations" then
        for _, d in ipairs(dinos.dinos) do
            d.mutations = {}
        end
        saveSystem:save()
        self.input = "✅ All mutations cleared"
        
    else
        self.input = "❌ Unknown command"
    end
end
