#                                  _|
#    _|_|_|  _|    _|    _|_|_|  _|_|_|_|    _|_|    _|_|_|  _|_|
#  _|_|      _|    _|  _|_|        _|      _|_|_|_|  _|    _|    _|
#      _|_|  _|    _|      _|_|    _|      _|        _|    _|    _|
#  _|_|_|      _|_|_|  _|_|_|        _|_|    _|_|_|  _|    _|    _|
#                  _|
#              _|_|


@with_kw struct ThreeBodyMasses
    m0::Float64
    m1::Float64
    m2::Float64
    m3::Float64
    ThreeBodyMasses(m0,m1,m2,m3) = m0<m1+m2+m3 ? error("m₀ should be bigger than m₁+m₂+m₃") : new(m0,m1,m2,m3)
end

lims(k::Int,ms::ThreeBodyMasses) = k==1 ? lims1(ms) : (k==2) ? lims2(ms) : lims3(ms)
lims1(ms::ThreeBodyMasses) = ((ms.m2+ms.m3)^2, (ms.m0-ms.m1)^2)
lims2(ms::ThreeBodyMasses) = ((ms.m3+ms.m1)^2, (ms.m0-ms.m2)^2)
lims3(ms::ThreeBodyMasses) = ((ms.m1+ms.m2)^2, (ms.m0-ms.m3)^2)
#
import Base: getindex, ^, length
^(ms::ThreeBodyMasses,i::Int) = SVector(ms.m1,ms.m2,ms.m3,ms.m0).^i
# 
function getindex(ms::ThreeBodyMasses, i::Int)
    i==1 && return ms.m1
    i==2 && return ms.m2
    i==3 && return ms.m3
    i==4 && return ms.m0
end
nt(ms::ThreeBodyMasses) = NamedTuple{(:m0,m1,:m2,:m3)}([ms.m0,ms.m1,ms.m2,ms.m3])
#
import Base: iterate
# 
iterate(ms::ThreeBodyMasses) = iterate(SVector(ms.m1,ms.m2,ms.m3,ms.m0))
iterate(ms::ThreeBodyMasses, state) = iterate(SVector(ms.m1,ms.m2,ms.m3,ms.m0),state)
# 
@with_kw struct ThreeBodySpins
    two_h1::Int
    two_h2::Int
    two_h3::Int
    two_h0::Int
end
function getindex(two_hs::ThreeBodySpins, i::Int)
    i==1 && return two_hs.two_h1
    i==2 && return two_hs.two_h2
    i==3 && return two_hs.two_h3
    i==4 && return two_hs.two_h0
end
length(σs::ThreeBodySpins) = 4
iterate(two_hs::ThreeBodySpins)        = iterate(SVector(two_hs.two_h1,two_hs.two_h2,two_hs.two_h3,two_hs.two_h0))
iterate(two_hs::ThreeBodySpins, state) = iterate(SVector(two_hs.two_h1,two_hs.two_h2,two_hs.two_h3,two_hs.two_h0),state)
# 
# 
@with_kw struct ThreeBodySystem
    ms::ThreeBodyMasses
    two_js::ThreeBodySpins
end
# 
ThreeBodySystem(m0,m1,m2,m3; two_js = [0,0,0,0]) =
    ThreeBodySystem(ThreeBodyMasses(m0=m0,m1=m1,m2=m2,m3=m3),
                    ThreeBodySpins(two_js...));
#

# Dynamic variables
@with_kw struct Invariants
    σ1::Float64
    σ2::Float64
    σ3::Float64
end
function Invariants(ms::ThreeBodyMasses;σ1=-1.0,σ2=-1.0,σ3=-1.0)
    sign(σ1)+sign(σ2)+sign(σ3)!=1 && error("the method works with TWO invariants given: $((σ1,σ2,σ3))")
    σ3 < 0 && return Invariants(;σ1,σ2,σ3=sum(ms^2)-σ1-σ2)
    σ1 < 0 && return Invariants(;σ2,σ3,σ1=sum(ms^2)-σ2-σ3)
    σ2 < 0 && return Invariants(;σ3,σ1,σ2=sum(ms^2)-σ3-σ1)
end
# 
length(σs::Invariants) = 3
function getindex(σs::Invariants, i::Int)
    i==1 && return σs.σ1
    i==2 && return σs.σ2
    i==3 && return σs.σ3
end
nt(σs::Invariants) = NamedTuple{(:σ1,:σ2,:σ3)}([σs.σ1,σs.σ2,σs.σ3])
 
