# %%
# error in makie: unpleasant experience with missing attributes from docs
# I passed cmap = :dense or CategoricalColormap. Got unhelpful error
# started searching docstrings. Nothing worked. It was impossible to use Makie
# via the help system. The error messages were also "wrong". for example,
# `scatter!(ax, data; color = c, edgecolor = :white)` throws the "wrong" error
# `MethodError: no method matching gl_convert(::Symbol)`, while in truth what
# happens is that the keyword `edgecolor` is a wrong name. Correct keyword is 
#  markeredgecolor....
# (exactly same error with `heatmap(...; cmap = )`)

# Please, please, please put **all** attributes of a plotting function in its
# docstring...

# change
#  Went to the downloaded docs
# but even then there was no example that illustrated how to change colormap

# I then went to the "online docs" which I have downloaded myself. I was getting
# increasingly frustrated with how hard it was to find the keywords of a `scatter` plot.
# It wasn't where I expected: where the `scatter` atomic function is presented.
# They absolutely must be there.
# I finally leanred I have to do: 

fig, ax, o = GLMakie.scatter(rand(5), rand(5))

o.attributes

# to see all keywords. That's kind of crazy. Noone wants to do this.