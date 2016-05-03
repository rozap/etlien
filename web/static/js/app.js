import "phoenix"

console.log("elo from regular js")
window.onload = function() {
  var elmDiv = document.getElementById('elm-main'),
    elmApp = Elm.embed(Elm.Main, elmDiv);
}