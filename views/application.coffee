#pseudo
#load data from local
#check service for data not in local
#add that data to local
#display data

getDataFromUSGS = (callback) -> 
	url = "http://earthquake.usgs.gov/earthquakes/shakemap/rss.xml"
	$.ajax {
	    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=300&callback=?&q=' + encodeURIComponent(url),
	    dataType: 'json',
	    success: (data) -> callback data.responseData.feed
	  }
	
addItem = (item) ->
	date = new Date(item.publishedDate)
	time = if (date.getHours() >= 12) then "<strong>" + (date.getHours() - 12) + ":" + date.getMinutes() + 
		"</strong>PM" else "<strong>" + date.getHours() + ":" + date.getMinutes() + "</strong>AM"
	$("#quakes").append "<li><a href='"+ item.link +
		"'><p class='ui-li-aside ui-li-desc'>" + time + 
		"</p><h3 class='ui-li-heading'>" + item.title + 
		"</h3><p class='ui-li-desc'>" + item.contentSnippet + "</p></a></li>"
		
renderData = (items) ->
	#sorted = _.sortBy(items, (item) -> new Date(item.publishedDate).toLocaleTimeString())
	#reversed = sorted.reverse()
	$("#quakes").append '<li data-role="list-divider">' + new Date(items[0].publishedDate).toLocaleDateString() + '<span class="ui-li-count">' + items.length + '</span></li>'
	addItem item for item in items
	$("#quakes").listview('refresh');

parseData = (feed) ->
	#should get from localstorage
	#add from feed arg what isn't already in local
	#should have listview spinny icon for loading
	
	#may need to get in local time and sort first
	sorted = _.sortBy(feed.entries, (item) -> new Date(item.publishedDate))
	reversed = sorted.reverse()
	data = _.groupBy(reversed, (item) -> new Date(item.publishedDate).toLocaleDateString())
	dates = _.toArray(data)
	#now = new Date
	#dates = ( now.setDate(now.getDate() - num) for num in[0...29] )
	renderData(date) for date in dates
	#addItem record for record in feed.entries
	#$("#quakes").listview('refresh');
	#should save all that back to localstorage
	$.mobile.hidePageLoadingMsg()
	
$ ->
	$.mobile.showPageLoadingMsg()
	getDataFromUSGS parseData
	
	$("#refresh").click( () ->
		$.mobile.showPageLoadingMsg()
		getDataFromUSGS parseData)