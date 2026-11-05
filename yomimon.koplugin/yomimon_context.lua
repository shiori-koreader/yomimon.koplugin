--[[--
Falas com dados da sua leitura: hora, páginas de hoje, recorde, sequência de dias,
sessão sem parar, dias sumido e em que parte do livro você está.

Cada gatilho olha o estado (preenchido por Estado.comer) e, se valer, oferece frases
com brechas: {hora} ("2h13" / "2:13 a.m."), {n} (páginas ou dias), {livro}, {pct}.
Gatilhos "fortes" (madrugada, recorde, maratona, sumiço) costumam ganhar das outras falas.

Lógica pura (sem KOReader), testável fora dele.
]]

local Lingua = require("yomimon_language")
local Voz = require("yomimon_voice")

local Contexto = {}

local LENDO_AGORA = 30 * 60   -- leu nos últimos 30 min: está lendo agora

-- Frases por gatilho e temperamento ("jovem" = ninfa e jovem; "velha" = adulta e anciã).
local FALAS = {
    madrugada = {
        jovem = {
            "São {hora}. A gente não devia estar dormindo? <noturna:Eu adoro essa hora.|Eu tô com medo do escuro e você lendo.>",
            "{hora} e você aqui. Tá tudo bem? Eu tô bem. Acho. Tô com sono.",
            "Ler às {hora} parece proibido. <medrosa:Fiquei com medo.|noturna:Nosso horário favorito.|Gostei.>",
            "Às {hora} as letras ficam maiores. Ou meus olhos ficam menores.",
            "{hora}! Se alguém perguntar, a gente estava dormindo.<dominio: Sonhando {lugar}.|>",
        },
        velha = {
            "{hora}. Nada de bom foi lido depois da meia-noite. Exceto tudo o que presta.",
            "Lendo às {hora}. <noturna:A melhor hora, eu sempre disse.|diurna:Isso não é hora de gente.|Amanhã você culpa o livro. Eu culpo você.>",
            "{hora} da madrugada. Eu com meu cigarro imaginário, você com a luz do Kindle. Dois vícios.",
            "{hora}. A hora em que toda frase parece verdade. Cuidado com o que sublinha.",
        },
    },
    recorde = {
        jovem = {
            "Nunca comi tanto num dia: {n} páginas. Minha barriga tá orgulhosa e assustada.",
            "Recorde de {n} páginas. Acho que cresci um milímetro.",
        },
        velha = {
            "Novo recorde: {n} páginas num dia. Você está fugindo de alguma coisa?",
            "{n} páginas. Nunca comi tanto. Anote a data, que eu vou reclamar dela depois.",
        },
    },
    maratona = {
        jovem = {
            "{n} páginas hoje. <corajosa:Aguento mais cem.|Minha barriga tá redondinha.>",
            "Já foram {n} páginas! Eu não ando mais, só rolo.",
        },
        velha = {
            "{n} páginas hoje. Minha barriga agradece; minha dignidade, nem tanto.",
            "{n} páginas. <erudita:Proust aprovaria. Talvez.|Isso não é leitura, é mudança de endereço.>",
            "Já são {n} páginas. Pisque. Beba água. Depois volte, claro.",
        },
    },
    sumiu = {
        jovem = {
            "{n} dias sem papel. Contei cada hora. <medrosa:Com medo de você não voltar.|Foram muitas.>",
            "{n} dias! De fome, quase comi minha própria sombra. <medrosa:Ela me assustou.|corajosa:Lutei com ela.|dominio:Tinha gosto de {gosto}.|>",
        },
        velha = {
            "{n} dias sem ler. <otimista:Tudo bem, a gente recomeça.|A civilização caiu e ninguém me avisou?>",
            "{n} dias. Fiquei aqui, ruminando a orelha do livro<erudita: e uma tese|dominio: e sonhando com {coisa}|>.",
            "{n} dias sem você. <romantica:Senti sua falta. Pronto, falei.|Não vou perguntar onde estava. Estava sem ler, é o que importa.>",
        },
    },
    tarde = {
        jovem = {
            "Já são {hora}. Só mais um capítulo, né? Eu sei como isso termina.",
            "<noturna:{hora}… tô bem acordadinha. Continua.|{hora}… meus olhinhos tão pesando, mas continua.>",
            "Ler às {hora} é tipo contar segredo. Baixinho.",
        },
        velha = {
            "{hora}. A hora em que todo leitor jura que dorme depois deste capítulo.",
            "São {hora}. O livro não vai fugir. Você vai, de sono.",
            "{hora}. Ainda acordada <noturna:por gosto. A noite é minha|por sua causa. Não que eu me importe>.",
        },
    },
    cedo = {
        jovem = {
            "Lendo às {hora}? Antes do café? <diurna:Adoro a manhã!|noturna:Eu nem dormi ainda.|Que coragem.>",
            "{hora} e já me dando comida. Que bom dia!",
            "Acordou cedo pra ler? Eu acordei cedo pra comer. Somos uma equipe.",
        },
        velha = {
            "{hora}. Ler antes do café. <diurna:A única ordem natural das coisas.|Não entendo, mas respeito.>",
            "São {hora}. Os pássaros cantam, você lê, eu como. A única ordem natural que aprovo.",
            "Leitura às {hora}. O dia nem começou e já está melhor que ontem.",
        },
    },
    sessao = {
        jovem = {
            "{n} páginas sem parar! Posso respirar?",
            "Você leu {n} páginas de uma vez. Tá tudo bem aí fora?",
            "{n} páginas seguidas. Esse livro te pegou. Me pegou também.",
        },
        velha = {
            "{n} páginas seguidas. Ou o livro é bom, ou sua vida está pior.",
            "Uma sessão de {n} páginas. Os monges copistas aprovariam.",
        },
    },
    sequencia = {
        jovem = {
            "{n} dias seguidos lendo! Tô ficando mal acostumada.",
            "Dia {n} seguido de comida. Acho que você gosta de mim.<dominio: Hoje teve {gosto}.|>",
            "{n} dias sem falhar. <romantica:Isso já é namoro.|otimista:Vai virar cem.|Não para agora, tá?>",
        },
        velha = {
            "{n} dias seguidos. Constância: a virtude mais chata e mais rara.",
            "{n} dias lendo sem falta. <otimista:Acredito em você.|cinica:Vamos ver quanto dura.|Estou quase acreditando em você.>",
            "Dia {n} seguido. Não vou elogiar. Pronto, elogiei.",
        },
    },
    bom_dia = {
        jovem = {
            "{n} páginas hoje. Tô ficando cheinha.",
            "{n} páginas hoje. <amarga:Pelo menos isso.|Tá sendo um bom dia, né?>",
        },
        velha = {
            "{n} páginas hoje. Respeitável. Não espetacular, mas respeitável.<dominio: Com gosto de {gosto}.|>",
            "{n} páginas hoje. Já dá pra chamar de leitura.",
            "{n} páginas. Um dia decente. <otimista:Andam aparecendo mais.|Raros, os dias decentes.>",
        },
    },
    nada_hoje = {
        jovem = {
            "Nenhuma página hoje… tudo bem, eu espero. Espero muito.",
            "Hoje ainda não comi nada. Nem uma vírgula.",
            "O dia tá acabando e o livro fechado. Fiquei olhando a capa.",
        },
        velha = {
            "Nenhuma página hoje. O dia ainda não acabou. Mas está tentando.",
            "Hoje: zero páginas. Anotado no meu diário de decepções.",
            "O livro passou o dia fechado. Eu também, por dentro.",
        },
    },
    reta_final = {
        jovem = {
            "{pct} de “{livro}”. Tá acabando! Não quero que acabe!",
            "Reta final de “{livro}”. <corajosa:Vou até o fim sem piscar.|medrosa:Vou comer de olhos fechados.|Vou comer devagar pra durar.>",
            "Falta pouco pra acabar “{livro}”. E depois, o que eu vou comer?",
        },
        velha = {
            "{pct} de “{livro}”. A reta final. <otimista:É aqui que os bons autores brilham.|É aqui que os autores estragam tudo.>",
            "Quase no fim de “{livro}”. Não me conte. Eu vou comer o final de qualquer jeito.",
            "Últimas páginas de “{livro}”. Prepare-se para o vazio pós-livro. Eu já moro nele.",
        },
    },
    metade = {
        jovem = {
            "Metade de “{livro}”! Tá ficando bom. Ou ruim. Ainda não sei.",
            "Já comi metade de “{livro}”. A outra metade tá me olhando.",
        },
        velha = {
            "Metade de “{livro}”. Daqui pra frente, ladeira abaixo.",
            "Meio de “{livro}”. O ponto em que os autores costumam se perder.",
        },
    },
    comeco = {
        jovem = {
            "Começando “{livro}”… cheira a {cheiro|papel novo}. Ou a problema.",
            "Primeiras páginas de “{livro}”. <corajosa:Já tô animada.|Já tô nervosa.>",
        },
        velha = {
            "Começo de “{livro}”. Toda capa promete. Vamos ver o que cumpre.",
        },
    },
    fim_de_semana = {
        jovem = {
            "Fim de semana lendo! O melhor tipo de fim de semana.",
            "Fim de semana é dia de papel. Oba.",
        },
        velha = {
            "Fim de semana e você lendo. Nada de festa? Ótimo. Festas são superestimadas.",
            "Fim de semana. O mundo sai, você lê. Escolha certa.",
        },
    },
}

