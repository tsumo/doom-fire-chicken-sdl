(import (chicken condition)
        (chicken memory)
        (rename (chicken random)
                (pseudo-random-integer random))
        (srfi 1)
        (srfi 4)
        (prefix sdl2 sdl2:)
        miscmacros)
(declare (uses extras))

(sdl2:set-main-ready!)
(sdl2:init! '(video timer))

(on-exit sdl2:quit!)

(current-exception-handler
  (let ((original-handler (current-exception-handler)))
    (lambda (exception)
      (sdl2:quit!)
      (original-handler exception))))

(define C sdl2:make-color)
(define P sdl2:make-point)
(define R sdl2:make-rect)

(define +title+ "sdl2")
(define +screen-width+ 100)
(define +screen-height+ 100)
(define +screen-pixels+ (* +screen-width+ +screen-height+))

(define +white+ (C 255 255 255))
(define +black+ (C 0 0 0))

(define *fullscreen?* #f)

(define +palette+ #((102 37 6)
                    (128 45 5)
                    (153 54 4)
                    (178 64 3)
                    (201 78 5)
                    (219 94 11)
                    (234 113 21)
                    (244 133 31)
                    (251 153 44)
                    ; (254 174 61)
                    ; (254 194 84)
                    (254 211 112)
                    (254 225 141)
                    (255 225 141)
                    (255 237 166)
                    (255 245 188)
                    (255 251 208)
                    (255 255 229)))

(define +pixels+ (make-u8vector +screen-pixels+ 0))
(for-each (lambda (i)
            (u8vector-set! +pixels+ i 16))
          (iota +screen-width+ (* (- +screen-pixels+ +screen-width+))))

(define +fire-palette+ (sdl2:make-palette 16))
(for-each (lambda (i)
            (sdl2:palette-set! +fire-palette+ i (apply sdl2:make-color
                                                       (vector-ref +palette+ i))))
          (iota 16))

(define +fire-surf+ (sdl2:make-surface +screen-width+ +screen-height+ 8))
(sdl2:surface-palette-set! +fire-surf+ +fire-palette+)

(define-values (*window* *renderer*)
  (sdl2:create-window-and-renderer!
    +screen-width+ +screen-height+
    (if *fullscreen?* '(fullscreen) '())))

(set! (sdl2:window-title *window*) +title+)

(set! (sdl2:render-viewport *renderer*)
  (R 0 0 +screen-width+ +screen-height+))

(define (handle-event ev exit-main-loop!)
  (case (sdl2:event-type ev)
    ((quit)
     (exit-main-loop! #t))
    ((key-down)
     (case (sdl2:keyboard-event-sym ev)
       ((escape)
        (exit-main-loop! #t))))))

(set! (sdl2:render-draw-color *renderer*) +black+)
(sdl2:render-clear! *renderer*)

(define (fire-iter)
  (map (lambda (e i)
         (u8vector-set! +pixels+ i (max 0 (- (u8vector-ref +pixels+ (+ i +screen-width+)) 1))))
       (u8vector->list +pixels+) (iota (- +screen-pixels+ +screen-width+))))

(define (main-loop)
  (let/cc exit-main-loop!
    (while #t
      (sdl2:pump-events!)
      (while (sdl2:has-events?)
        (handle-event (sdl2:poll-event!) exit-main-loop!))

      (fire-iter)

      (move-memory! +pixels+ (sdl2:surface-pixels-raw +fire-surf+))
      (sdl2:blit-surface! +fire-surf+ #f (sdl2:window-surface *window*) #f)
      (sdl2:update-window-surface! *window*)

      (sdl2:delay! 30))))

(main-loop)

