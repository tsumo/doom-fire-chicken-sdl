(import (chicken condition)
        (chicken memory)
        (rename (chicken random)
                (pseudo-random-integer random))
        (srfi 1)
        (prefix sdl2 sdl2:)
        miscmacros
        vector-lib)
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

(define-values (*window* *renderer*)
  (sdl2:create-window-and-renderer!
    +screen-width+ +screen-height+
    (if *fullscreen?* '(fullscreen) '())))

(set! (sdl2:window-title *window*) +title+)

(set! (sdl2:render-viewport *renderer*)
  (R 0 0 +screen-width+ +screen-height+))

(define +texture+
  (sdl2:create-texture *renderer* 'rgb888 'streaming
                       +screen-width+ +screen-height+))

(define +pixels+ (allocate +screen-pixels+))

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

(set! (sdl2:render-draw-color *renderer*) +white+)

(define (main-loop)
  (let/cc exit-main-loop!
	(while #t
	  (sdl2:pump-events!)
	  (while (sdl2:has-events?)
		(handle-event (sdl2:poll-event!) exit-main-loop!))

      ; (let* ((x (random 90))
      ;        (y (random 90))
      ;        (offset (+ (* x 3) (* +screen-width+ 3 y))))
      ;   (pointer-u8-set! (pointer+ +pixels+ (+ offset 0)) (random 256))
      ;   (pointer-u8-set! (pointer+ +pixels+ (+ offset 1)) (random 256))
      ;   (pointer-u8-set! (pointer+ +pixels+ (+ offset 2)) (random 256)))
      (sdl2:update-texture-raw! +texture+ #f (object->pointer +pixels+) (* +screen-width+ 3))
      (sdl2:render-copy! *renderer* +texture+)

	  (sdl2:render-present! *renderer*)
	  (sdl2:delay! 30))))

(main-loop)
(free +pixels+)

