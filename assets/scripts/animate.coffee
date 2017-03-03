wheelTimeout = 4000
waterfallPreempt = 50

waterfall = () ->
  $(".waterfall").each((i) ->
    obj = $(this).offset().top
    win = $(window).scrollTop() + $(window).height()
    win -= waterfallPreempt
    if win > obj
      $(this).animate({ opacity: 1, top: 0 }, 1000)
  )

wheel = (curr) ->
  curr.animate(
    { opacity: 0, left: "-10em" },
    { duration: 500, "queue": false, done: () ->
      curr.hide()
      if curr.is($(".wheel").children().last())
        next = $(".wheel").children().first()
      else
        next = curr.next()
      next.show().css({ "opacity": "0", "left": "10em" }).animate(
        { opacity: 1, left: 0 },
        { duration: 500, "queue": false
        , done: setTimeout((() -> wheel(next)),wheelTimeout)}
      ) }
  )

$(document).ready(() ->
  waterfall()
  setTimeout((() -> wheel($(".wheel").children().first())), wheelTimeout)
  $(window).scroll(() -> waterfall())
)
