$(function() {

	$( "#prev" ).button({
		text: false,
		icons: {
			primary: "ui-icon-seek-start"
		}
	});

	$( "#play" ).button({
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
			document.getElementById("myytplayer").playVideo();
		} else {
			options = {
				label: "play",
				icons: {
					primary: "ui-icon-play"
				}
			};
		}
		$( this ).button( "option", options );
		document.getElementById("myytplayer").pauseVideo();
	});

	$( "#next" ).button({
		text: false,
		icons: {
			primary: "ui-icon-seek-end"
		}
	});

	// http://jscrollpane.kelvinluck.com/
	$('#left_panel').jScrollPane();


	$("#song_list li").click(function() {

		swfobject.removeSWF("player");

		var newdiv = document.createElement('div');
		newdiv.setAttribute('id',"player_div");
		newdiv.innerHTML = '';
		document.getElementById("right_top_panel").appendChild(newdiv);

		if (music[$(this).text()][1]) {

			$('#right_top_panel').css('padding-top', '5px');
			$('#right_top_panel').css('height', '400px');

			// Youtube
			yt_id = music[$(this).text()][0];
			var params = { allowScriptAccess: "always" };
			var atts = { id: "player" };
			swfobject.embedSWF("http://www.youtube.com/e/" + yt_id + "?enablejsapi=1&playerapiid=ytplayer",
			"player_div", "600", "390", "8", null, null, params, atts);

		} else {

			$('#right_top_panel').css('padding-top', '155px');
			$('#right_top_panel').css('height', '250px');

			// Soundcloud 
			var flashvars = {
				enable_api: true, 
				object_id: "myPlayer",
				url: "http://soundcloud.com/forss/flickermood"
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

		}

	});


});