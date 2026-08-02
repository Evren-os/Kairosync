yay.opt.combined_upgrade = true
yay.opt.diff_menu = true
yay.opt.clean_after = true
yay.opt.devel = true

yay.create_autocmd("UpgradeSelect", {
    desc = "Skip recently modified AUR upgrades",
    callback = function(event)
        yay.log.info("Analyzing package age for potential supply chain risks...")
        local exclude = {}

        local recent_cutoff = os.time() - (2 * 24 * 60 * 60)

        for _, pkg in ipairs(event.data.upgrades) do
            if pkg.repository == "aur" and pkg.last_modified >= recent_cutoff then
                yay.log.warn("Excluding recently modified packages: " .. pkg.name)
                table.insert(exclude, pkg.name)
            end
        end

        return { exclude = exclude, skip_menu = false }
    end,
})