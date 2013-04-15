chrome.omnibox.onInputChanged.addListener(function(text, suggest) {
  fuzzyTabs(text, function(results){
    suggest(_.map(results, function(re){
      return { content: re.url, description: re.title }
    }));
  });
});

// This event is fired with the user accepts the input in the omnibox.
chrome.omnibox.onInputEntered.addListener( function(text) {
  fuzzyTabs(text, function(tabs){
    if(tabs) chrome.tabs.update(tabs[0].id, {selected: true});
  });
});

function fuzzyTabs(search, callback){
  chrome.windows.getCurrent({"populate": true}, function(wind){
    var filtered = fuzzy.filter(search, wind.tabs, {
      extract: function(el){ return el.url + "::" + el.title }
    });
    callback(_.map(filtered, function(fil){return fil.original}));
  });
}

chrome.bookmarks.search("github", function(i){
  console.log(i);
});


//should add content script injected keyboard shortcut for all pages
