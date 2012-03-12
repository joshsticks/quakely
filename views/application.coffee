#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data


#should probably just store these in the localstorage as a hunk of key values with the key being the link
#localstorage['quakes'] = [{"usgs.gov/adf", Object},{"usgs.gov/dfs", Object}] --- key(link), value(serialized obj)

class Quake
	constructor: (data) ->
		@latlong = data.contentSnippet.substring(data.contentSnippet.indexOf('UTCLat/Lon: ') + 12, 
			data.contentSnippet.indexOf('Depth'))
		@link = data.link
		@date = new Date(data.publishedDate)
		@title = data.title
	equals: (other) ->
		this.link == other.link
				
#html5 storage support check helper
supports_html5_storage = ->
	try
		return 'localStorage' of window and window['localStorage'] isnt null
	catch e
		return false

#use google feed api to get around COR issues accessing RSS feed
getDataFromRSSFeed = (url, callback) -> 
	googleFeedApi = '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=300&callback=?&q='
	$.ajax {
	    url: document.location.protocol + googleFeedApi + encodeURIComponent(url),
	    dataType: 'json',
	    success: (data) -> callback data.responseData.feed
	  }
	
renderItem = (item) ->
	#TODO: this time code generates 7:4 instead of 7:04 etc.
	time = if (item.date.getHours() >= 12) then "<strong>" + (item.date.getHours() - 12) + ":" + item.date.getMinutes() + 
		"</strong>PM" else "<strong>" + item.date.getHours() + ":" + item.date.getMinutes() + "</strong>AM"
	$("#quakes").append "<li><a href='"+ item.link +
		"'><p class='ui-li-aside ui-li-desc'>" + time + 
		"</p><h3 class='ui-li-heading'>" + item.title + 
		"</h3><p class='ui-li-desc'>" + item.latlong + "</p></a></li>"
		
renderData = (items) ->
	$("#quakes").append '<li data-role="list-divider">' + items[0].date.toLocaleDateString() + 
		'<span class="ui-li-count">' + items.length + '</span></li>'
	renderItem item for item in items
	$("#quakes").listview('refresh');

parseData = (feed) ->
	#should get from localstorage
	#if supports_html5_storage()
	#	if localStorage["quakes"]?
	#		quakes = JSON.parse localStorage["quakes"]
			#if runTimes?
			#	runTimes.push new Date()
			#else
			#	runTimes = [new Date()]
			#localStorage["runTimes"] = JSON.stringify runTimes
	
	#REALLY CLOSE, should probably refactor to check if network
	#if there is network get from feed, else get from local
	#add a refresh function which does similar and  delete function
	
	
	#get the array of quakes from local if they exist
	if supports_html5_storage()
		if localStorage["quakes"]?
			quakes = JSON.parse localStorage["quakes"]
	
	#generate an array of quakes from the feed
	if quakes?
		for item in feed.entries
			do (item) ->
				quake = new Quake(item)
				if(!_.include(quakes, quake))
					quakes.push quake
	else
		quakes = []
		quakes.push new Quake(item) for item in feed.entries
					
	#save quake data back to local
	localStorage["quakes"] = JSON.stringify quakes

	#sort the data from the feed in desc order by date
	quakes = _.sortBy(quakes, (quake) -> quake.date).reverse()
	#group them by local date
	quakes = _.toArray(_.groupBy(quakes, (quake) -> quake.date.toLocaleDateString()))

	#add from data from feed that isn't already in local
	#should wrap in a if quakes block incase no data in localstorage
	#for date in dates
	#	do (date, dates) ->
			
	#		if (quakes[dates.indexOf(date)] == dates[dates.indexOf(date)])
				#should see if date even exists, if not add all
	#			for quake in date
	#				do (quake, date, dates) ->
						#if (!quakes[dates.indexOf(date)][date.indexOf(quake)].link == quake.link)
							#not sure if not operator here is right, add the thing if it's not there
	

	
	renderData(date) for date in quakes

	$.mobile.hidePageLoadingMsg()

loadData = ->
	$.mobile.showPageLoadingMsg()
	getDataFromRSSFeed "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml", parseData
	
$ ->
	loadData()
	
	$("#refresh").click( () ->
		loadData())