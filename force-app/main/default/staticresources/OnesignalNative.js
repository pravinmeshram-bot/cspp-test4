window.globalInformation_documentData = '';

function gonative_callback(data) {
    alert('****',data);
    window.globalInformation_documentData = data;
}
window.gonative_callback = function(info) {
    var oneSignal = JSON.stringify(info);
    alert(oneSignal);
    window.globalInformation_documentData = JSON.parse(JSON.stringify(oneSignal));
}