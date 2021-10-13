
using Gadfly
using Cairo, Fontconfig

include("load_locations.jl")

electrodeLocs=loadLocs()

thisPlot=plot(electrodeLocs,x=:x,y=:y,Theme(background_color="white"));

draw(PNG("test.png", 8inch, 8inch), thisPlot)
