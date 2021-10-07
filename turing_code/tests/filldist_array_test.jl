
using Turing, Distributions
using Random

angleData=rand(Normal(),3,2,100)

@model function fitTest(data) 

    mu ~ filldist(Normal(),3,2)

    for i in 1:100
        for j in 1:3
            for k in 1:2
                data[j,k,i] ~ Normal(mu[j,k],1)
            end
        end
    end
    
    
end

tau = 10
iterations = 1000

chain = sample(fitTest(angleData), NUTS(0.85), iterations, progress=true)

    
