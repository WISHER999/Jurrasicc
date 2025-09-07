-- Documents/Jurrasicc/Cinematics.lua

-- Phase constants
local PHASE_SPIN  = "spin"
local PHASE_HALO  = "halo"
local PHASE_FLASH = "flash"
local PHASE_TEXT  = "text"
local PHASE_DONE  = "done"

-- Phase durations (seconds)
local D_SPIN  = 2
local D_HALO  = 1.5
local D_FLASH = 0.4

-- Pool sizes
local N_PARTICLES = 40
local N_FEATHERS  = 20
local N_MIST      = 25

-- Math shortcuts
local sin    = math.sin
local min    = math.min
local floor  = math.floor
local random = math.random

-- Screen center
local CX, CY = WIDTH/2, HEIGHT/2

Cinematics = class()

function Cinematics:init()
    -- Active state
    self.active      = false
    self.phase       = nil
    self.timer       = 0
    self.dino        = nil
    
    -- Cross transform
    self.crossAngle  = 0
    self.crossSize   = min(WIDTH, HEIGHT) * 0.7
    
    -- Glow / halo / text alphas
    self.glowAlpha   = 0
    self.haloAlpha   = 0
    self.haloPulse   = 0
    self.flashAlpha  = 0
    self.text        = ""
    self.textTimer   = 0
    self.rarityAlpha = 0
    
    -- Build effect pools
    self:makePool("particles", N_PARTICLES, function()
        return {
            x     = CX + random(-200,200),
            y     = CY + random(-200,200),
            size  = random(2,5),
            alpha = random(100,200),
            dx    = random(-100,100)/50,
            dy    = random(-100,100)/50
        }
    end)
    
    self:makePool("feathers", N_FEATHERS, function()
        return {
            x     = random(0,WIDTH),
            y     = HEIGHT + random(0,HEIGHT),
            dx    = random(-20,20)/100,
            dy    = -random(30,60)/100,
            size  = random(16,32),
            rot   = random(0,360),
            drot  = random(-2,2),
            alpha = random(150,255)
        }
    end)
    
    self:makePool("mist", N_MIST, function()
        return {
            x     = random(0,WIDTH),
            y     = random(0,HEIGHT),
            w     = random(150,300),
            h     = random(80,160),
            alpha = random(10,40),
            dx    = random(-10,10)/100,
            dy    = random(-10,10)/100
        }
    end)
    
    -- Load GoldenCross sprite
    self.crossImage = asset.documents.GoldenCross
    if not self.crossImage then
        print("❌ Missing asset.documents.GoldenCross")
    end
end

-- Returns current halo radius based on crossSize
function Cinematics:getHaloRadius()
    return self.crossSize * 1.2
end

-- Generic pool initializer
function Cinematics:makePool(name, count, factory)
    self[name] = {}
    for i = 1, count do
        self[name][i] = factory()
    end
end

-- Start the Seraphic pulse for a given dino
function Cinematics:triggerSeraphicPulse(dino)
    self.active      = true
    self.phase       = PHASE_SPIN
    self.timer       = ElapsedTime
    self.dino        = dino
    
    -- Reset transforms & timers
    self.crossAngle  = 0
    self.glowAlpha   = 0
    self.haloAlpha   = 0
    self.haloPulse   = 0
    self.flashAlpha  = 0
    self.text        = ""
    self.textTimer   = 0
    self.rarityAlpha = 0
end

function Cinematics:isPlaying()
    return self.active
end

-- Update all effects & advance phase
function Cinematics:update()
    if not self.active then return end
    local elapsed = ElapsedTime - self.timer
    
    -- Pulse glow alpha
    self.glowAlpha = (sin(ElapsedTime * 2) * 0.5 + 0.5) * 200 + 55
    
    -- Advance effect pools
    self:updatePool(self.particles, function(p)
        p.x = p.x + p.dx; p.y = p.y + p.dy
        if p.x < -20 or p.x > WIDTH+20 or p.y < -20 or p.y > HEIGHT+20 then
            p.x, p.y = CX + random(-200,200), CY + random(-200,200)
        end
    end)
    
    self:updatePool(self.feathers, function(f)
        f.x = f.x + f.dx; f.y = f.y + f.dy
        f.rot = (f.rot + f.drot) % 360
        if f.y < -f.size then
            f.x, f.y = random(0,WIDTH), HEIGHT + f.size
        end
    end)
    
    self:updatePool(self.mist, function(m)
        m.x = m.x + m.dx; m.y = m.y + m.dy
        if m.x < -m.w or m.x > WIDTH+m.w or m.y < -m.h or m.y > HEIGHT+m.h then
            m.x, m.y = random(0,WIDTH), random(0,HEIGHT)
        end
    end)
    
    -- Phase transitions
    self:advancePhase(elapsed)
