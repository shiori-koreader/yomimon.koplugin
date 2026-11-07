return {
    name = "Português (Brasil)",
    format = {
        clock = function(d)
            if d.min == 0 then return d.hour .. "h" end
            return string.format("%dh%02d", d.hour, d.min)
        end,
        months = { "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro",
                   "novembro", "dezembro" },
        ordinals = { "Segundo", "Terceiro", "Quarto", "Quinto", "Sexto" },
        thousands = ".",
        lowercase_after = { endings = { ":", ",", "mas" }, openings = { "Sabia que…", "Acho que…", "Pensei bastante e" } },
    },
}
