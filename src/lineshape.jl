function ChewMandestam(s,m1sq,m2sq)
    m1, m2 = sqrt(m1sq), sqrt(m2sq)
    #
    sth,spth = (m1+m2)^2, (m1-m2)^2;
    λh = sqrt(spth-s)*sqrt(sth-s)
    #
    val = 1/(π) * (
        λh/s*log((m1sq+m2sq-s+λh)/(2*m1*m2))-
            (m1sq-m2sq) * (1.0/s - 1/sth) * log(m1/m2)
    )
    return val
end

function Rho(s,m1sq,m2sq)
    m1, m2 = sqrt(m1sq), sqrt(m2sq)
    #
    sth,spth = (m1+m2)^2, (m1-m2)^2;
    λh = sqrt(s-sth)*sqrt(s-spth)
    return λh/s
end
iRho(s,m1sq,m2sq) = 1im*Rho(s,m1sq,m2sq)


#  _|  _|                                _|
#  _|      _|_|_|      _|_|      _|_|_|  _|_|_|      _|_|_|  _|_|_|      _|_|
#  _|  _|  _|    _|  _|_|_|_|  _|_|      _|    _|  _|    _|  _|    _|  _|_|_|_|
#  _|  _|  _|    _|  _|            _|_|  _|    _|  _|    _|  _|    _|  _|
#  _|  _|  _|    _|    _|_|_|  _|_|_|    _|    _|    _|_|_|  _|_|_|      _|_|_|
#                                                            _|
#                                                            _|

pole(σ,mcsq) = 1.0/(mcsq - σ)
BW(σ,m,Γ) = pole(σ,m^2-1im*m*Γ)

function BWdw(σ,m,Γ,m1,m2)
    √σ < (m1+m2) && return 0.0im
    ρσ = sqrt(λ(σ,m1^2,m2^2))/σ
    ρ0 = sqrt(λ(m^2,m1^2,m2^2))/m^2
    pole(σ,m^2-1im*m*Γ*ρσ/ρ0)
end

struct Lineshape{T<:Real}
    itype::Int
    type::String
    pars::Vector{T}
end

# Breit-Wigner with constant width
Lineshape(m,Γ) = Lineshape(0,"BW",[m,Γ])
BreitWigner(m,Γ) = Lineshape(0,"BW",[m,Γ])

function amp(s,lsh::Lineshape)
    (lsh.itype == 0) && return BW(s,lsh.pars[1],lsh.pars[2])
    error("No itype #$(lsh.itype) found")
    return 0.0im
end


#            _|
#  _|_|_|    _|_|_|          _|_|_|  _|_|_|
#  _|    _|  _|    _|      _|_|      _|    _|
#  _|    _|  _|    _|          _|_|  _|    _|
#  _|_|_|    _|    _|  _|  _|_|_|    _|_|_|    _|
#  _|                                _|
#  _|                                _|

RhoQTB(s,m1,m2,Γ1,m1th) = √s < (m2+m1th) ? 0.0 : 1.0/s*quadgk(σ->sqrt((s-(√σ+m2)^2)*(s-(√σ-m2)^2)) * m1*Γ1 / π / ((m1^2-σ)^2+(m1*Γ1)^2), m1th^2, (√s-m2)^2)[1]
iRhoQTB(s,m1,m2,Γ1,m1th) = 1im*RhoQTB(s,m1,m2,Γ1,m1th)

# k(s,m1,m2) = sqrt(s-(m1+m2)^2)
# kapp(s,m1,m2,Γ1,m1th) = real(k(s,m1-1im*Γ1/2,m2)-k((m1th+m2)^2,m1-1im*Γ1/2,m2))
# function discretise(f, xmin, xmax; npoints=50)
#     ev = LinRange(xmin, xmax, npoints)
#     calv = f.(ev)
#     return interpolate((ev,), calv, Gridded(Linear()))
# end
# calv = map(e->kint(e^2,mρ,mJpsi,0.15,2mπ), ev)
# plot(e->itp0(e),mJpsi+2mπ, 4.3)
