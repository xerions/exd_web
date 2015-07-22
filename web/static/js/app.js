import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", chan => {
//   console.log("Success!")
// })
$('.responsive-table').cardtable();
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

export default App
