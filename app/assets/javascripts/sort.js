$(document).ready(function() {
    var sortParam = getSortParam();
    var sortDir = getSortDirection();
    $previousSearches = $("#previous-searches");
    modifyLinks(sortParam, sortDir);
    setListeners();
});

var setListeners = function() {
    $("#previous-searches").on("click", "#query", function(e) {
        sortElements(e);
    });
    $("#previous-searches").on("click", "#count", function(e) {
        sortElements(e);
    });
    $("#previous-searches").on("click", "#updated_at", function(e) {
        sortElements(e);
    });
};

var sortElements = function(event) {
    var sortParam = event.target.id;
    var sortDir = getSortDirection();
    var sortDir = sortDir === 'asc' ? 'desc' : 'asc';
    $.ajax({
        url: "/searches/previous_searches?sort_by=" + sortParam + "&sort_direction=" + sortDir,
        type: 'GET',
        success: function(res) {
            $previousSearches.html(res);
            setSearchParams(sortParam, sortDir);
            modifyLinks(sortParam, sortDir);
        }
    });
};

var setSearchParams = function(sortParam, sortDir) {
    var newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
    newUrl = newUrl.split('?')[0];
    newUrl += "?sort_by=" + sortParam + "&sort_direction=" + sortDir;
    window.history.pushState({ path: newUrl }, '', newUrl);
};

var getSortDirection = function() {
    var search = window.location.search.slice(1);
    if (search.length > 0) {
        var attrs = search.split('&');
        return attrs[1].split('=')[1];
    } else {
        return "asc";
    }
};

var getSortParam = function() {
    var search = window.location.search.slice(1);
    if (search.length > 0) {
        var attrs = search.split('&');
        return attrs[0].split('=')[1];
    } else {
        return "query";
    }
};

var modifyLinks = function(sortParam, sortDir) {
    if (sortParam && sortDir) {
        $('.search-cell a').each(function(a) {
            var url = $(this).attr('href');
            url = url.split('?')[0];
            url += "?sort_by=" + sortParam + "&sort_direction=" + sortDir;
            $(this).attr('href', url);
        });
    }
};