end

-- Helper to advance any effect pool
function Cinematics:updatePool(pool, fn)
    for _, item in ipairs(pool) do fn(item) end
end

-- Manage phase changes & timers
function Cinematics:advancePhase(elapsed)
    if self.phase == PHASE_SPIN and elapsed > D_SPIN then
        self.phase = PHASE_HALO;  self.timer = ElapsedTime
        
    elseif self.phase == PHASE_HALO then
        self.haloPulse = self.haloPulse + DeltaTime
        self.haloAlpha = min(200, self.haloPulse * 200)
        if elapsed > D_HALO then
            self.phase = PHASE_FLASH; self.timer = ElapsedTime
        end
        
    elseif self.phase == PHASE_FLASH then
        self.flashAlpha = min(255, elapsed * 600)
        if elapsed > D_FLASH then
            self.phase     = PHASE_TEXT
            self.textTimer = ElapsedTime
        end
        
    elseif self.phase == PHASE_TEXT then
        local full  = "🪽 " .. self.dino.name .. " has transcended the limits and become a Seraphic 🪽"
        local chars = floor((ElapsedTime - self.textTimer) * 20)
        self.text    = string.sub(full, 1, chars)
        self.rarityAlpha = min(255,
        (ElapsedTime - self.textTimer - 2) * 120
        )
        if chars >= #full then
            self.phase = PHASE_DONE
            self.timer = ElapsedTime
        end
        
    elseif self.phase == PHASE_DONE and elapsed > 2 then
        self.active = false
    end
end

-- Draw sequence
function Cinematics:draw()
    if not self.active or not self.dino then return end
    
    self:drawBackground()
    self:drawMist()
    self:drawFeathers()
    self:drawParticles()
    self:drawGlow()
    self:drawHalo()
    self:drawCross()
    self:drawFlash()
    self:drawText()
end

-- 1) Warm smoky gradient backdrop
function Cinematics:drawBackground()
    for y = 0, HEIGHT, 4 do
        fill(120, 80, 30, 255 * (1 - y/HEIGHT) * 0.5)
        rect(0, y, WIDTH, 4)
    end
end

-- 2) Mist blobs
function Cinematics:drawMist()
    for _, m in ipairs(self.mist) do
        fill(180, 120, 60, m.alpha)
        ellipse(m.x, m.y, m.w, m.h * 0.6)
    end
end

-- 3) Falling leaves
function Cinematics:drawFeathers()
    for _, f in ipairs(self.feathers) do
        pushMatrix()
        translate(f.x, f.y); rotate(f.rot)
        fill(255, 200, 60, f.alpha)
        ellipse(0, 0, f.size * 0.4, f.size * 0.15)
        popMatrix()
    end
end

-- 4) Spark particles
function Cinematics:drawParticles()
    for _, p in ipairs(self.particles) do
        fill(255, 215, 100, p.alpha)
        ellipse(p.x, p.y, p.size * 0.5)
    end
end

-- 5) Additive glow ring
function Cinematics:drawGlow()
    blendMode(ADDITIVE)
    fill(255, 200, 80, self.glowAlpha)
    ellipse(CX, CY, self.crossSize * 1.6)
    blendMode(NORMAL)
end

-- 6) Pulsing halo ring
function Cinematics:drawHalo()
    if self.phase == PHASE_HALO
    or self.phase == PHASE_FLASH
    or self.phase == PHASE_TEXT then
        noFill()
        stroke(255, 223, 100, self.haloAlpha)
        strokeWidth(8)
        ellipse(CX, CY, self:getHaloRadius(), self:getHaloRadius())
        strokeWidth(1)
    end
end

-- 7) Spinning GoldenCross
function Cinematics:drawCross()
    if not self.crossImage then return end
    pushMatrix()
    translate(CX, CY)
    rotate(self.crossAngle)
    sprite(self.crossImage, 0, 0, self.crossSize, self.crossSize)
    popMatrix()
end

-- 8) White flash burst
function Cinematics:drawFlash()
    if self.phase == PHASE_FLASH then
        fill(255, 255, 255, self.flashAlpha)
        rect(0, 0, WIDTH, HEIGHT)
    end
end

-- 9) Typewriter text & rarity badge
function Cinematics:drawText()
    if self.phase == PHASE_TEXT
    or self.phase == PHASE_DONE then
        fontSize(32)
        fill(255, 255, 180)
        text(self.text, CX, CY - self.crossSize*0.6)
        
        if self.rarityAlpha > 0 then
            fontSize(20)
            fill(255, 215, 0, self.rarityAlpha)
            text("✨ Chance of 1 in 999,999 ✨",
            CX, CY - self.crossSize*0.8)
        end
    end
end
