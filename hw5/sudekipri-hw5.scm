(define operator (lambda (op-symbol env) 
  (cond 
    ((equal? op-symbol '+) +)
    ((equal? op-symbol '-) -)
    ((equal? op-symbol '*) *)
    ((equal? op-symbol '/) /)
    (else  (display "cs305: ERROR \n\n") (repl env)))))

(define define-statement? (lambda (e)
    (and (list? e) (= (length e) 3) (equal? (car e) 'define) (symbol? (cadr e)))))

(define let-parameter? (lambda (e)
	(if (list? e)
		(if (null? e) 
			#t
			(if (= (length (car e)) 2)
				(let-parameter? (cdr e)) 
				#f
			)
		)
		#f
	)
))

(define cond-parameter? (lambda (e)
(if (null? e) #f
	(if (and (list? (car e)) (= (length (car e)) 2))
		(if (equal? (caar e) 'else)
			(if (null? (cdr e)) #t #f)
		       	(cond-parameter? (cdr e))
		)
		#f
	))
))

(define letstar-statement? (lambda (e)
	(and (list? e) (equal? (car e) 'let*) (= (length e) 3) (let-parameter? (cadr e)))))

(define let-statement? (lambda (e)
	(and (list? e) (equal? (car e) 'let) (= (length e) 3) (let-parameter? (cadr e)))))

(define if-statement? (lambda (e)
	(and (list? e) (equal? (car e) 'if) (= (length e) 4))))

(define cond-statement? (lambda (e)
	(and (list? e) (equal? (car e) 'cond) (> (length e) 2) (cond-parameter? (cdr e)))))

(define get-value (lambda (var old-env new-env)
    (cond
      ((null? new-env) (display "cs305: ERROR \n\n") (repl old-env))

      ((equal? (caar new-env) var) (cdar new-env))

      (else (get-value var old-env (cdr new-env))))))

(define extend-env (lambda (var val old-env)
      (cons (cons var val) old-env)))

(define repl (lambda (env)
  (let* (
         (dummy1 (display "cs305> "))

         (expr (read))

	 (dummy1.5 (newline))

         (new-env (if (define-statement? expr)
                      (extend-env (cadr expr) (s7-interpret (caddr expr) env) env)
                      env))

         (val (if (define-statement? expr)
                  (cadr expr)
                  (s7-interpret expr env)))

         (dummy2 (display "cs305: "))
         (dummy3 (display val))

         (dummy4 (newline))
         (dummy4 (newline)))
     (repl new-env))))

(define s7-interpret (lambda (e env)
  (cond 
    ((number? e) e)

    ((symbol? e) (get-value e env env))

    ((not (list? e)) 
	(display "cs305: ERROR \n\n") (repl env) )

    ((null? e) e)

    ((if-statement? e) (if (eq? (s7-interpret (cadr e) env) 0)
            ( s7-interpret (cadddr e) env)
                ( s7-interpret (caddr e) env)))
  
    ((cond-statement? e) 
	(if (eq? (length e) 3) 
		(if (eq? (s7-interpret (caadr e) env) 0) (s7-interpret (car (cdaddr e)) env)
		(s7-interpret (cadadr e) env))
		(let ((if-cond  (caadr e)) (then (cadadr e)) (else-part (cons 'cond (cddr e))) ) 
			(let ((c (list 'if if-cond then else-part))) (s7-interpret c env)))))

    ((let-statement? e)
      (let ((names (map car  (cadr e)))
            (exprs (map cadr (cadr e))))
           (let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
           	(let ((new-env (append (map cons names vals) env)))
            	(s7-interpret (caddr e) new-env)))))

    ((letstar-statement? e) (if (<= (length (cadr e)) 1)
			 (let ((l (list 'let (cadr e) (caddr e))))   
			    (let ((names (map car  (cadr e)))
	            		(exprs (map cadr (cadr e))))
        	   		(let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
                		(let ((new-env (append (map cons names vals) env)))
                		(s7-interpret (caddr e) new-env)))))
			(let ((first (list 'let (list (caadr e)))) (rest (list 'let* (cdadr e) (caddr e))))
     								(let ((l (append first (list rest)))) (let ((names (map car (cadr l))) (inits (map cadr (cadr l))))
     									(let ((vals (map (lambda (init) (s7-interpret init env)) inits)))
     										(let ((new-env (append (map cons names vals) env)))
												(s7-interpret (caddr l) new-env))))))
			))
			 
    (else 
       (let ((operands (map s7-interpret (cdr e) (make-list (length (cdr e)) env)))
             (operator (operator (car e) env)))

         (apply operator operands))))))

(define cs305 (lambda () (repl '())))
