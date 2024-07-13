#lang nanopass

;;(require compatibility/defmacro)
(require pprint-all)
(require javascript)
(require "./js.rkt")

(provide L0
         parse-L0
         L1
         pass1
         language->s-expression)

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define-language L0
  (terminals
   (number (%num))
   (string (%str))
   (symbol (%sym))
   (primitive (%pr))
   )
  (Expr (%e %body)
        %c
        %v
        (begin %e* ... %e)
        (vector %e* ...)
        (define %v %e)
        (print %cv)
        )
  (ConstantOrVariable
   (%cv)
   %v
   %c
   )
  (Constant
   (%c)
   %num
   %str
   )
  (Variable
   (%v)
   %sym
   )
  )

;; (define primitive?
;;   (lambda (x)
;;     (memq x '(+ - * / cons car cdr pair? vector make-vector vector-length
;;               vector-ref vector-set! vector? string make-string
;;               string-length string-ref string-set! string? void))))

;; (define constant?
;;   (lambda (x)
;;     (or (number? x)
;;         (string? x))))

(define-parser parse-L0 L0)

(define-language L1
  (extends L0)
  (terminals
   (+
    (symbol-name (%sn))
    )
   )
  (Expr
   (%e %body)
   (+
    (:js-program %e* ... %e)
    (:vector %e* ...)
    (:js-let %v %e)
    (:js-console.log %cv)
    )
   )
  (ConstantOrVariable
   (%cv)
   (+
    ;;(:variable %sn)
    (:constant %c)
    )
   )
  (Variable
   (%v)
   (+
    (:variable %sn)
    )
   )
  )

(define (symbol-name? x)
  (string? x)
  )

(define-pass pass1 : L0 (ir) -> L1 ()
  (Expr : Expr (ir) -> Expr ()
        [(begin ,[%e*] ... ,[%e]) `(:js-program ,%e* ... ,%e)]
        [(vector ,[%e*] ...) `(:vector ,%e* ...)]
        [(define ,[%v] ,[%e]) `(:js-let ,%v ,%e)]
        [(print ,[%cv]) `(:js-console.log ,%cv)]
        )
  (ConstantOrVariable : ConstantOrVariable (ir) -> ConstantOrVariable ()
                      [,%c `(:constant ,%c)]
                      )
  (Variable : Variable (ir) -> Variable ()
                      [,%sym `(:variable ,(symbol->string %sym))]
                      )
  )

(dump (language->s-expression L0))

(dump (language->s-expression L1))

(define $input '(begin (print 123) (define x 777) (print x)))
(dump $input)

(define $p0 (parse-L0 $input))
(dump $p0)

(define $p1 (pass1 $p0))
(dump $p1)

(define $up1 (unparse-L1 $p1))

(dump $up1)
(dump (car $up1))
(dump '':js-program)

(define $js (eval $up1 ns))

(displayln $js)

(define $eval (eval-script $js))
(dump $eval)




(eval-script "print(40 + 2)")

(dump
 (format-term
  (parse-source-element
   $js))
 )
(displayln "")
(set! $input '(vector 111 x))
(set! $p0 (parse-L0 $input))
(dump $p0)
(set! $p1 (pass1 $p0))
(dump $p1)
