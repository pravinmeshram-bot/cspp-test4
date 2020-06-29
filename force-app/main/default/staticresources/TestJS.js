// window.gonative_status_beforelogin = function (data) {
//   if (data && data.hasTouchId && data.hasSecret) {
//     // Prompt the user to use the fingerprint to log in
//     window.open(
//       "gonative://auth/get?callbackFunction=gonative_secret_callback",
//       "_top"
//     );
//   }
// };


// window.open(
//   "gonative://auth/status?callbackFunction=gonative_status_beforelogin",
//   "_top"
// );



window.myfunction = function() {
    console.log('anunia banunia');
}



window.gonative_status_afterlogin = function(data) {
  if (data && data.hasTouchId) {
    var secret = JSON.stringify({
      username: "akaki",
      password: "bakaki",
    });
    window.location.href =
      "gonative://auth/save?secret=" + encodeURIComponent(secret);
  console.log('adddddddddd');
  
    }

}; 


window.location.href = 'gonative://auth/status?callbackFunction=gonative_status_afterlogin';
           
window.gonative_status_beforelogin = function(data) {
  if (data && data.hasTouchId && data.hasSecret) {
    // Prompt the user to use the fingerprint to log in

    console.log("baddddddddddd");
    window.location.href =
      "gonative://auth/get?callbackFunction=gonative_secret_callback";
  }
};

window.location.href = "gonative://auth/status?callbackFunction=gonative_status_beforelogin"
