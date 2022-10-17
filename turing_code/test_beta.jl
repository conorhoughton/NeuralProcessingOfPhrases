using Distributions

function betaPdf(α,β,x)
    return Distributions.pdf(Beta(α,β),x)
end

println(betaPdf(1.0,2.0,[0.5,0.5]))
