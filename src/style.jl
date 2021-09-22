include("colorscheme.jl")
using GLMakie

function generate_cmap(n)
    if n > length(COLORS)
        return cgrad(COLORS[1:4], n; categorical = false)
    else
        return cgrad(COLORS[1:min(length(COLORS), n)], n; categorical = true)
    end
end

function plot_2D_basins!(fig, basins, xg, yg;
        i = 1, j = 1, attractors = nothing, title = "",
        add_colorbar = true, idxs = 1:2, titlealign = :left,
    )

    title = replace(string(title), '_' => ' ')
    zeroi = findall(isequal(-1), basins)
    basins[zeroi] .= 0
    ids = sort!(unique(basins))
    cmap = generate_cmap(length(ids))
    ax = Axis(fig[i,j]; title, titlealign)
    
    hm = heatmap!(ax, xg, yg, basins; 
        colormap = cmap, colorrange = (ids[1] - 0.5, ids[end]+0.5),
    )
    if add_colorbar
        cb = Colorbar(fig[i,j+1], hm)
        l = string.(ids)
        if 0 ∈ ids
            l[1] = "-1"
        end 
        cb.ticks = (ids, l)
    end

    if !isnothing(attractors)
        for k ∈ keys(attractors)
            k == 0 && continue
            j = 0 ∈ ids ? k+1 : k
            @show j
            scatter!(ax, attractors[k][:, idxs].data;
                color = cmap[j], strokewidth = 3, strokecolor = :white
            )
        end
    end
    display(fig)
    return ax
end

# other styling elements for Makie
set_theme!(;
    palette = (color = COLORS,), 
    fontsize = 30
)