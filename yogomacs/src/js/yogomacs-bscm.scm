;;
;; Scheme2js -> Biwascheme
;;
(define (scm->scm bscm exp)
  (let1 str (write-to-string exp)
    (bscm.evaluate str)))

