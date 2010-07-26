(define-module yogomacs.dests.ysh-dir
  (export ysh-dir-dest)
  (use yogomacs.reply)
  (use yogomacs.dests.file)
  )
(select-module yogomacs.dests.ysh-dir)

(define (ysh-dir-dest path params config)
  (let1 shtml '(*TOP* (*PI* xml "version=\"1.0\" encoding=\"UTF-8\"") "\n" (*DECL* DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd") "\n" (*COMMENT* " Created by xhtmlize-1.34 in external-css mode. ") "\n" (html (|@| (xmlns "http://www.w3.org/1999/xhtml") (xml:lang "en") (lang "en")) "\n" (head "\n" "    " (title "/") "\n" "    " (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/ysh--Default.css") (title "Default"))) "\n" "    " (link (|@| (rel "stylesheet") (type "text/css") (href "file:///tmp/ysh--Invert.css") (title "Invert"))) "\n" "  ") "\n" "  " (body "\n" "    " (div (pre (|@| (class "header-line")))) "\n" (div "\n" "    " (pre (|@| (class "buffer")) "\n" (span (|@| (class "linum") (id "L:1")) (a (|@| (href "#L:1")) " 1")) (span (|@| (class "lfringe") (id "f:L;P:1;L:1")) " ") (span (|@| (class "rfringe") (id "f:R;L:1")) " ") (span (|@| (class "comment-delimiter") (id "F:1")) "/* ") (span (|@| (class "comment") (id "F:4")) "Assembly code template for system call stubs.\n")) "\n") "\n" (pre (|@| (class "modeline")) (span "/")) "\n" (form (|@| (class "minibuffer-shell")) (input (|@| (type "text") (id "minibuffer") (class "minibuffer")))) "\n" (pre (|@| (class "minibuffer-prompt-shell")) (span (|@| (id "prompt") (class "minibuffer-prompt")) " <ysh")) "\n" "  ") "\n") "\n")
    (make <shtml-data>
      :params params
      :config config
      :data ((compose fix-css-href integrate-file-face) shtml)
      :last-modification-time #f) 
    ))
(provide "yogomacs/dests/ysh-dir")