#lang rosette

(require
  (for-syntax
    (only-in racket/syntax format-id))
  "../base.rkt"
  "../decode.rkt")

(provide define-insn)

; The main macro for defining instructions.

(define-syntax (define-insn stx)
  (syntax-case stx ()
    [(_ (arg ...) #:encode encode [(field ...) op interp] ...)
     #'(begin
         (struct op (arg ...)
          #:transparent
          #:guard (lambda (arg ... name)
                    (values
                      ; split for type checking
                      (for/all ([arg arg #:exhaustive])
                        (guard arg)
                        arg) ...))
          #:methods gen:instruction
          [(define (instruction-encode insn)
             (define lst
               (match-let ([(op arg ...) insn])
                 ((lambda (arg ...) (encode field ...)) arg ...)))
             (apply concat (map (lambda (x) (if (box? x) (unbox x) x)) lst)))
           (define (instruction-run insn cpu)
             (match-let ([(op arg ...) insn])
               (interp cpu insn arg ...)))]) ...
         (add-decoder op
           ((lambda (arg ...) (encode field ...)) (typeof arg) ...))
         ... )]))

; Type checking guards.

(define-syntax-rule (guard v)
  (let ([type (typeof v)])
    (define expr
      (cond
        [(box? type)
         (set! type (unbox type))
         (and (box? v) (type (unbox v)))]
        [else
         (type v)]))
    (assert expr (format "~a: expected type ~a" v type))))

(define-syntax (typeof stx)
  (syntax-case stx ()
    [(_ arg)
     (with-syntax ([type (format-id stx "typeof-~a" (syntax-e #'arg))])
       #'type)]))

(define typeof-aq (bitvector 1))
(define typeof-csr (bitvector 12))
(define typeof-fm (bitvector 4))
(define typeof-funct3 (bitvector 3))
(define typeof-funct6 (bitvector 6))
(define typeof-funct7 (bitvector 7))
(define typeof-imm11:0 (bitvector 12))
(define typeof-imm11:5 (bitvector 7))
(define typeof-imm12&10:5 (bitvector 7))
(define typeof-imm20&10:1&11&19:12 (bitvector 20))
(define typeof-imm31:12 (bitvector 20))
(define typeof-imm4:0 (bitvector 5))
(define typeof-imm4:1&11 (bitvector 5))
(define typeof-opcode (bitvector 7))
(define typeof-pred (bitvector 4))
(define typeof-rd (bitvector 5))
(define typeof-rl (bitvector 1))
(define typeof-rs1 (bitvector 5))
(define typeof-rs2 (bitvector 5))
(define typeof-shamt5 (bitvector 5))
(define typeof-shamt6 (bitvector 6))
(define typeof-succ (bitvector 4))
(define typeof-uimm (bitvector 5))