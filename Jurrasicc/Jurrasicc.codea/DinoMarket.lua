DinoMarket = class()

function DinoMarket:init()
    self.open = false
    self.iconPos = vec2(WIDTH - 60, 60)
    self.scrollY = 0
    self.cardHeight = 120
    self.spacing = 20
    self.feedback = ""
    self.timer = 0
end

function DinoMarket:draw()
    
    sprite(asset.documents.Market, self.iconPos.x, self.iconPos.y, 40, 40)
    
    if self.open then
        clip(0, 0, WIDTH, HEIGHT)
        local i = 0
        for name, stats in pairs(DinoStats) do
            i = i + 1
            local y = HEIGHT - (i * (self.cardHeight + self.spacing)) + self.scrollY
            
            
            fill(50)
            rect(50, y, WIDTH - 100, self.cardHeight)
            
            
            fill(255)
            fontSize(18)
            text(name, 100, y + self.cardHeight - 20)
            fontSize(14)
            text("ATK: "..stats.attack.."  HP: "..stats.health.."  Rarity: "..stats.rarity, 100, y + self.cardHeight - 50)
            
            
            fill(255, 215, 0)
            rect(WIDTH - 160, y + self.cardHeight - 60, 100, 40)
            fill(0)
            fontSize(16)
            text(stats.cost.."🪙", WIDTH - 110, y + self.cardHeight - 40)
            
            
        end
        clip()
        
        -- Feedback
        if self.feedback ~= "" then
            fontSize(16)
            text(self.feedback, WIDTH/2, HEIGHT - 50)
            if ElapsedTime - self.timer > 2 then self.feedback = "" end
        end
    end
end

function DinoMarket:touched(touch)
    if touch.state == BEGAN then
        
        if vec2(touch.x, touch.y):dist(self.iconPos) < 30 then
            self.open = not self.open
            return
        end
        
        
        if self.open then
            local i = 0
            for name, stats in pairs(DinoStats) do
                i = i + 1
                local y = HEIGHT - (i * (self.cardHeight + self.spacing)) + self.scrollY
                if touch.x > WIDTH - 160 and touch.x < WIDTH - 60 and
                touch.y > y + self.cardHeight - 60 and touch.y < y + self.cardHeight - 20 then
                    
                    if player.coins >= stats.cost then
                        player.coins = player.coins - stats.cost
                        hatchery:addToQueue(name, stats.cost / 100) -- Hatch time based on cost
                        saveSystem:save()
                        self.feedback = "✅ Sent "..name.." to hatchery!"
                    else
                        self.feedback = "❌ Not enough coins"
                    end
                    self.timer = ElapsedTime
                end
            end
        end
    elseif touch.state == MOVING and self.open then
        self.scrollY = self.scrollY + touch.deltaY
    end
end
