header {* Example usage of the ``sturm'' method *}
(* Author: Manuel Eberl <eberlm@in.tum.de> *)
theory Sturm_Ex
imports "../Sturm"
begin

text {*
  In this section, we give a variety of statements about real polynomials that can b
  proven by the \emph{sturm} method.
*}

lemma
 "\<forall>x::real. x^2 + 1 \<noteq> 0"
by sturm

lemma
  fixes x :: real
  shows "x^2 + 1 \<noteq> 0" by sturm

lemma "(x::real) > 1 \<Longrightarrow> x^3 > 1" by sturm

lemma "\<forall>x::real. x*x \<noteq> -1" by sturm

schematic_lemma A:
"card {x::real. -0.010831 < x \<and> x < 0.010831 \<and> 
    1/120*x^5 + 1/24 * x^4 +1/6*x^3 - 49/16777216*x^2 - 17/2097152*x = 0} 
  = ?n"
  by sturm

lemma "card {x::real. x^3 + x = 2*x^2 \<and> x^3 - 6*x^2 + 11*x = 6} = 1" 
by sturm



schematic_lemma "card {x::real. x^3 + x = 2*x^2 \<or> x^3 - 6*x^2 + 11*x = 6} = ?n" by sturm


lemma
  "card {x::real. -0.010831 < x \<and> x < 0.010831 \<and> 
     poly [:0, -17/2097152, -49/16777216, 1/6, 1/24, 1/120:] x = 0} = 3"
  by sturm

lemma "\<forall>x::real. x*x \<noteq> 0 \<or> x*x - 1 \<noteq> 2*x" by sturm

lemma "(x::real)*x+1 \<noteq> 0 \<and> (x^2+1)*(x^2+2) \<noteq> 0" by sturm

end