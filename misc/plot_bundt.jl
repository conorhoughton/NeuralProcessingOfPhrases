using Gadfly
using Cairo, Fontconfig
using Compose

set_default_plot_size(8cm, 8cm)

plt1 = plot(z=(x,y) -> sqrt(x^2+y^2)*exp(-sqrt(x^2+y^2))/2π, xmin=[-3],
     xmax=[3], ymin=[-3], ymax=[3], Geom.contour,
           Coord.cartesian(fixed=true),Guide.xlabel(nothing),Guide.ylabel(nothing),
           style(major_label_font="CMU Serif",minor_label_font="CMU Serif", major_label_font_size=16pt,minor_label_font_size=14pt),
           Guide.colorkey(title="p(x,y)" ),Theme(background_color="white"))

draw(SVG("bundt.svg",8cm,8cm),plt1)

set_default_plot_size(8cm, 4cm)

plt2 = plot(x->x*exp(-x)/2π,0,3,style(major_label_font="CMU Serif",minor_label_font="CMU Serif",
                                      major_label_font_size=16pt,minor_label_font_size=14pt),
            Guide.yticks(ticks=[0.0,0.02,0.04,0.06]),
            Guide.ylabel("p(r)"),Guide.xlabel("r",orientation=:horizontal),
            Theme(background_color="white"))

draw(SVG("bundt_profile.svg",8cm,4cm),plt2)

#plts=vstack(plt2,plt1)

#draw(SVG("bundt.svg",8cm,12cm),plts)
