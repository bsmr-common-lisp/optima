(in-package :optima)

(defmacro %or (&rest forms)
  "Similar to OR except %OR also allows to call (FAIL) in each branch
to jump to its next branch."
  (setq forms (remove '(fail) forms :test #'equal))
  (cond ((null forms)
         '(fail))
        ((null (rest forms))
         (first forms))
        ((self-evaluating-object-p (first forms))
         (first forms))
        (t
         (let ((block (gensym "BLOCK")))
           `(block ,block
              (tagbody
                 ,@(loop for form in (butlast forms)
                         for tag = (gensym "FAIL")
                         collect `(return-from ,block
                                    (macrolet ((fail () `(go ,',tag)))
                                      ,form))
                         collect tag)
                 (return-from ,block ,(car (last forms)))))))))

(defmacro %if (test then else)
  "Similar to IF except %IF also allows to call (FAIL) in THEN branch
to jump to ELSE branch."
  `(%or (if ,test ,then (fail)) ,else))

(defmacro fail ()
  "Causes the latest pattern matching be failed and continue to do the
rest of pattern matching."
  (error "Not pattern matching."))
