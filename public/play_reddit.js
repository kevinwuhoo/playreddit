var currSong = "";

function load_song (key) {
	
	if (key in music) {

		swfobject.removeSWF("player");

		var newdiv = document.createElement('div');
		newdiv.setAttribute('id',"player_div");
		newdiv.innerHTML = '';
		document.getElementById("right_top_panel").appendChild(newdiv);

		if (music[key][1]) {

			$('#right_top_panel').css('padding-top', '5px');
			$('#right_top_panel').css('height', '400px');

			// Youtube
			yt_id = music[key][0];
			var params = { allowScriptAccess: "always" };
			var atts = { id: "player" };
			swfobject.embedSWF("http://www.youtube.com/e/" + yt_id + "?enablejsapi=1&playerapiid=ytplayer&autoplay=1",
			"player_div", "600", "390", "8", null, null, params, atts);

		} else {

			$('#right_top_panel').css('padding-top', '155px');
			$('#right_top_panel').css('height', '250px');

			// Soundcloud 
			var flashvars = {
				enable_api: true, 
				object_id: "myPlayer",
				url: music[key][0],
				auto_play: true
			};
			var params = {
				allowscriptaccess: "always"
			};
			var attributes = {
				id: "player",
				name: "player"
			};
			swfobject.embedSWF("http://player.soundcloud.com/player.swf", "player_div", "600", "81", "9.0.0",
			"expressInstall.swf", flashvars, params, attributes);

			soundcloud.addEventListener('onMediaEnd', function(player, data) {
				load_next();
			});
		}
		
	} else {
		//alert("key not in array");
	}
	
}

function load_next() {
	load_song(currSong.next().html());
	currSong = currSong.next();
}

function load_prev() {
	load_song(currSong.prev().html());
	currSong = currSong.prev();
}

function youtubePlayNext(newState) {
	 if (newState === 0)
		load_next();
}

function onYouTubePlayerReady(playerId) {
  ytplayer = document.getElementById("player");
  ytplayer.addEventListener("onStateChange", "youtubePlayNext");
}

$(function() {

	$( "#prev" ).button({
		text: false,
		icons: {
			primary: "ui-icon-seek-start"
		}
	})
	.click(function(){load_prev()});

	$("#play").button({
		text: false,
		icons: {
			primary: "ui-icon-play"
		}
	})
	.click(function() {
		var options;
		if ( $( this ).text() === "play" ) {
			options = {
				label: "pause",
				icons: {
					primary: "ui-icon-pause"
				}
			};
			//document.getElementById("player").playVideo();
		} else {
			options = {
				label: "play",
				icons: {
					primary: "ui-icon-play"
				}
			};
		}
		$( this ).button( "option", options );
		//document.getElementById("myytplayer").pauseVideo();
	});

	$( "#next" ).button({
		text: false,
		icons: {
			primary: "ui-icon-seek-end"
		}
	})
	.click(function(){load_next()});

	$('#left_panel').jScrollPane();

	$("#song_list li").click(function() {

		currSong = $(this);
		load_song($(this).text());
		
	});


});