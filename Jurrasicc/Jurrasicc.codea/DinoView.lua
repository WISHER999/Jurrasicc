local rarityColors = {
    Common = color(150, 150, 150),
    Rare = color(0, 150, 255),
    Epic = color(180, 0, 180),
    Legendary = color(255, 140, 0),
    Apex = color(255, 0, 0),
    Omega = color(0, 0, 0)
}

local apexCooldown = 0
local particlePool = {}
local particleEmitCooldown = 0

function table.contains(t, val)
    for _, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end

DinoViewer = class()

function DinoViewer:init()
    self.scrollX = 0
    self.cardWidth = 160
    self.spacing = 20
    self.cardHeight = 100
    self.yPos = HEIGHT / 2 - self.cardHeight / 2
end

function DinoViewer:draw()
    clip(0, 0, WIDTH, HEIGHT)
    
    for i, dino in ipairs(dinos.dinos) do
        if type(dino) == "string" then
            local base = DinoStats[dino]
            dino = {
                name = dino,
                level = 1,
                attack = base and base.attack or 0,
                health = base and base.health or 0,
                dupes = 0,
                mutations = {}
            }
            dinos.dinos[i] = dino
        end
        
        local x = (i - 1) * (self.cardWidth + self.spacing) + self.scrollX + 60
        local y = self.yPos
        local rarity = DinoStats[dino.name] and DinoStats[dino.name].rarity or "Common"
        local cardColor = rarityColors[rarity] or color(100)
        
        fill(cardColor)
        rect(x, y, self.cardWidth, self.cardHeight)
        
        -- Apex lightning
        if rarity == "Apex" and ElapsedTime - apexCooldown > 0.5 then
            apexCooldown = ElapsedTime
            for j = 1, 2 do
                local lx = x + math.random(math.floor(self.cardWidth))
                local ly1 = y + self.cardHeight
                local ly2 = ly1 + math.random(15, 40)
                stroke(255, 255, 255)
                strokeWidth(1.5)
                line(lx, ly1, lx, ly2)
            end
        end
        
        -- Mutation visuals
        local hasSeraphic = table.contains(dino.mutations, "Seraphic Grace")
        local emit = false
        if ElapsedTime - particleEmitCooldown > 0.2 then
            emit = true
            particleEmitCooldown = ElapsedTime
        end
        
        for _, m in ipairs(dino.mutations or {}) do
            local colorMap = {
                Omega = color(255),
                Mythic = color(180, 0, 180),
                Apex = color(255, 0, 0),
                Eternal = color(0, 200, 255),
                Divine = color(255, 255, 0),
                ["Seraphic Grace"] = color(255, 255, 100)
            }
            
            local particleColor = colorMap[m] or color(255)
            
            if emit then
                for j = 1, 6 do
                    local angle = math.random() * math.pi * 2
                    local radius = math.random(10, 40)
                    table.insert(particlePool, {
                        x = x + self.cardWidth / 2 + math.cos(angle) * radius,
                        y = y + self.cardHeight / 2 + math.sin(angle) * radius,
                        dx = math.random(-2, 2) / 10,
                        dy = math.random(-2, 2) / 10,
                        life = 1,
                        col = particleColor
                    })
                end
            end
        end
        
        if hasSeraphic then
            -- Golden aura
            noStroke()
            fill(255, 255, 0, 60)
            ellipse(x + self.cardWidth / 2, y + self.cardHeight / 2, self.cardWidth + 40, self.cardHeight + 40)
            
            -- Wings on sides
            local wingY = y + self.cardHeight / 2 + math.sin(ElapsedTime * 4) * 6
            fontSize(28)
            fill(255)
            text("🪽", x - 20, wingY)
            text("🪽", x + self.cardWidth + 20, wingY)
            
            -- Halo above
            local haloY = y + self.cardHeight + 30 + math.sin(ElapsedTime * 2) * 5
            fontSize(24)
            fill(255, 255, 0)
            text("💫", x + self.cardWidth / 2, haloY)
        end
        
        -- Dino name and stats
        fill(255)
        fontSize(16)
        text(dino.name or "Unknown", x + self.cardWidth / 2, y + self.cardHeight / 2 + 20)
        fontSize(14)
        text("Lv "..(dino.level or "?").."  ATK: "..(dino.attack or "?").."  HP: "..(dino.health or "?"),
        x + self.cardWidth / 2, y + self.cardHeight / 2 - 10)
        
        -- Mutation tags
        if dino.mutations and #dino.mutations > 0 then
            fontSize(12)
            fill(0, 255, 255)
            text("🧬 "..table.concat(dino.mutations, ", "), x + self.cardWidth / 2, y + 10)
        end
    end
    
    -- Particle rendering
    for i = #particlePool, 1, -1 do
        local p = particlePool[i]
        p.x = p.x + p.dx
        p.y = p.y + p.dy
        p.life = p.life - 0.01
        
        fill(p.col.r, p.col.g, p.col.b, p.life * 50)
        ellipse(p.x, p.y, 3)
        
        if p.life <= 0 then
            table.remove(particlePool, i)
        end
    end
    
    clip()
end

function DinoViewer:touched(touch)
    if touch.state == MOVING then
        self.scrollX = self.scrollX + touch.deltaX
    end
end
