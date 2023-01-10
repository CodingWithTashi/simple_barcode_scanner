window.parent.addEventListener('reader', (e) => {
    const qrBoxWidth = e.detail.qrBoxWidth;
    const qrBoxHeight = e.detail.qrBoxHeight;
    jsCreateReader(qrBoxWidth, qrBoxHeight);

});

jsCreateReader = (qrBoxWidth, qrBoxHeight) => {
    //refer doc here https://github.com/mebjas/html5-qrcode
    const html5QrCode = new Html5Qrcode("reader");
    console.log("Starting SCANNING CODE");
    const qrCodeSuccessCallback = (decodedText, decodedResult) => {
        html5QrCode.stop();
        /* handle success for web */
        window.parent.postMessage(decodedText, "*");

        /* handle success for window */
        if (window.chrome.webview != "undefined") {
            var param = {
                "methodName": "successCallback",
                "data": decodedText
            }
            window.chrome.webview.postMessage(param);
        }

    };
    const config = {
        fps: 10,
        qrbox: {
            width: qrBoxWidth,
            height: qrBoxHeight,
            //aspectRatio: 1.7777778
        }
    };

    // If you want to prefer back camera
    html5QrCode.start({
        facingMode: "environment"
    }, config, qrCodeSuccessCallback);
    //html5QrCode.start({ facingMode: "user" }, config, qrCodeSuccessCallback);

    //Window event listener
    if (window.chrome.webview != undefined) {
        window.chrome.webview.addEventListener('message', function (e) {
            let data = JSON.parse(JSON.stringify(e.data));

            if (data.cmd === undefined)
                return;

            if (data.event === "close") {
                html5QrCode.stop();
            }
        });
    }

};