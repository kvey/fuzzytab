handlers = {
    change: (port, text, callback) ->
        # order
        # 1. search tabs
        tabExtract = (el) -> return el.url + "::" + el.title
        chrome.windows.getCurrent({"populate": true}, (wind) ->
            fuzzy.filter(search, wind.tabs, tabExtract, ((filtered) ->
                    port.postMessage({
                        tag: "resultsTabs"
                        results: _.map(filtered, (fil) -> return fil.original)
                    })
                )
            )
        )

        # 2. search directories using only first word
        dirExtract = (el) -> return el.title
        bookExtract = (el) -> return el.url + "::" + el.title
        fuzzy.filter(search.split(" ")[0], bookmarkDirs, dirExtract, (filtered) ->
            # 3. search bookmarks within the directories that matched
            fuzzy.filter(search, extractBookmarks(filtered), bookExtract, (filtered) ->
                port.postMessage({
                    tag: "resultsBookmarks"
                    results: _.map(filtered, (fil) -> return fil.original)
                })
            )
        )

    submitTab: (target) ->
        chrome.tabs.update(target, {selected: true}) # tab id

    submitBookmark: (target) ->
        chrome.tabs.create({url: target})

    submitGoogle: (target) ->
        chrome.tabs.create({url: "https://www.google.com/search?q=#{target}"})
}

extractBookmarks = (directories) ->
    results = []
    for direct in directories
        (dive = (dir) ->
            for child in dir.children
                if child.url
                    results.push(child)
                else
                    dive(child)
        )(direct)

bookmarkDirs = []
chrome.bookmarks.getTree((i) ->
    mobileBarAndDesktop = _.merge(i[0].children...)
    (dive = (dir) ->
        for child in dir.children
            unless child.url # if it has a url it's a bookmark instead
                bookmarkDirs.push(child)
                dive(child) if child.children
    )(mobileBarAndDesktop)
)

chrome.runtime.onConnect.addListener((port) ->
  port.onMessage.addListener((msg) -> handlers[msg.tag](port, msg.data))
)
