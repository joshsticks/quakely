#remaining work:
#gesture based deletion
#clean up code --- parseData function in particular

#little object for quake data
class Quake
	constructor: (data) ->
		latlong = data.contentSnippet.substring(data.contentSnippet.indexOf('UTCLat/Lon: ') + 12, 
			data.contentSnippet.indexOf('Depth'))
		@lat = latlong.substring(0, latlong.indexOf('/'))
		@long = latlong.substring(latlong.indexOf('/') + 1, latlong.length)
		@link = data.link
		@date = new Date(data.publishedDate)
		@title = data.title
		@magnitude = data.title.substring(0, data.title.indexOf(' -'))
				
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

#generate a formatted 12 hour time
formatTime = (date) ->
	if (date.getHours() >= 12)
		hours = date.getHours() - 12
		ampm = "PM"
		if hours == 0
			hours = 12
	else
		hours = date.getHours()
		ampm = "AM"
	if (date.getMinutes() < 10)
		minutes = "0" + date.getMinutes()
	else
		minutes = date.getMinutes()
	"<strong>" + hours + ":" + minutes + "</strong>" + ampm

#rendering an individual quake object	
renderItem = (item) ->
	time = formatTime item.date
		
	if (item.magnitude >= 7)
		color = "style='color:Red'"
	else if (item.magnitude >= 5)
		color = "style='color:LightCoral'"
	else
		color = ""
	$("#quakes").append "<li><a href='"+ item.link +
		"'><p class='ui-li-aside ui-li-desc'>" + time + 
		"</p><h3 class='ui-li-heading'" + color + ">" + item.title + 
		"</h3><p class='ui-li-desc'>" + "<strong>LAT</strong> " + 
		item.lat + " <strong>LONG</strong> " + item.long + "</p></a></li>"

#takes the object with date and array of quakes on that date and renders it		
renderData = (items) ->
	$("#quakes").append '<li data-role="list-divider">' + items[0].date.toLocaleDateString() + 
		'<span class="ui-li-count">' + items.length + '</span></li>'
	renderItem item for item in items
	$("#quakes").listview('refresh');

#handles parsing and then rendering data from feed and/or localstorage...or no data
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

#invokes the feed reader with the parser as a callback
loadData = ->
	$.mobile.showPageLoadingMsg()
	getDataFromRSSFeed "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml", parseData
	
$ ->
	#initial load
	loadData()
	
	#bind the refresh button to reload data
	$("#refresh").click( () ->
		loadData())
	
	#bind to the swipe for rendering a delete button
	$("ul li").live( 'swiperight', (e) ->
		alert("swiped"))