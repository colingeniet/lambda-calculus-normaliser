{-# OPTIONS --safe --cubical #-}

module Evaluator.Weakening where


open import Library.Equality
open import Library.Sets
open import Syntax.Terms
open import Syntax.Terms.Weakening
open import Weakening.Variable
open import Value.Value
open import Value.Weakening
open import Value.Lemmas
open import NormalForm.NormalForm
open import NormalForm.Weakening
open import Evaluator.Evaluator


-- All computations can be weakened.
_+eval_ : {Γ Δ Θ : Con} {A : Ty} {u : Tm Θ A} {ρ : Env Δ Θ} {uρ : Val Δ A} →
          eval u > ρ ⇒ uρ → (σ : Wk Γ Δ) → eval u > (ρ +E σ)  ⇒ (uρ +V σ)
_+evals_ : {Γ Δ Θ Ψ : Con} {σ : Tms Θ Ψ} {ρ : Env Δ Θ} {σρ : Env Δ Ψ} →
          evals σ > ρ ⇒ σρ → (ν : Wk Γ Δ) → evals σ > (ρ +E ν)  ⇒ (σρ +E ν)
_+$_ : {Γ Δ : Con} {A B : Ty} {f : Val Δ (A ⟶ B)} {v : Val Δ A} {fv : Val Δ B} →
       f $ v ⇒ fv → (σ : Wk Γ Δ) → (f +V σ) $ (v +V σ) ⇒ (fv +V σ)

(eval[] cσ cu) +eval δ = eval[] (cσ +evals δ) (cu +eval δ)
(evalπ₂ {σρ = σρ} cσ) +eval δ =
  tr (λ x → eval _ > _ ⇒ x) (π₂+ {ρ = σρ} {σ = δ}) (evalπ₂ (cσ +evals δ))
(evallam u ρ) +eval δ = evallam u (ρ +E δ)
(evalapp {ρ = ρ} cf $fρ) +eval δ =
  evalapp (tr (λ ρ → eval _ > ρ ⇒ _) (π₁+ {ρ = ρ} ⁻¹) (cf +eval δ))
          (tr (λ v → _ $ v ⇒ _) (π₂+ {ρ = ρ} ⁻¹) ($fρ +$ δ))
(isPropeval x y i) +eval δ = isPropeval (x +eval δ) (y +eval δ) i

evalsid +evals δ = evalsid
(evals∘ cν cσ) +evals δ = evals∘ (cν +evals δ) (cσ +evals δ)
evalsε +evals δ = evalsε
(evals, cσ cu) +evals δ = evals, (cσ +evals δ) (cu +eval δ)
(evalsπ₁ {σρ = σρ} cσ) +evals δ =
  tr (λ x → evals _ > _ ⇒ x) (π₁+ {ρ = σρ} {σ = δ}) (evalsπ₁ (cσ +evals δ))
(isPropevals x y i) +evals δ = isPropevals (x +evals δ) (y +evals δ) i

($lam cu) +$ σ = $lam (cu +eval σ)
($app n v) +$ σ = $app (n +NV σ) (v +V σ)
(isProp$ x y i) +$ σ = isProp$ (x +$ σ) (y +$ σ) i



_+q_ : {Γ Δ : Con} {A : Ty} {v : Val Δ A} {n : Nf Δ A} →
       q v ⇒ n → (σ : Wk Γ Δ) → q (v +V σ) ⇒ (n +N σ)
_+qs_ : {Γ Δ : Con} {A : Ty} {v : NV Δ A} {n : NN Δ A} →
        qs v ⇒ n → (σ : Wk Γ Δ) → qs (v +NV σ) ⇒ (n +NN σ)
(qo qv) +q δ = qo (qv +qs δ)
(q⟶ {A = A} {f = f} {fz = fz} $f qf) +q δ =
  let $f+ : ((f +V (wkwk A idw)) +V (wk↑ A δ))
            $ (neu (var z))
            ⇒ (fz +V (wk↑ A δ))
      $f+ = $f +$ (wk↑ A δ)
      p : (f +V wkwk A idw) +V wk↑ A δ
          ≡ (f +V δ) +V wkwk A idw
      p = (f +V wkwk A idw) +V wk↑ A δ     ≡⟨ +V∘ {v = f} ⁻¹ ⟩
          f +V ((wkwk A idw) ∘w (wk↑ A δ)) ≡⟨ ap (λ x → f +V x) wkid∘↑ ⟩
          f +V (δ ∘w (wkwk A idw))         ≡⟨ +V∘ {v = f} ⟩
          (f +V δ) +V (wkwk A idw)         ∎
      $f+' : ((f +V δ) +V (wkwk A idw))
             $ (neu (var z))
             ⇒ (fz +V (wk↑ A δ))
      $f+' = tr (λ x → x $ _ ⇒ _) p $f+
  in q⟶ $f+' (qf +q (wk↑ A δ))
(isPropq x y i) +q δ = isPropq (x +q δ) (y +q δ) i
qsvar +qs δ = qsvar
(qsapp qsf qv) +qs δ = qsapp (qsf +qs δ) (qv +q δ)
(isPropqs x y i) +qs δ = isPropqs (x +qs δ) (y +qs δ) i
