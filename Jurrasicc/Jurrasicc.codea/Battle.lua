Battle = class()

function Battle:init()
    self.active     = false
    self.selecting  = false
    self.playerTeam = {}
    self.enemyTeam  = {}
    self.turn       = "player"
    self.log        = {}
    self.winner     = nil
    self.feedback   = ""
    self.timer      = 0
end

function Battle:draw()
    if not self.active and not self.selecting then
        fill(255,0,0)
        rect(WIDTH-160,HEIGHT-60,100,40)
        fill(255)
        fontSize(16)
        text("Battle",WIDTH-110,HEIGHT-40)
    end
    if self.selecting then
        fontSize(18)
        fill(255)
        text("🦖 Select a dino to battle",WIDTH/2,HEIGHT-30)
        for i,dino in ipairs(dinos.dinos) do
            local y=HEIGHT-80 - i*60
            fill(50)
            rect(60,y,WIDTH-120,50)
            fill(255)
            text(dino.name.." Lv"..dino.level.." ["..(table.concat(dino.mutations or {},", ") or "None").."]",WIDTH/2,y+25)
        end
    end
    if self.active or self.winner then
        fill(0,0,0,180)
        rect(0,0,WIDTH,HEIGHT)
        fontSize(20)
        fill(255)
        text("Battle Log",WIDTH/2,HEIGHT-40)
        fontSize(16)
        local count=math.min(10,#self.log)
        for i=1,count do
            local entry=self.log[#self.log-count+i]
            local y=HEIGHT-60 - (count-i)*20
            text(entry,WIDTH/2,y)
        end
        if self.winner then
            fontSize(24)
            fill(self.winner=="player" and color(0,255,0) or color(255,0,0))
            text(self.winner=="player" and "🏆 Victory!" or "💀 Defeat...",WIDTH/2,HEIGHT/2)
            fontSize(16)
            fill(255,255,255,180)
            text("Tap anywhere to continue",WIDTH/2,HEIGHT/2-40)
        end
    end
    if self.feedback~="" then
        fontSize(16)
        fill(255)
        text(self.feedback,WIDTH/2,HEIGHT-80)
        if ElapsedTime - self.timer > 2 then self.feedback = "" end
    end
end

function Battle:touched(touch)
    if touch.state~=BEGAN then return end
    if self.winner then
        self.active = false
        self.selecting = false
        self.winner = nil
        self.log = {}
        self.feedback = ""
        return
    end
    player.coins = player.coins or 0
    if not self.active and not self.selecting
    and touch.x>WIDTH-160 and touch.x<WIDTH-60
    and touch.y>HEIGHT-60 and touch.y<HEIGHT-20 then
        if player.coins<300 then
            self.feedback="❌ Not enough coins (300 required)"
        else
            self.selecting=true
            self.feedback="🦖 Select a dino to battle"
        end
        self.timer=ElapsedTime
        return
    end
    if self.selecting then
        for i,dino in ipairs(dinos.dinos) do
            local y=HEIGHT-80 - i*60
            if touch.x>60 and touch.x<WIDTH-60 and touch.y>y and touch.y<y+50 then
                self.selecting=false
                player.coins=player.coins-300
                saveSystem:save()
                self:start({dino})
                self.feedback="⚔️ Battle started with "..dino.name.." (-300 coins)"
                self.timer=ElapsedTime
                return
            end
        end
    end
end

function Battle:start(playerTeam)
    if type(playerTeam)=="table" and playerTeam.name then playerTeam={playerTeam} end
    if type(playerTeam)~="table" or #playerTeam==0 or not playerTeam[1].name then
        self.feedback="❌ No dino selected for battle"
        return
    end
    self.playerTeam=playerTeam
    self.enemyTeam={}
    self.log={}
    self.winner=nil
    self.turn="player"
    self.timer=ElapsedTime
    local pool={"Indominus Rex","Velociraptor","Scorpion Full Potential","Tyrannosaurus","Spinosaurus"}
    while #self.enemyTeam<3 do
        local name=pool[math.random(#pool)]
        local mutation=self:pickCounterMutation()
        local base=DinoStats[name]
        if not base then name="Indominus Rex"; base=DinoStats[name] end
        local boost=mutationBoost({mutation})
        if type(boost)~="number" then boost=1.0 end
        local level=math.random(80,100)
        local attack=math.floor((base.attack or 100)*boost*(1+level*0.05))
        local health=math.floor((base.health or 100)*boost*(1+level*0.05))
        table.insert(self.enemyTeam,{name=name,level=level,attack=attack,health=health,mutations={mutation}})
    end
    self.active=true
end

function Battle:pickCounterMutation()
    local tiers={"Mythic","Apex","Omega","Eternal","Divine","Seraphic Grace"}
    return tiers[math.random(#tiers)]
end

function Battle:update()
    if not (self.active and not self.winner) then return end
    local attacker,defender,defenderTeam
    if self.turn=="player" then
        attacker=self.playerTeam[1]; defender=self.enemyTeam[1]; defenderTeam=self.enemyTeam
    else
        attacker=self.enemyTeam[1]; defender=self.playerTeam[1]; defenderTeam=self.playerTeam
    end
    if not attacker or not defender then return end
    local minDmg=math.max(1,math.floor(attacker.attack*0.8))
    local maxDmg=math.max(minDmg,attacker.attack)
    local raw=math.random(minDmg,maxDmg)
    local actual=math.min(raw,defender.health)
    defender.health=defender.health-actual
    table.insert(self.log,attacker.name.." dealt "..actual.." to "..defender.name)
    if defender.health<=0 then
        table.insert(self.log,defender.name.." was defeated!")
        table.remove(defenderTeam,1)
        if #self.playerTeam==0 then
            self.winner="enemy"
            self.active=false
            table.insert(self.log,"💀 You were defeated by the AI!")
            return
        elseif #self.enemyTeam==0 then
            self.winner="player"
            self.active=false
            table.insert(self.log,"🏆 You defeated the AI!")
            self:rewardPlayer()
            return
        end
        self.turn=(self.turn=="player") and "enemy" or "player"
        return
    end
    self.turn=(self.turn=="player") and "enemy" or "player"
end

function Battle:rewardPlayer()
    local dnaReward,potionReward,coinReward=10000,1,5000
    player.dna=(player.dna or 0)+dnaReward
    player.potions=(player.potions or 0)+potionReward
    player.coins=(player.coins or 0)+coinReward
    saveSystem:save()
    table.insert(self.log,string.format("🎁 Reward: +%d DNA, +%d Potion, +%d Coins",dnaReward,potionReward,coinReward))
end

function Battle:isActive()
    return self.active
end
