from sympy import *
import sympy as sp
sp.init_printing(use_latex = "mathjax")
E, e1, e2, v, s1, s2, s3 = symbols("E \u03b5_{11} \u03b5_{22} \u03bd sigma_1 sigma_2 sigma_3")
Eq1 = Eq(e1, s1/E - v*s2/E -v*s3/E)
print(Eq1)
Eq1 = Eq1.subs({s1:-500, s2:-100, s3:-500, e1:-0.003})
print(Eq1)
Eq2 = Eq(e2, -v*s1/E + s2/E - v*s3/E)
print(Eq2)
Eq2 = Eq2.subs({s1:-500, s2:-100, s3:-500, e2:0.001})
print(Eq2)
Sol = solve((Eq1, Eq2), (E,v))
print("E = ", Sol[E])
print("\u03bd = ", Sol[v])