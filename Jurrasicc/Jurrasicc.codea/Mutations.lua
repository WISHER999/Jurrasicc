MutationLab = class()

function MutationLab:init()
    self.open = false
    self.iconPos = vec2(WIDTH - 40, HEIGHT / 2)
    self.scrollY = 0
    self.cardHeight = 140
    self.spacing = 20
    self.feedback = ""
    self.timer = 0
    self.previewCache = {}
    
    
    self.odds = {
        ["Common"] = 60,
        ["Mythic"] = 25,
        ["Apex"] = 10,
        ["Omega"] = 4,
        ["Eternal"] = 0.6,
        ["Divine"] = 0.3,
        ["Seraphic Grace"] = 0.1
    }
    
    
    self.boosts = {
        Common = 1.0,
        Mythic = 1.25,
        Apex = 1.5,
        Omega = 2.5,
        Eternal = 5.0,
        Divine = 6.5,
        ["Seraphic Grace"] = 10.0
    }
end

function MutationLab:draw()
    fill(0, 255, 255)
    ellipse(self.iconPos.x, self.iconPos.y, 40)
    fontSize(12)
    fill(255)
    text("Lab", self.iconPos.x, self.iconPos.y)
    
    if not self.open then return end
    
    clip(0, 0, WIDTH, HEIGHT)
    for i, dino in ipairs(dinos.dinos) do
        local y = HEIGHT - (i * (self.cardHeight + self.spacing)) + self.scrollY
        
        fill(50)
        rect(50, y, WIDTH - 100, self.cardHeight)
        
        fill(255)
        fontSize(18)
        text(dino.name.." Lv"..dino.level, 100, y + self.cardHeight - 20)
        fontSize(14)
        text("Mutation: "..(table.concat(dino.mutations or {}, ", ") or "None"), 100, y + self.cardHeight - 50)
        
        if not self.previewCache[dino.name] then
            self.previewCache[dino.name] = self:previewTier()
        end
        local previewTier = self.previewCache[dino.name]
        local base = DinoStats[dino.name]
        local boost = self.boosts[previewTier] or 1
        local atk = math.floor(base.attack * boost * (1 + dino.level * 0.05))
        local hp = math.floor(base.health * boost * (1 + dino.level * 0.05))
        fill(200)
        text("Preview → ATK: "..atk.."  HP: "..hp.."  ["..previewTier.."]", 100, y + self.cardHeight - 70)
        
        fill(0, 200, 255)
        rect(WIDTH - 160, y + self.cardHeight - 60, 100, 30)
        fill(255)
        fontSize(14)
        text("Mutate", WIDTH - 110, y + self.cardHeight - 45)
        
        fill(0, 255, 100)
        rect(WIDTH - 160, y + self.cardHeight - 100, 100, 30)
        fill(255)
        fontSize(14)
        text("Level Up", WIDTH - 110, y + self.cardHeight - 85)
    end
    clip()
    
    if self.feedback ~= "" then
        fontSize(16)
        text(self.feedback, WIDTH/2, HEIGHT - 50)
        if ElapsedTime - self.timer > 2 then self.feedback = "" end
    end
end

function MutationLab:touched(touch)
    if touch.state == BEGAN then
        if vec2(touch.x, touch.y):dist(self.iconPos) < 30 then
            self.open = not self.open
            return
        end
        
        for i, dino in ipairs(dinos.dinos) do
            local y = HEIGHT - (i * (self.cardHeight + self.spacing)) + self.scrollY
            
            -- ✅ Level Up
            if touch.x > WIDTH - 160 and touch.x < WIDTH - 60 and
            touch.y > y + self.cardHeight - 100 and touch.y < y + self.cardHeight - 70 then
                if dino.level >= 100 then
                    self.feedback = "⚠️ Already max level"
                else
                    dino.level = dino.level + 1
                    local base = DinoStats[dino.name]
                    local boost = self.boosts[dino.mutations[1]] or 1
                    dino.attack = math.floor(base.attack * boost * (1 + dino.level * 0.05))
                    dino.health = math.floor(base.health * boost * (1 + dino.level * 0.05))
                    saveSystem:save()
                    self.feedback = "✅ "..dino.name.." leveled up to "..dino.level
                end
                self.timer = ElapsedTime
            end
            
            -- ✅ Mutate
            if touch.x > WIDTH - 160 and touch.x < WIDTH - 60 and
            touch.y > y + self.cardHeight - 60 and touch.y < y + self.cardHeight - 30 then
                if player.dna < 100 then
                    self.feedback = "❌ Not enough DNA"
                else
                    player.dna = player.dna - 100
                    local tier = self:rollTier()
                    dino.mutations = {tier}
                    local base = DinoStats[dino.name]
                    local boost = self.boosts[tier] or 1
                    dino.attack = math.floor(base.attack * boost * (1 + dino.level * 0.05))
                    dino.health = math.floor(base.health * boost * (1 + dino.level * 0.05))
                    saveSystem:save()
                    self.feedback = "✅ "..dino.name.." mutated to "..tier
                    self.previewCache[dino.name] = self:previewTier()
                    
                    if tier == "Seraphic Grace" then
                        cinematics:triggerSeraphicPulse(dino)
                    end
                end
                self.timer = ElapsedTime
            end
        end
    elseif touch.state == MOVING and self.open then
        self.scrollY = self.scrollY + touch.deltaY
    end
end


function MutationLab:rollTier()
    local total = 0
    for _, chance in pairs(self.odds) do
        total = total + chance
    end
    
    local roll = math.random() * total
    local cumulative = 0
    for tier, chance in pairs(self.odds) do
        cumulative = cumulative + chance
        if roll <= cumulative then return tier end
    end
    return "Common"
end

function MutationLab:previewTier()
    return self:rollTier()
end
