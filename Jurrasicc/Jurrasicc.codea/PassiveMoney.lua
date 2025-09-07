PassiveIncome = class()

function PassiveIncome:init()
    self.lastTick = ElapsedTime
end

function PassiveIncome:update()
    if ElapsedTime - self.lastTick >= 0.1 then
        local income = #dinos.dinos * 10
        player.coins = player.coins + income
        self.lastTick = ElapsedTime
    end
end
