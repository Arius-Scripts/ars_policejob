local AddBlipForCoord             = AddBlipForCoord
local SetBlipSprite               = SetBlipSprite
local SetBlipDisplay              = SetBlipDisplay
local SetBlipScale                = SetBlipScale
local SetBlipColour               = SetBlipColour
local SetBlipAsShortRange         = SetBlipAsShortRange
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
local AddTextComponentString      = AddTextComponentString
local EndTextCommandSetBlipName   = EndTextCommandSetBlipName
local DeletePed                   = DeletePed
local cfg                         = Config.PoliceStation

-- Creating blip
local blip                        = AddBlipForCoord(cfg.blip.pos)
SetBlipSprite(blip, cfg.blip.type)
SetBlipDisplay(blip, 6)
SetBlipScale(blip, cfg.blip.scale)
SetBlipColour(blip, cfg.blip.color)
SetBlipAsShortRange(blip, true)

BeginTextCommandSetBlipName('STRING')
AddTextComponentString(cfg.blip.name)
EndTextCommandSetBlipName(blip)


-- Zones
local zone = lib.zones.box({
    name = 'police',
    coords = cfg.zone.pos,
    size = cfg.zone.size,
    clothes = Config.ClothingScript and cfg.clothes,
    rotation = 0.0,
    onEnter = function(self)
        if self.clothes then
            initClothes(self.clothes)
        end
        initArmory(cfg.armory)
        initGarage(cfg.garage)
    end,
    onExit = function(self)
        for k, v in pairs(peds) do
            if DoesEntityExist(v) then
                DeletePed(v)
            end
        end
    end
})



AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for k, v in pairs(peds) do
        if DoesEntityExist(v) then
            DeletePed(v)
        end
    end
end)
