ResetButton = class()

function ResetButton:init()
    self.pos = vec2(100, 60)
    self.size = vec2(140, 50)
    self.feedback = ""
    self.timer = 0
end

function ResetButton:draw()
    fill(180, 0, 0)
    rect(self.pos.x, self.pos.y, self.size.x, self.size.y)
    fill(255)
    fontSize(16)
    text("Reset Progress", self.pos.x + self.size.x/2, self.pos.y + self.size.y/2)
    
    if self.feedback ~= "" then
        fontSize(16)
        text(self.feedback, WIDTH/2, HEIGHT - 50)
        if ElapsedTime - self.timer > 2 then self.feedback = "" end
    end
end

function ResetButton:touched(touch)
    if touch.state == BEGAN and
    touch.x > self.pos.x and touch.x < self.pos.x + self.size.x and
    touch.y > self.pos.y and touch.y < self.pos.y + self.size.y then
        
        -- Reset player stats
        player.coins = 1000
        player.food = 1000
        player.dna = 500
        
        -- Clear dino roster
        dinos.dinos = {}
        
        -- Save new state
        saveSystem:save()
        
        self.feedback = "✅ Progress reset!"
        self.timer = ElapsedTime
    end
end