-- Em inglês, as mesmas listas vêm de yomimon_en.lua.
local EN = Lingua.conteudo("contexto")
if EN then FALAS = EN end
Lingua.anexar(FALAS, Lingua.extra("contexto"))  -- lotes novos de frases

--- Hora para as falas: "2h13" (pt) ou "2:13 a.m." (en).
function Contexto.hora(agora)
    local d = os.date("*t", agora)
    if Lingua.ingles() then
        local h = d.hour % 12
        if h == 0 then h = 12 end
        return string.format("%d:%02d %s", h, d.min, d.hour < 12 and "a.m." or "p.m.")
    end
    if d.min == 0 then return d.hour .. "h" end
    return string.format("%dh%02d", d.hour, d.min)
end

--- Gatilhos que valem agora, cada um { nome, n, forte }, os fortes primeiro.
function Contexto.gatilhos(s, agora)
    local lista = {}
    local function add(nome, n, forte) lista[#lista + 1] = { nome = nome, n = n, forte = forte or false } end
    local hora = tonumber(os.date("%H", agora))
    local hoje_dia = os.date("%Y-%m-%d", agora)
    local hoje = s.hoje == hoje_dia and (s.paginas_hoje or 0) or 0
    local desde = s.ultima_refeicao and (agora - s.ultima_refeicao)
    local lendo = desde and desde < LENDO_AGORA

    if lendo and hora < 5 then add("madrugada", nil, true) end
    if s.recorde_em == hoje_dia and hoje >= 10 and hoje >= (s.recorde_dia or 0) then add("recorde", hoje, true)
    elseif hoje >= 40 then add("maratona", hoje, true) end
    if desde and desde >= 2 * 86400 then add("sumiu", math.floor(desde / 86400), true) end

    if lendo and hora >= 22 then add("tarde") end
    if lendo and hora >= 5 and hora < 9 then add("cedo") end
    if lendo and (s.sessao_paginas or 0) >= 25 then add("sessao", s.sessao_paginas) end
    if (s.sequencia or 0) >= 3 and s.hoje == hoje_dia then add("sequencia", s.sequencia) end
    if hoje >= 15 and hoje < 40 then add("bom_dia", hoje) end
    if hoje == 0 and hora >= 19 and desde and desde >= 6 * 3600 and desde < 2 * 86400 then add("nada_hoje") end
    local pct = s.ultimo_progresso
    if pct and s.ultimo_livro and desde and desde < 86400 then
        if pct >= 0.9 and pct < 1 then add("reta_final", math.floor(pct * 100))
        elseif pct >= 0.45 and pct <= 0.55 then add("metade")
        elseif pct < 0.05 then add("comeco") end
    end
    local dia_semana = tonumber(os.date("%w", agora))
    if (dia_semana == 0 or dia_semana == 6) and hoje >= 5 then add("fim_de_semana") end
    return lista
end

--- Uma fala com dados da leitura, ou nil. Devolve também se o gatilho é forte.
-- temperamento: "jovem" ou "velha". sorteio(n) devolve um inteiro de 1 a n.
function Contexto.fala(s, agora, temperamento, sorteio)
    sorteio = sorteio or math.random
    local lista = Contexto.gatilhos(s, agora)
    if #lista == 0 then return nil end
    local g = lista[1].forte and lista[1] or lista[sorteio(#lista)]
    local banco = FALAS[g.nome] and FALAS[g.nome][temperamento]
    if not banco then return nil end
    local valores = {
        hora = Contexto.hora(agora), n = g.n and tostring(g.n),
        livro = s.ultimo_livro, pct = g.n and (g.n .. "%"),
    }
    -- as palavras de domínio ({gosto}, {cheiro}…) ficam para o resolvedor de voz (yomimon_voice.lua)
    local texto = Voz.escolher(banco, s, sorteio):gsub("{(%a+)}", function(b)
        if valores[b] then return valores[b] end
        if Voz.SLOTS[b] then return nil end
        return b
    end)
    texto = texto:gsub("([ap]%.m%.)%.", "%1")  -- "It's 2:13 a.m.." → "It's 2:13 a.m."
    return texto, g.forte
end

return Contexto
