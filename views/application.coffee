#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data

#should probably refactor at this point
#Quake class with a functioning equals operator
#Quakes class with Array of Arrays, Quakes[Date][Quake[]]

#html5 storage support check helper
supports_html5_storage = ->
	try
		return 'localStorage' of window and window['localStorage'] isnt null
	catch e
		return false

getDataFromUSGS = (callback) -> 
	url = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"
	$.ajax {
	    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=300&callback=?&q=' + encodeURIComponent(url),
	    dataType: 'json',
	    success: (data) -> callback data.responseData.feed
	  }
	
renderItem = (item) ->
	date = new Date(item.publishedDate)
	time = if (date.getHours() >= 12) then "<strong>" + (date.getHours() - 12) + ":" + date.getMinutes() + 
		"</strong>PM" else "<strong>" + date.getHours() + ":" + date.getMinutes() + "</strong>AM"
	$("#quakes").append "<li><a href='"+ item.link +
		"'><p class='ui-li-aside ui-li-desc'>" + time + 
		"</p><h3 class='ui-li-heading'>" + item.title + 
		"</h3><p class='ui-li-desc'>" + item.contentSnippet + "</p></a></li>"
		
renderData = (items) ->
	$("#quakes").append '<li data-role="list-divider">' + new Date(items[0].publishedDate).toLocaleDateString() + '<span class="ui-li-count">' + items.length + '</span></li>'
	renderItem item for item in items
	$("#quakes").listview('refresh');

parseData = (feed) ->
	#should get from localstorage
	if supports_html5_storage()
		if localStorage["quakes"]?
			quakes = JSON.parse localStorage["quakes"]
			#if runTimes?
			#	runTimes.push new Date()
			#else
			#	runTimes = [new Date()]
			#localStorage["runTimes"] = JSON.stringify runTimes
	
	
	#sort the data from the feed in desc local time
	sorted = _.sortBy(feed.entries, (item) -> new Date(item.publishedDate))
	reversed = sorted.reverse()
	data = _.groupBy(reversed, (item) -> new Date(item.publishedDate).toLocaleDateString())
	dates = _.toArray(data)
	

	#add from data from feed that isn't already in local
	#should wrap in a if quakes block incase no data in localstorage
	for date in dates
		do (date, dates) ->
			#should see if date even exists, if not add all
			for quake in date
				do (quake, date, dates) ->
					if (!quakes[dates.index(date)][date.indexOf(quake)].link == quake.link)
						#not sure if not operator here is right, add the thing if it's not there
	
	#save quake data back to local
	localStorage["quakes"] = JSON.stringify dates

	#should save all that back to localstorage
	renderData(date) for date in dates

	$.mobile.hidePageLoadingMsg()

loadData = ->
	$.mobile.showPageLoadingMsg()
	getDataFromUSGS parseData
	
$ ->
	loadData()
	
	$("#refresh").click( () ->
		loadData())