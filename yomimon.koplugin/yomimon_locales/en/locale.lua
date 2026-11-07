return {
    name = "English",
    format = {
        clock = function(d)
            local h = d.hour % 12
            if h == 0 then h = 12 end
            return string.format("%d:%02d %s", h, d.min, d.hour < 12 and "a.m." or "p.m.")
        end,
        months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
                   "November", "December" },
        ordinals = { "Second", "Third", "Fourth", "Fifth", "Sixth" },
        thousands = ",",
        lowercase_after = { endings = { ":", ",", "but" }, openings = { "I think…", "I've thought about it and" } },
    },
}
