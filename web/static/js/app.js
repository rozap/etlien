import "phoenix"

console.log("elo from regular js")
window.onload = function() {
  console.log('goober')
  var elmDiv = document.getElementById('elm-main'),
    elmApp = Elm.Main.embed(elmDiv);
}