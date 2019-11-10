
#                                                                _|
#    _|_|_|    _|_|    _|_|_|      _|_|    _|  _|_|    _|_|_|  _|_|_|_|    _|_|
#  _|    _|  _|_|_|_|  _|    _|  _|_|_|_|  _|_|      _|    _|    _|      _|_|_|_|
#  _|    _|  _|        _|    _|  _|        _|        _|    _|    _|      _|
#    _|_|_|    _|_|_|  _|    _|    _|_|_|  _|          _|_|_|      _|_|    _|_|_|
#        _|
#    _|_|


function flatDalitzPlotSample31(tbs; Nev::Int=10000, σ3bins::Int=500)
    s = tbs.msq[4]
    density = getbinned1dDensity(σ1->sqrt(λ(σ1,tbs.msq[2],tbs.msq[3])*λ(σ1,s,tbs.msq[1]))/σ1, (tbs.mthsq[1],tbs.sthsq[1]), σ3bins)
    σ1 = [rand(density) for _ in 1:Nev]
    σ3 = [σ3of1(2*rand()-1,σ,tbs.msq) for σ in σ1]
    return (σ3, σ1)
end

function four_vectors_in_binary_decay(cosθ, ϕ;
        m1sq::Real=error("give mass 1 squared"),
        m2sq::Real=error("give mass 2 squared"),
        m0sq::Real=error("give decay mass squared"))
    E1 = (m0sq+m1sq-m2sq)/(2sqrt(m0sq));
    E2 = (m0sq-m1sq+m2sq)/(2sqrt(m0sq));
    p = sqrt(λ(m0sq,m1sq,m2sq))/(2sqrt(m0sq));
    #
    sinθ = sqrt(1-cosθ^2)
    p1 = [p*sinθ*cos(ϕ), p*sinθ*sin(ϕ), p*cosθ, E1]
    p2 = [-p*sinθ*cos(ϕ), -p*sinθ*sin(ϕ), -p*cosθ, E2]
    [p1, p2]
end

function four_vectors_in_binary_decay(p0,cosθ,ϕ;
        m1sq::Real=error("give mass 1 squared"),
        m2sq::Real=error("give mass 2 squared"))
    psq = sum(abs2,p0[1:3])
    m0sq = p0[4]^2-psq
    #
    γ = p0[4]/sqrt(m0sq)
    cosθ0 = p0[3]/sqrt(psq)
    ϕ0 = atan(p0[2],p0[1])
    #
    p1, p2 = four_vectors_in_binary_decay(cosθ,ϕ; m1sq=m1sq, m2sq=m2sq, m0sq=m0sq)
    boostz!(p1,γ); roty_cos!(p1,cosθ0); rotz!(p1, ϕ0)
    boostz!(p2,γ); roty_cos!(p2,cosθ0); rotz!(p2, ϕ0)
    #
    return [p1, p2]
end



invmasssq(p) = p[4]^2-sum(abs2, p[1:3])

function rotz!(p,θ)
    c, s = cos(θ), sin(θ)
    p[1], p[2] = [c -s; s c]*[p[1], p[2]]
    return
end
function roty!(p,θ)
    c, s = cos(θ), sin(θ)
    p[1], p[3] = [c s; -s c]*[p[1], p[3]]
    return
end
function roty_cos!(p,cosθ)
    c, s = cosθ, sqrt(1-cosθ^2)
    p[1], p[3] = [c s; -s c]*[p[1], p[3]]
    return
end
function boostz!(p,γ)
    γ, βγ = γ*sign(γ), sqrt(γ^2-1)*sign(γ)
    p[3], p[4] = [γ βγ; βγ γ]*[p[3], p[4]]
    return
end
