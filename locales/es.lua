local Translations = {

    -- Lang:t('lang_2')
    lang_1 = 'Inciar ',
    lang_2 = 'Abrir ',
    lang_3 = ' Menú Hielo',
    lang_4 = '¡Estás ocupado!',
    lang_5 = 'No puedes hacer eso ahora mismo',
    lang_6 = "¡No tienes un pico!",
    lang_7 = '¡Necesitas uno, hazte con él!',
    lang_8 = "¡Se ha roto el pico!",
    lang_9 = "Ya estaba viejo, necesitas uno nuevo",
    lang_10 = "Minando hielo...",
    lang_11 = 'Comprobando para selloil...',
    -- entrega
    lang_12 = 'Entrega fallida',
    lang_13 = 'Se le acabó el tiempo, misión fallida',
    lang_14 = 'Tiempo de entrega restante: ',
    lang_15 = "Necesito enviar hielo...",
    lang_16 = "¿puedes ayudar? Entrega a.. ",
    lang_17 = 'Comienza ',
    lang_18 = 'Creo que el coche estaba entre los árboles o en la carretera, mira a tu alrededor... ya has seleccionado una entrega',
    lang_19 = "Vender hielo",
    lang_20 = "Toma el dinero y corre",
    lang_21 = 'Ya has seleccionado',
    lang_22 = 'Su entrega es',
    lang_23 = ' seleccionó una entrega',
    lang_24 = 'Entrega exitosa',
    lang_25 = 'Ha completado su entrega',
    -- servidor
    lang_26 = 'Vendido todo',
    lang_27 = 'ha vendido todo su hielo por $ ',
    lang_28 = 'Necesitas hielo',
    lang_29 = 'no tienes hielo para vender',
    lang_30 = '¡Conseguiste algo!',
    lang_31 = 'No es mucho, pero mejor que nada..',
    lang_32 = '¡Conseguiste algo!',
    lang_33 = 'Fiebre del minero, más hielo..',
    lang_36 = '¡Algo salió mal!',
    lang_35 = 'Revisa el inventario, algo pasa..',
}

if GetConvar('rsg_locale', 'en') == 'es' then
  Lang = Locale:new({
      phrases = Translations,
      warnOnMissing = true,
      fallbackLang = Lang,
  })
end
