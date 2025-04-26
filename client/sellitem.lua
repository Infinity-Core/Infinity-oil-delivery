local sellitemCallback = nil

RegisterNUICallback('sellitem_confirm', function(data, cb)
    if sellitemCallback then
        sellitemCallback(tonumber(data.amount), data.itemImage)
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellitem_cancel', function(_, cb)
    if sellitemCallback then
        sellitemCallback(nil)
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

function ShowSellItemPrompt(opts, cb)
    sellitemCallback = cb
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        item = opts.item,
        itemLabel = opts.itemLabel,
        itemImage = opts.itemImage,
        max = opts.max
    })
end

exports('sellitemPrompt', ShowSellItemPrompt) 