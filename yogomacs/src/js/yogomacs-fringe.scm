(define-menu lfringe 
  `("Make Text Annotation" ,(lambda (e) (stitch-prepare-draft-text-box (e.findElement ".lfringe"))))
  `("Leave a Footprint" ,(lambda (e) e))
  )
