(define-menu lfringe 
  `("Make Annotation" ,(lambda (e) (stitch-prepare-text-box (e.findElement ".lfringe"))))
  `("Leave a Footprint" ,(lambda (e) e))
  )
