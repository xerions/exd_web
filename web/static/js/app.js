// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
$('.responsive-table').cardtable();
$('.table-responsive .trimmable').each(function() {
    var that = $(this),
        title = that.text(),
        chars = title.length;

    if (chars > 20) {
        var newTitle = title.substring(0, 17) + "...";
        that.text(newTitle);
    }
});
$("#search").click(function() {
    pattern = $('#pattern').val();
    window.location = "../search/" + pattern;
});
$('#pattern').keypress(function(e) {
    if(e.keyCode == 13)
        $('#search').click();
});

let App = {
}
export default App// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
