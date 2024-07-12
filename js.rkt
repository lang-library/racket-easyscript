#lang racket

(provide :js-program :js-console.log :constant :js-let :variable)

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define (:js-program . $rest)
  (let* ([$result ""])
    (for ([$x $rest])
      (set! $result
            (string-append-immutable $result (eval $x) ";"))
      )
    (format "{~a}" $result)
    )
  )

(define (:js-console.log $x)
  (format "print(~a)" (eval $x))
  )

(define (:constant $x)
  (format "~s" $x)
  )

(define (:js-let $var $val)
  (format "var ~a=(~a)" (eval $var) (eval $val))
  )

(define (:variable $x)
  $x
  )
