(define (lfringe-prepare-draft-text-box e)
  (stitch-prepare-draft-text-box (e.findElement ".lfringe")))

(define-menu lfringe 
  `("Make Text Annotation" ,lfringe-prepare-draft-text-box)
  )
