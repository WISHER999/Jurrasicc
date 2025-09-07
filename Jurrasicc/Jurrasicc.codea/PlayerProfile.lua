PlayerProfile = class()

function PlayerProfile:init()
    self.coins = 1000
    self.food = 1000
    self.dna = 100
end

function PlayerProfile:grantAdminResources()
    self.coins = 9000000000
    self.food = 9000000000
    self.dna = 9000000000
end

function PlayerProfile:drawHUD()
    fill(255)
    fontSize(18)
    text("Coins: "..self.coins, 100, HEIGHT - 40)
    text("Food: "..self.food, 100, HEIGHT - 70)
    text("DNA: "..self.dna, 100, HEIGHT - 100)
end
