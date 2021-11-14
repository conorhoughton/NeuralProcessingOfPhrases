#there must be a better way to do this!

using Gadfly
using Cairo, Fontconfig
using Compose

function wrappedCauchy(γ,μ)
   pdf(θ) = 1/2π * sinh(γ) / (cosh(γ) - cos(θ-μ))
end

set_default_plot_size(8cm, 8cm)

nPoints=200

θs=range(-π,π, length=nPoints)

xticks = [0,49,99,149,199]
labels = Dict(zip(xticks, ["-π","-π/2","0","π/2","π"]))

pdf0=wrappedCauchy(0.5,0.0)
pdf1=wrappedCauchy(1.0,0.0)
pdf2=wrappedCauchy(2.0,0.0)
pdf3=wrappedCauchy(5.0,0.0)

pdfs=[[pdf0(θ) for θ in θs],[pdf1(θ) for θ in θs],[pdf2(θ) for θ in θs],[pdf3(θ) for θ in θs]]

plt=plot(pdfs, x=Row.index, y=Col.value, color=Col.index,
         Scale.color_discrete_manual("blue","red","purple","green"),
         Stat.xticks(ticks=xticks),
         Scale.x_continuous(labels = x -> labels[x]),
         Geom.line,
         style(major_label_font="CMU Serif",minor_label_font="CMU Serif"),
         Theme(background_color="white"),
         Guide.colorkey(title="γ",labels=["0.5","1.0","2.0","5.0"]),
         Guide.xlabel("θ"),Guide.ylabel("p(θ)")
         )

#draw(SVG("wrapped_cauchy.svg",8cm,12cm),plt)
draw(PDF("wrapped_cauchy.pdf",8cm,8cm),plt)
