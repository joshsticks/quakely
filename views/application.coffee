#remaining work:
#coloring of rows based on magnitude 5+ light red 7+ red
#gesture based deletion
#clean up code --- parseData function in particular

class Quake
	constructor: (data) ->
		latlong = data.contentSnippet.substring(data.contentSnippet.indexOf('UTCLat/Lon: ') + 12, 
			data.contentSnippet.indexOf('Depth'))
		@lat = latlong.substring(0, latlong.indexOf('/'))
		@long = latlong.substring(latlong.indexOf('/') + 1, latlong.length)
		@link = data.link
		@date = new Date(data.publishedDate)
		@title = data.title
				
#html5 storage support check helper
supports_html5_storage = ->
	try
		return 'localStorage' of window and window['localStorage'] isnt null
	catch e
		return false

#use google feed api to get around COR issues accessing RSS feed
getDataFromRSSFeed = (url, callback) -> 
	if (navigator.onLine)
		googleFeedApi = '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=300&callback=?&q='
		$.ajax {
	    	url: document.location.protocol + googleFeedApi + encodeURIComponent(url),
	    	dataType: 'json',
	    	success: (data) -> callback data.responseData.feed
	  	}
	else
		callback null
	
renderItem = (item) ->
	if (item.date.getHours() >= 12)
		hours = item.date.getHours() - 12
		ampm = "PM"
		if hours == 0
			hours = 12
	else
		hours = item.date.getHours()
		ampm = "AM"
	if (item.date.getMinutes() < 10)
		minutes = "0" + item.date.getMinutes()
	else
		minutes = item.date.getMinutes()
	time = "<strong>" + hours + ":" + minutes + "</strong>" + ampm
	$("#quakes").append "<li><a href='"+ item.link +
		"'><p class='ui-li-aside ui-li-desc'>" + time + 
		"</p><h3 class='ui-li-heading'>" + item.title + 
		"</h3><p class='ui-li-desc'>" + "<strong>LAT</strong> " + 
		item.lat + " <strong>LONG</strong> " + item.long + "</p></a></li>"
		
renderData = (items) ->
	$("#quakes").append '<li data-role="list-divider">' + items[0].date.toLocaleDateString() + 
		'<span class="ui-li-count">' + items.length + '</span></li>'
	renderItem item for item in items
	$("#quakes").listview('refresh');

parseData = (feed) ->
	
	if supports_html5_storage()
		if localStorage["localData"]?
			localData = JSON.parse localStorage["localData"]
	
	if localData?
		quakes = []		   
		if feed?
			for item in feed.entries
				do (item) ->
					for local in localData
						if (local.link == item.link)
							break
						if (local.link != item.link && localData.indexOf(local) == (localData.length - 1))
							localData.push item
					
			localStorage["localData"] = JSON.stringify localData
		quakes.push new Quake(item) for item in localData
	else
		if feed?
			quakes = []
			localStorage["localData"] = JSON.stringify feed.entries
			quakes.push new Quake(item) for item in feed.entries 
	
	if quakes?	
		#sort the data from the feed in desc order by date
		quakes = _.sortBy(quakes, (quake) -> quake.date).reverse()
		#group them by local date
		quakes = _.toArray(_.groupBy(quakes, (quake) -> quake.date.toLocaleDateString()))
	
		$("#quakes").empty()
		renderData(date) for date in quakes
	else
		$("#quakes").empty()
		$("#quakes").append('<li><h3 class="ui-li-heading">NO LOCAL DATA AND NO NETWORK!</h3></li>')
		$("#quakes").listview('refresh');
	$.mobile.hidePageLoadingMsg()

loadData = ->
	$.mobile.showPageLoadingMsg()
	getDataFromRSSFeed "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml", parseData
	
$ ->
	loadData()
	
	$("#refresh").click( () ->
		loadData())