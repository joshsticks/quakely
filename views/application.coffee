#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data

getDataFromUSGS = (url, callback) -> 
	$.ajax {
	    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=100&callback=?&q=' + encodeURIComponent(url),
	    dataType: 'json',
	    success: (data) -> callback data.responseData.feed
	  }

quakes = (feed) ->
	#should get from localstorage
	#add from feed arg what isn't already in local
	$("#quakes").append "<li>" + record.title + "</li>" for record in feed.entries
	$("#quakes").listview('refresh');
	#should save all that back to localstorage
	
$ ->
	url = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"
	getDataFromUSGS url, quakes