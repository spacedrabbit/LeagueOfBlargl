LeagueOfBlargl
==============

Query the League of Legends API for Info

#####v.3#####

**Accomplishes**
* Searchbar functionality is in place
	+ searching for summoners from the searchbar works
	+ additionally, stores prior searches (SavedSearch class)
	+ displays those prior searches

* More features added to the primary search results table
	+ Cells populate automatically with summoner data and icon
	+ tapping a cell after a search brings you to a profile view (not fully implemented)

* Updates to API Manager
	+ Improves upon existing API requests
	+ Adds a subclass to manage static data calls
	+ moves some functionality into data manager

* Updates to Data Manager
	+ parses data from API to generate Summoner objects
	+ makes calls to retrieve icon data, then stores it

* UI updates to make the color scheme slightly less horrendous, but still pretty bad

**Known Bugs:**
* Searching for a summoner that the API cannot retrieve the icon for results in
	the entry being added to the list of prior results, but the table doesn't update
	- searching for a summoner after the above issue results in the table updating for all previous calls
	- there is no verifying to see if a summoner has already been searched for
* There is not much in the way of error handling just yet, so a bad request just does nothing besides produce
	console output
* Plus a bunch more that are not quite so obvious when running the code, but will be resolved by a refactor

**To Do:**
* Spend a day refactoring. The End.
* But then after that, the goal is to populate recent game statistics, so
	+ fill out the profile page
	+ present additional data via a collection view that will display data categories (rune pages, masteries, etc.)

**Notes**
If I didn't believe in technical debt up until now, this project would certainly have me seeing the light.
Day 4 of this ZQ will have to be spent nearly entirely on code refactoring.. there's just way too much
interdependence for my tastes, and the code is getting unweilding in terms of which methods get called where.
It may have been a mistake moving the data source of the main tableview to the Data Manager, as it's splitting
up where I update results and make updates to the table.

**Tidbits**
Request Fails, but Response Succeeds
At one point, I had explicitly set the requestSerializer of an AFHTTPSessionManager to be that of AFJSONRequestSerializer.
 The response serializer was of type AFImageResponseSerializer (this request was for the icon image requests).

When running the code. I kept getting the common error of (paraphrase) "unacceptable request type: html/text",
 despite specifically setting the header values of the request for Content-Type to be "application/json".

That's confusing on it's own, but not only did I receive a response code of 404, but I would still get  the requested image in my
 response block! So, it was erroring on the request, but still returning what I needed.. odd.

So the fix? I figure that there has to be a problem with my request at some point, but it's not entirely clear where that issue
 stemmed. Concerned that I should be making a different kind of request given that this was (I guess) a download task, I re-wrote
 the request such that I call on the parent method (AFURLSessionManager) dataTaskWithRequest:completionHandler: and created
 the URL request via the request serializer method requestWithMethod:URLString:parameters:error:



#####V0.1#####
**To Do:**
- Implement SearchBar Entirely
- Implement [NSKeyedArchiving][KA]
- Look into [Mantle][1]

[1]: https://github.com/Mantle/Mantle
[KA]: http://nshipster.com/nscoding/
