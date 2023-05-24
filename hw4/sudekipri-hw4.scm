(define main-procedure
  (lambda (tripleList)
    (if (or (null? tripleList) (not (list? tripleList)))
        (error "ERROR305: the input should be a list full of triples")
        (if (check-triple? tripleList)
            (sort-area (filter-pythagorean (filter-triangle (sort-all-triples tripleList))))
            (error "ERROR305: the input should be a list full of triples")))))

(define check-triple?
  (lambda (tripleList)
    (cond ((null? tripleList) #t)
          ((and (check-length? (car tripleList) 3) (check-sides? (car tripleList)))
           (check-triple? (cdr tripleList)))
          (else #f))))

(define check-length?
  (lambda (inTriple count)
    (= (length inTriple) count)))

(define check-sides?
  (lambda (inTriple)
    (and (integer? (car inTriple)) (> (car inTriple) 0)
         (integer? (cadr inTriple)) (> (cadr inTriple) 0)
         (integer? (caddr inTriple)) (> (caddr inTriple) 0))))

(define sort-all-triples
  (lambda (tripleList)
    (my-map sort-triple tripleList)))

(define sort-triple
  (lambda (inTriple)
    (my-sort inTriple <)))

(define filter-triangle
  (lambda (tripleList)
    (my-filter (lambda (triple)
              (triangle? triple))
            tripleList)))

(define triangle?
  (lambda (triple)
    (and (< (car triple) (+ (cadr triple) (caddr triple)))
         (< (cadr triple) (+ (car triple) (caddr triple)))
         (< (caddr triple) (+ (car triple) (cadr triple))))))

(define filter-pythagorean
  (lambda (tripleList)
    (my-filter pythagorean-triangle? tripleList)))

(define pythagorean-triangle?
  (lambda (triple)
    (= (+ (expt (car triple) 2) (expt (cadr triple) 2)) (expt (caddr triple) 2))))

(define sort-area
  (lambda (tripleList)
    (my-sort tripleList (lambda (a b) (< (get-area a) (get-area b))))))

(define get-area
  (lambda (triple)
    (/ (* (car triple) (cadr triple)) 2)))

; Define my-map function
(define my-map
  (lambda (func lst)
    (if (null? lst)
        '()
        (cons (func (car lst)) (my-map func (cdr lst))))))

; Define my-filter function
(define my-filter
  (lambda (pred lst)
    (cond ((null? lst) '())
          ((pred (car lst)) (cons (car lst) (my-filter pred (cdr lst))))
          (else (my-filter pred (cdr lst))))))

; Define my-sort function
(define my-sort
  (lambda (lst pred)
    (if (null? lst)
        '()
        (insert (car lst) (my-sort (cdr lst) pred) pred))))

; Define helper function for my-sort
(define insert
  (lambda (elem lst pred)
    (if (null? lst)
        (list elem)
        (if (pred elem (car lst))
            (cons elem lst)
            (cons (car lst) (insert elem (cdr lst) pred))))))

(check-sides? '(3.4 4 5))
(check-triple? '((1 2 51.3) (3 4 5)))
(filter-triangle '((3 4 5) (2 4 -1)))
(check-triple? '((5 12 13) (3 4 5) (16 63 65) (12 35 37)))
(check-triple? '((5 3 9) (9 55 32) ('a 28 67)))
(check-triple? '((5 12 12) (6 6 6) ()))
(check-length? '(3 4 5) 4)
(check-sides? '(() 'c 3))
(check-sides? '(6 0 27))
(filter-triangle '((8 10 21) (22 31 53)))
(filter-pythagorean '((3 4 5) (13 18 30) (5 12 13) (8 8 8)))
