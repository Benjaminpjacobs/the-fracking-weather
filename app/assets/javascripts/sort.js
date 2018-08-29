$(document).ready(() => {
    const sortParam = getSortParam();
    const sortDir = getSortDirection();
    modifyLinks(sortParam, sortDir);
    setListeners();
});

const setListeners = function() {
    $("#previous-searches").on("click", "#query", (e) => sortElements(e));
    $("#previous-searches").on("click", "#count", (e) => sortElements(e));
    $("#previous-searches").on("click", "#updated_at", (e) => sortElements(e));
};

const sortElements = (event) => {
    const $previousSearches = $("#previous-searches");
    const sortParam = event.target.id;
    const sortDir = getSortDirection();
    const opSortDir = sortDir === 'asc' ? 'desc' : 'asc';
    $.ajax({
        url: "/searches/previous_searches?sort_by=" + sortParam + "&sort_direction=" + opSortDir,
        type: 'GET',
        success: (res) => {
            handleResponse(res, $previousSearches, sortParam, opSortDir);
        }
    });
};

const handleResponse = (res, $previousSearches, sortParam, SortDir) => {
    $previousSearches.html(res);
    setSearchParams(sortParam, SortDir);
    modifyLinks(sortParam, SortDir);
}

const setSearchParams = (sortParam, sortDir) => {
    const fullUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
    const baseUrl = fullUrl.split('?')[0];
    const newUrl = baseUrl + "?sort_by=" + sortParam + "&sort_direction=" + sortDir;
    window.history.pushState({ path: newUrl }, '', newUrl);
};

const getSortDirection = () => {
    const search = window.location.search.slice(1);
    if (search.length > 0) {
        const attrs = search.split('&');
        return attrs[1].split('=')[1];
    } else {
        return "asc";
    }
};

const getSortParam = () => {
    const search = window.location.search.slice(1);
    if (search.length > 0) {
        const attrs = search.split('&');
        return attrs[0].split('=')[1];
    } else {
        return "query";
    }
};

const modifyLinks = (sortParam, sortDir) => {
    if (sortParam && sortDir) {
        $('.search-cell a').each(function(a) {
            const fullUrl = $(this).attr('href');
            const baseUrl = fullUrl.split('?')[0];
            const newUrl = baseUrl + "?sort_by=" + sortParam + "&sort_direction=" + sortDir;
            $(this).attr('href', newUrl);
        });
    }
};