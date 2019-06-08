(import (chicken condition)
        (chicken memory)
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

(define +title+ "sdl2")
(define +screen-width+ 100)
(define +screen-height+ 100)
(define +screen-pixels+ (* +screen-width+ +screen-height+))

(define-values (*window* *renderer*)
  (sdl2:create-window-and-renderer!
    +screen-width+ +screen-height+))

(set! (sdl2:window-title *window*) +title+)

(set! (sdl2:render-viewport *renderer*)
  (sdl2:make-rect 0 0 +screen-width+ +screen-height+))

(define +texture+
  (sdl2:create-texture *renderer* 'rgb888 'streaming
                       +screen-width+ +screen-height+))

(define +pixels+ (allocate (* 3 +screen-pixels+)))

(define (handle-event ev exit-main-loop!)
  (case (sdl2:event-type ev)
    ((quit)
     (exit-main-loop! #t))
    ((key-down)
     (case (sdl2:keyboard-event-sym ev)
       ((escape)
        (exit-main-loop! #t))))))

(define (main-loop)
  (let/cc exit-main-loop!
    (while #t
      (sdl2:pump-events!)
      (while (sdl2:has-events?)
        (handle-event (sdl2:poll-event!) exit-main-loop!))

      (sdl2:update-texture-raw! +texture+ #f (object->pointer +pixels+) (* +screen-width+ 3))
      (sdl2:render-copy! *renderer* +texture+)

      (sdl2:render-present! *renderer*)
      (sdl2:delay! 30))))

(main-loop)
(free +pixels+)

