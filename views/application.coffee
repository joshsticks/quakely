#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data

getDataFromUSGS = (url, callback) -> 
	$.ajax {
	    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=300&callback=?&q=' + encodeURIComponent(url),
	    dataType: 'json',
	    success: (data) -> callback data.responseData.feed
	  }
	
renderData = (items) ->
	#add row header then iterate rows
	$("#quakes").append '<li data-role="list-divider">' + new Date(items[0].publishedDate).toDateString() + '<span class="ui-li-count">' + items.length + '</span></li>'
	$("#quakes").append "<li><a href='"+ item.link + "'>" + item.title + "</a></li>" for item in items
	$("#quakes").listview('refresh');

#rename this be parse once the parsing is implemented
parseData = (feed) ->
	#should get from localstorage
	#add from feed arg what isn't already in local
	#should have listview spinny icon for loading
	data = _.groupBy(feed.entries, (item) -> new Date(item.publishedDate).toDateString())
	dates = _.toArray(data)
	#now = new Date
	#dates = ( now.setDate(now.getDate() - num) for num in[0...29] )
	renderData(date) for date in dates
	#addItem record for record in feed.entries
	#$("#quakes").listview('refresh');
	#should save all that back to localstorage
	
$ ->
	url = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"
	getDataFromUSGS url, parseData
	#add dividers for last 30 days
	#after getting data probably remove dividers where no quakes occurred