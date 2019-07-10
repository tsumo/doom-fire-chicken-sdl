(import (chicken condition)
        (chicken memory)
        (rename (chicken random)
                (pseudo-random-integer random))
        (srfi 1)
        (srfi 4)
        (prefix sdl2 sdl2:)
        miscmacros)

(sdl2:set-main-ready!)
(sdl2:init! '(video timer))

(on-exit sdl2:quit!)

(current-exception-handler
  (let ((original-handler (current-exception-handler)))
    (lambda (exception)
      (sdl2:quit!)
      (original-handler exception))))

(define +screen-width+ 200)
(define +screen-height+ 50)
(define +screen-pixels+ (* +screen-width+ +screen-height+))

(define *fullscreen?* #f)

(define +palette+
  (apply vector
         (map (lambda (color) (apply sdl2:make-color color))
              '((0 0 0)
                (102 37 6)
                (128 45 5)
                (153 54 4)
                (178 64 3)
                (201 78 5)
                (219 94 11)
                (234 113 21)
                (244 133 31)
                (251 153 44)
                (254 174 61)
                (254 194 84)
                (254 211 112)
                (254 225 141)
                (255 225 141)
                (255 237 166)))))

(define +pixels+ (make-u8vector +screen-pixels+ 0))
(for-each (lambda (i)
            (u8vector-set! +pixels+ i 15))
          (iota +screen-width+ (* (- +screen-pixels+ +screen-width+))))

(define +fire-palette+ (sdl2:make-palette 16))
(sdl2:palette-colors-set! +fire-palette+ +palette+)

(define +fire-surf+ (sdl2:make-surface +screen-width+ +screen-height+ 8))
(sdl2:surface-palette-set! +fire-surf+ +fire-palette+)

(define-values (*window* *renderer*)
  (sdl2:create-window-and-renderer!
    (* 4 +screen-width+) (* 4 +screen-height+)
    (if *fullscreen?* '(fullscreen) '())))

(define +32-surf+ (sdl2:make-surface +screen-width+ +screen-height+ 32))
(define +stretch-rect+ (sdl2:make-rect 0 0 (* 4 +screen-width+) (* 4 +screen-height+)))

(set! (sdl2:window-title *window*) "DOOM fire")

(set! (sdl2:render-viewport *renderer*)
  (sdl2:make-rect 0 0 +screen-width+ +screen-height+))

(define (handle-event ev exit-main-loop!)
  (case (sdl2:event-type ev)
    ((quit)
     (exit-main-loop! #t))
    ((key-down)
     (case (sdl2:keyboard-event-sym ev)
       ((escape)
        (exit-main-loop! #t))))))

(define (fire-iter)
  (map (lambda (e i)
         (let ((below (u8vector-ref +pixels+ (+ i +screen-width+))))
           (u8vector-set! +pixels+ (+ i (random 2)) (max 0 (+ (- below (random 2)))))))
       (u8vector->list +pixels+) (iota (- +screen-pixels+ +screen-width+))))

(define (main-loop)
  (let/cc exit-main-loop!
    (while #t
      (sdl2:pump-events!)
      (while (sdl2:has-events?)
        (handle-event (sdl2:poll-event!) exit-main-loop!))

      (fire-iter)

      (move-memory! +pixels+ (sdl2:surface-pixels-raw +fire-surf+))
      (sdl2:blit-surface! +fire-surf+ #f +32-surf+ #f)
      (sdl2:blit-scaled! +32-surf+ #f (sdl2:window-surface *window*) +stretch-rect+)
      (sdl2:update-window-surface! *window*)

      (sdl2:delay! 30))))

(main-loop)

