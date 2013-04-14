chrome.omnibox.onInputChanged.addListener(
  function(text, suggest) {
    fuzzyFilter(text, function(results){
      suggest(_.map(results, function(re){
        return { content: re.url, description: re.title }
      }));
    });
  });

// This event is fired with the user accepts the input in the omnibox.
chrome.omnibox.onInputEntered.addListener( function(text) {
  chrome.windows.getCurrent({"populate": true}, function(wind){
    var tab = _.find(wind.tabs, {"url": text});
    if(tab){
      chrome.tabs.update(tab.id, {selected: true});
    }else{
      fuzzyFilter(text, function(tabs){
        if(tabs){
          tab = tabs[0];
          if(tab) chrome.tabs.update(tab.id, {selected: true});
        }
      });
    }
  })
});

function fuzzyFilter(search, callback){
  chrome.windows.getCurrent({"populate": true}, function(wind){
    var filtered = _.union(
      fuzzy.filter(search, wind.tabs, {
        extract: function(el){ return el.url }
      }),
      fuzzy.filter(search, wind.tabs, {
        extract: function(el){ return el.title }
      })
    );
    callback(
      _.map(filtered, function(fil){ return _.filter(wind.tabs, function(tab){
        return (tab.url == fil.string || tab.title == fil.string);
      })[0]})
    );
  })
}

//should add content script injected keyboard shortcut for all pages
//save available tags in a tab-id hash in localstorage and update it when it's being used
