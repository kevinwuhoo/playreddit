music = null
song = null

loadSong = (key) -> 

  if music[key]?

    song = music[key]

    swfobject.removeSWF "player"

    newdiv = document.createElement 'div'
    newdiv.setAttribute 'id',"player_div"
    newdiv.innerHTML = ''
    document.getElementById("video").appendChild(newdiv)

    height = $(window).height()
    # (window height) - (header height) - (header margins) - (footer height)
    # - (footer bottom margin) - (footer top margin) - 10
    player_height = height - 50 - 20 - 50 - 2 - 10
    # player_height = (String) player_height

    width = $(window).width()
    # ((window width) * 66%) - (header left margin) - (right margin)
    player_width = (width * 0.66) - 10 - 10
    player_width = (String) player_width

    if song['ytid']

      player_height = (String) player_height

      # Youtube
      ytid = song['ytid']
      params = allowScriptAccess: "always"
      atts = id: "player"
      swfobject.embedSWF "http://www.youtube.com/e/" + ytid + "?enablejsapi=1&playerapiid=ytplayer&autoplay=1",
      "player_div", player_width, player_height, "8", null, null, params, atts

      # Add appropriate youtube padding
      $('#video').css "top", "70px"
      $('#video').css "left", "10px"

    else

      # Soundcloud 
      flashvars =
        enable_api: true
        object_id: "player"
        url: song['url']
        auto_play: true            # Soudncloud auto-play
      
      params = 
        allowscriptaccess: "always"
      
      attributes = 
        id: "player"
        name: "player"
      
      swfobject.embedSWF "http://player.soundcloud.com/player.swf", 
      "player_div", player_width, "81", "9.0.0",
      "expressInstall.swf", flashvars, params, attributes

      # Soundcloud auto-advance
      soundcloud.addEventListener 'onMediaEnd', (player, data) -> 
        loadNext()

      soundcloud.addEventListener 'onPlayerError', (player, data) ->
        loadNext()

      soundcloud.addEventListener 'onMediaPause', (player, data) ->
        showPlay()

      soundcloud.addEventListener 'onMediaPlay', (player, data) ->
        showPause()

      soundcloud.addEventListener 'onMediaStart', (player, data) ->
        showPause()

      top_margin = (player_height / 2 + 70) + "px"
    
      # Add appropriate soundcloud padding
      $('#video').css "top", top_margin
      $('#video').css "left", "10px"

  # else
    # console.log "key not in array"

loadNext = ->
  nextSong = $('.selected').next()
  $('.selected').toggleClass("selected")
  nextSong.toggleClass("selected")
  loadSong(nextSong.text()) 

window.loadNext = loadNext

loadPrev = ->
  prevSong = $('.selected').prev()
  $('.selected').toggleClass("selected")
  prevSong.toggleClass("selected")
  loadSong(prevSong.text()) 

# Youtube auto-advance on finish
window.youtubePlayNext = (newState) ->
  # console.log("youtube says " + newState)
  if newState is 0 then loadNext()
  # music is playing
  if newState is 1 then showPause()
  # music is paused
  if newState is 2 then showPlay() 

# Youtube auto-play
window.onYouTubePlayerReady = (playerId) ->
  ytplayer = document.getElementById "player"
  ytplayer.addEventListener "onStateChange", "youtubePlayNext"
  ytplayer.addEventListener "onError", "loadNext"

showPause = ->
  $('#play').hide()
  $('#pause').show()

showPlay = ->
  $('#play').show()
  $('#pause').hide()

$ ->
  # Scrape reddit by using query string in url
  url = window.location.href
  if url.indexOf("?") != -1
    query = url.substring(url.indexOf("?") + 1, url.length)
    # console.log(query)
    $.ajax "/scrape?r=#{query}",
      dataType:'json'
      async: false
      success: (data) -> 
        music = data

    for title, data of music
      $("#playlist").append("<li>#{title}</li>")

    # Autoplay first song  
    $('#play').hide()
    loadSong($('#playlist li:first-child').text())
    $('#playlist li:first-child').toggleClass("selected")

  # Current Song Highlighting
  $("ul#playlist li").click ->
    $("ul#playlist li.selected").toggleClass("selected")
    $(@).toggleClass("selected")
    loadSong $(this).text()

  # Footer Nav Controls
  $("#next").click ->
    loadNext()

  $("#prev").click ->
    loadPrev()

  $("#play").click ->
    if song['ytid']
      ytplayer = document.getElementById "player"
      ytplayer.playVideo()
    else
      scplayer = soundcloud.getPlayer 'player'
      scplayer.api_play()

  $("#pause").click ->
    if song['ytid']
      ytplayer = document.getElementById "player"
      ytplayer.pauseVideo()
    else
      scplayer = soundcloud.getPlayer 'player'
      scplayer.api_pause()

  # <--------------- landing page js ------------------>
  subreddits = []
  addSubreddit = (subreddit) ->
    subreddits.push(subreddit)
    $("#subreddits").html(subreddits.join(", "))
    $("#playthem").show()

  $("#subreddit_input").keypress (event) ->
    if event.which is 13
      addSubreddit($(@).val())
      $(@).val("")

  $("td").click ->
    addSubreddit($(@).html())

  $("#playthem").click ->
    redirect = window.location.href
    subreddits = subreddits.join(",")
    redirect += "?" + subreddits
    window.location.href = redirect
  # <------------- end landing page js ----------------->
