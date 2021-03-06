
struct jls
    two_j::Int
    two_l::Int
    two_s::Int
end

struct twochain
    to_isobar::jls
    from_isobar::jls
end

two_J(ch::twochain) = ch.to_isobar.two_j
two_L(ch::twochain) = ch.to_isobar.two_l
two_S(ch::twochain) = ch.to_isobar.two_s
two_j(ch::twochain) = ch.from_isobar.two_j
two_l(ch::twochain) = ch.from_isobar.two_l
two_s(ch::twochain) = ch.from_isobar.two_s

function possibleLS(two_jp1,two_jp2,two_jp) # expects tuples
    two_ls = Vector{Tuple{Int,Int}}(undef,0)
    for two_s in abs(two_jp1[1]-two_jp2[1]):2:abs(two_jp1[1]+two_jp2[1])
        for two_l in abs(two_jp[1]-two_s):2:abs(two_jp[1]+two_s)
            if (two_jp1[2] == '+' ? 1 : -1) *
               (two_jp2[2] == '+' ? 1 : -1) *
               (two_jp[2]  == '+' ? 1 : -1) == (two_l % 4 == 2  ? -1 : 1)
                push!(two_ls, (two_l,two_s))
            end
        end
    end
    return two_ls
end

function coupling_schemek(k,two_jp,two_jps)
    (i,j) = ij_from_k(k)
    #
    # length(pls) != 1 && error("length(pls) = $(length(pls)) != 1 for the second decay: $(two_jp...)=>$(two_jps[2]...),$(two_jps[3]...). Check quantum numbers!");
    return [twochain(
                jls(two_jps[4][1],two_LS...),  # JLS
                jls(two_jp[1],two_ls...))  # jls
                    for two_LS in possibleLS(two_jp,two_jps[k],two_jps[4])
                    for two_ls in possibleLS(two_jps[i],two_jps[j],two_jp)]
end
coupling_scheme23(two_jp,two_jps) = coupling_schemek(1,two_jp,two_jps)
coupling_scheme12(two_jp,two_jps) = coupling_schemek(3,two_jp,two_jps)
coupling_scheme31(two_jp,two_jps) = coupling_schemek(2,two_jp,two_jps)

jls_coupling(two_j1, two_λ1, two_j2, two_λ2, two_j, two_l, two_s) =
    CG_doublearg(two_j1, two_λ1, two_j2, -two_λ2, two_s, two_λ1-two_λ2) *
        CG_doublearg(two_l, 0, two_s, two_λ1-two_λ2, two_j, two_λ1-two_λ2)

function clebsch_for_chaink(k, two_s_int, two_τ, chain, two_λs, two_js)
    (i,j) = ij_from_k(k)
    #
    v = 1.0;
    two_λi_λj = two_λs[i]-two_λs[j]
    v *= CG_doublearg(two_js[i],two_λs[i],two_js[j],-two_λs[j],two_s(chain),two_λi_λj) *
         CG_doublearg(two_l(chain),0,two_s(chain),two_λi_λj,two_s_int,two_λi_λj)
    #
    two_τ_λk = two_τ - two_λs[k]
    v *= CG_doublearg(two_s_int,two_τ,two_js[k],-two_λs[k],two_S(chain),two_τ_λk) *
         CG_doublearg(two_L(chain),0,two_S(chain),two_τ_λk,two_J(chain),two_τ_λk)
    return v
end

#(j1λ1j2λ2,JLS)
function HelicityRecoupling_doublearg(HLSpairs)
    v = 1.0;
    for p in HLSpairs
        (two_j1,two_λ1,two_j2,two_λ2) = p[1]
        (two_J,two_L,two_S) = p[2]
        two_λ1_λ2 = two_λ1-two_λ2
        v *= CG_doublearg(two_j1,two_λ1,two_j2,-two_λ2,two_S,two_λ1_λ2) *
             CG_doublearg(two_L,0,two_S,two_λ1_λ2,two_J,two_λ1_λ2)
    end
    return  v;
end
function HelicityRecoupling(HLSpairs)
    v = 1.0;
    for p in HLSpairs
        (j1,λ1,j2,λ2) = p[1]
        (J,L,S) = p[2]
        v *= CG_doublearg(2*j1,2*λ1,2*j2,-2*λ2,2*S,2*(λ1-λ2)) *
             CG_doublearg(2*L,0,2*S,2*(λ1-λ2),2*J,2*(λ1-λ2))
    end
    return  v;
end
