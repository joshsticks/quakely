#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data

getDataFromUSGS = (callback) -> 
	$.ajax {
	    url: document.location.protocol + '//earthquake.usgs.gov/earthquakes/shakemap/rss.xml',
	    dataType: 'xml',
	    success: (data) -> callback data.responseData.feed
	  }

quakes = (feed) ->
	#should get from localstorage
	#add from feed arg what isn't already in local
	$("#quakes").append "<li>" + record + "</li>" for record in feed
	#should save all that back to localstorage
	
$ ->
	getDataFromUSGS quakes