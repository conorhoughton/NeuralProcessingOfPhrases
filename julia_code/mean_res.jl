
function meanResultant(a)
    meanResultant(a,1)
end

function meanResultant(a,dim::Int64)
    #dropdims(abs.(sum(a,dims=dim)./size(a)[dim]),dims=dim)
    dropdims(abs.(mean(a,dims=dim)),dims=dim)
end

function circularMeasures(a)
    r=dropdims(sum(a,dims=1)./size(a)[1],dims=1)
    (angle.(r),abs.(r))
end


function phaseMeasures(a)
    r=dropdims(sum(a,dims=1)./size(a)[1],dims=1)
    r
end


function circularVariance(a)
    -2*log.(meanResultant(a))
end


# this is the bias corrected (mean resultant) squared from
# Kutil, Rade. "Biased and unbiased estimation of the circular mean resultant length and its variance." Statistics 46.4 (2012): 549-561.

function biasCorrect(a)
    (dropdims(abs.(sum(a,dims=1).^2/size(a)[1]),dims=1)-ones(Float64,size(a)[2:3]))/(size(a)[1]-1)
end



function getPower(a)
    getPower(a,1)
end

function getPower(a,dim::Int64)
    dropdims( mean((abs.(a)).^2,dims=dim) ,dims=dim)
end

