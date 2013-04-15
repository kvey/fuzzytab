port = chrome.runtime.connect({name: "fuzzytab"})

$.keydown((e) ->
  if(e.keyCode == 73 && e.ctrlKey == true)
    e.preventDefault()
    $("body").append("""
        <div id="fzytab-search" class="search">
            <input id="fzytab-query" name="query" placeholder="tabs and bookmarks"/>
            <ul id="fzytab-results">
            </ul>
        </div>
    """)
    $("#fzytab-query").change((e) ->
        port.postMessage({
            "query": $(this).val()
        })
    )
)

handlers = {
    "results": (port, results) ->
        for result in results
            $("#fzytab-results").append("""
                <li class="fzytab-result"
                    data-type="#{result.type}"
                    data-target="#{result.target}"
                >
                    #{result.text}
                </li>
            """)
         $(".fzytab-result").click((e) ->
             $(this).data("type")
         )
}

port.onMessage.addListener((msg) ->
    handlers[msg.tag](port, msg.data)
)

# use jqueryui autocomplete
