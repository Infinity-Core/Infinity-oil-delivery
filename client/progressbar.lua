local progressActive = false
local progressCallback = nil

RegisterNUICallback('finish', function(_, cb)
    if progressActive and progressCallback then
        progressCallback(true)
    end
    progressActive = false
    SetNuiFocus(false, false)
    cb('ok')
end)

function ShowProgressbar(text, time, cb, itemImage)
    if progressActive then return end
    progressActive = true
    progressCallback = cb
    SetNuiFocus(false, false)
    local msg = {
        action = 'show',
        text = text,
        time = time
    }
    if itemImage then
        msg.itemImage = itemImage
    end
    SendNUIMessage(msg)
end

function HideProgressbar()
    SendNUIMessage({action = 'hide'})
    progressActive = false
end

exports('progressbar', ShowProgressbar)
exports('hideProgressbar', HideProgressbar) 