@with_kw struct DalitzPlotPoint
    σs::Invariants
    two_λs::SVector{4,Int}
end
#
function randomPoint(ms::ThreeBodyMasses)
    σ1 = lims1(ms)[1] + rand()* (lims1(ms)[2]-lims1(ms)[1])
    σ3 = σ3of1(2rand()-1, σ1, ms^2)
    return Invariants(ms;σ1=σ1,σ3=σ3);
end

function randomPoint(tbs::ThreeBodySystem)
    DalitzPlotPoint(σs=randomPoint(tbs.ms),
        two_λs=[rand(-j:2:j) for j in tbs.two_js])
end

function possible_helicities(two_js::ThreeBodySpins)
    @unpack two_h0, two_h1, two_h2, two_h3 = two_js
    [ThreeBodySpins(two_λs...) for two_λs =
        Iterators.product(
            -two_h0:2:two_h0,
            -two_h1:2:two_h1,
            -two_h2:2:two_h2,
            -two_h3:2:two_h3)]
end

# dealing with spin 1/2
x2(v) = Int(2v)


#                                                                _|
#    _|_|_|    _|_|    _|_|_|      _|_|    _|  _|_|    _|_|_|  _|_|_|_|    _|_|
#  _|    _|  _|_|_|_|  _|    _|  _|_|_|_|  _|_|      _|    _|    _|      _|_|_|_|
#  _|    _|  _|        _|    _|  _|        _|        _|    _|    _|      _|
#    _|_|_|    _|_|_|  _|    _|    _|_|_|  _|          _|_|_|      _|_|    _|_|_|
#        _|
#    _|_|

function border(k, ms::ThreeBodyMasses; Nx::Int=300)
    (i,j) = ij_from_k(k)
    σiv = range(lims(i,ms)..., length=Nx)
    σkm = [σkofi(k,-1.0,σi,ms^2) for σi in σiv]
    σkp = [σkofi(k, 1.0,σi,ms^2) for σi in σiv]
    return (σiv, [σkm σkp])
end
#
border31(ms; Nx::Int=300) = border(3, ms; Nx=Nx)
border12(ms; Nx::Int=300) = border(1, ms; Nx=Nx)
border23(ms; Nx::Int=300) = border(2, ms; Nx=Nx)
# 
function flatDalitzPlotSample(ms::ThreeBodyMasses; Nev::Int=10000, σbins::Int=500)
    @unpack m0,m1,m2,m3 = ms
    density = getbinned1dDensity(σ1->sqrt(λ(σ1,m2^2,m3^2)*λ(σ1,m0^2,m1^2))/σ1, lims1(ms), σbins)
    σ1v = [rand(density) for _ in 1:Nev]
    σ3v = [σ3of1(2*rand()-1,σ1,ms^2) for σ1 in σ1v]
    return [Invariants(ms; σ1=σ1, σ3=σ3) for (σ1,σ3) in zip(σ1v,σ3v)]
end

#
inrange(x,r) = r[1]<x<r[2]
inphrange(σs::Invariants, ms::ThreeBodyMasses) = Kibble(σs,ms^2) < 0 &&
    inrange(σ1,lims1(ms)) && inrange(σ2,lims2(ms)) && inrange(σ3,lims3(ms))
# 
# 
change_basis_3from1(τ1, ms::ThreeBodyMasses) = change_basis_3from1(τ1..., ms.m1^2, ms.m2^2, ms.m3^2, ms.m0^2) 
change_basis_1from2(τ2, ms::ThreeBodyMasses) = change_basis_3from1(τ2..., ms.m2^2, ms.m3^2, ms.m1^2, ms.m0^2) 
change_basis_2from3(τ3, ms::ThreeBodyMasses) = change_basis_3from1(τ3..., ms.m3^2, ms.m1^2, ms.m2^2, ms.m0^2) 

# coupling scheme
coupling_schemek(k,two_jp,tbs::ThreeBodySystem) = coupling_schemek(k,two_jp,collect(zip(tbs.two_js,tbs.Ps)))
coupling_scheme23(two_jp,tbs::ThreeBodySystem)  = coupling_schemek(1,two_jp,tbs)
coupling_scheme12(two_jp,tbs::ThreeBodySystem)  = coupling_schemek(3,two_jp,tbs)
coupling_scheme31(two_jp,tbs::ThreeBodySystem)  = coupling_schemek(2,two_jp,tbs)
