
using Gadfly
using Cairo, Fontconfig

include("load_locations.jl")

electrodeLocs=loadLocs()

thisPlot=plot(electrodeLocs,x=:x,y=:y);

draw(PNG("test.png", 3inch, 3inch), thisPlot)
