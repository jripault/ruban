class Ruban
  constructor: (@options = {}) ->
    @initOptions()
    @$sections = $('section').wrapAll('<div class="ruban"></div>')
    @$ruban    = $('.ruban').css('transition-duration', @options.transitionDuration)

    @checkHash()
    @highlight()
    @resize()
    @bind()

  initOptions: () ->
    @options.ratio              ?= 4/3
    @options.minPadding         ?= '0.4em'
    @options.transitionDuration ?= '1s'

  bind: ->
    @bindKeys()
    @bindGestures()
    @bindResize()
    @bindHashChange()

  bindKeys: ->
    key('right, down, space, return, j, l', @next)
    key('left, up, backspace, k, h', @prev)

  bindGestures: ->
    Hammer(document).on('swipeleft swipeup', @next)
    Hammer(document).on('swiperight swipedown', @prev)

  bindResize: ->
    $(window).resize(=>
      @resize()
      @go(@$current, force: true)
    )

  bindHashChange: ->
    $(window).on('hashchange', @checkHash)

  resize: ->
    [width, height] = [$(window).width(), $(window).height()]
    if width > height
      min = height
      paddingV = @options.minPadding
      @$sections.css(
        'font-size':      "#{min * 0.4}%"
        'padding-top':    paddingV,
        'padding-bottom': paddingV
      )
      height = @$current.height()
      paddingH = "#{(width - @options.ratio*height)/2}px"
      @$sections.css(
        'padding-left':  paddingH
        'padding-right': paddingH
      )
    else
      min = width
      paddingH = @options.minPadding
      @$sections.css(
        'font-size':      "#{min * 0.4}%"
        'padding-left':  paddingH,
        'padding-right': paddingH
      )
      width = @$current.width()
      paddingV = "#{(height - width/@options.ratio)/2}px"
      @$sections.css(
        'padding-top':    paddingV,
        'padding-bottom': paddingV
      )

  checkHash: =>
    hash = window.location.hash
    slide = hash.substr(2) || 1
    @go(slide)

  highlight: ->
    hljs.initHighlightingOnLoad()

  prev: =>
    if @hasSteps()
      @prevStep()
    else
      @prevSlide()

  prevSlide: ->
    $prev = @$current.prev('section')
    @go($prev)

  prevStep: ->
    @$steps.eq(@index).removeClass('step').fadeOut()
    $prev = @$steps.eq(--@index)
    unless @index < -1
      if $prev.is(':visible')
        $prev.addClass('step').trigger('step')
      else if @index > -1
        @prevStep()
    else
      @prevSlide()

  next: =>
    if @hasSteps()
      @nextStep()
    else
      @nextSlide()

  nextSlide: ->
    $next = @$current.next('section')
    @go($next)

  nextStep: ->
    @$steps.eq(@index).removeClass('step')
    $next = @$steps.eq(++@index)
    if $next.length
      $next.fadeIn().addClass('step').trigger('step')
    else
      @nextSlide()

  checkSteps: ($section) ->
    @$steps = $section.find('.steps').children()
    unless @$steps.length
      @$steps = $section.find('.step')

    @index = -1
    @$steps.hide()

  hasSteps: ->
    @$steps? and @$steps.length isnt 0

  find: (slide) ->
    if slide instanceof $
      slide
    else
      $section = $("##{slide}")
      if $section.length is 0
        $section = @$sections.eq(parseInt(slide) - 1)
      $section

  go: (slide = 1, options = {}) ->
    $section = @find(slide)

    if $section.length and (options.force or not $section.is(@$current))
      @checkSteps($section)
      window.location.hash = "/#{$section.attr('id') || $section.index() + 1}"
      y = $section.prevAll().map(->
        $(@).outerHeight()
      ).get().reduce((memo, height) ->
        memo + height
      , 0)
      @$ruban.css('transform', "translateY(-#{y}px)")

      @$current.removeClass('active').trigger('inactive') if @$current?
      $section.addClass('active').trigger('active')
      @$current = $section


window.Ruban = Ruban