(function(ua, w, d, undefined) {

    var getXmlHttp = function(){
      var xmlhttp;
      try {
        xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
      } catch (e) {
        try {
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (E) {
          xmlhttp = false;
        }
      }
      if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
        xmlhttp = new XMLHttpRequest();
      }
      return xmlhttp;
    };

    var production = false;

    console.log("Production: ", production);

    var boilerplateMVC = {

      loadJS: function(file, callback) {
          var script = d.createElement("script");
          script.type = "text/javascript";
          if (script.readyState) {  // IE
              script.onreadystatechange = function() {
                  if (script.readyState == "loaded" || script.readyState == "complete") {
                      script.onreadystatechange = null;
                      callback();
                  }
              };
          } else {  // Other Browsers
              script.onload = function() {
                  callback();
              };
          }
          if(((typeof file).toLowerCase()) === "object" && file["data-main"] !== undefined) {
              script.setAttribute("data-main", file["data-main"]);
              script.async = true;
              script.src = file.src;
          } else {
              script.src = file;
          }
          d.getElementsByTagName("head")[0].appendChild(script);
      },

      loadCSS: function(url, callback) {
          var link = d.createElement("link");
          link.type = "text/css";
          link.rel = "stylesheet";
          link.href = url;
          d.getElementsByTagName("head")[0].appendChild(link);
          if(callback) {
              callback();
          }
      },

      loadFiles: function(production, obj, callback) {
          var self = this;
          if(production) {
              self.loadCSS(obj["prod-css"], function() {
                  if(obj["prod-js"]) {
                      self.loadJS(obj["prod-js"], callback);
                  }
              });
          } else {
              self.loadCSS(obj["dev-css"], function() {
                  if(obj["dev-js"]) {
                      self.loadJS(obj["dev-js"], callback);
                  }
              });
          }
      }
    }

    var startLoadFiles = function(data) {

      filesToLoad = {
          "dev-css": "css/desktop.css",
          "prod-css": "css/desktop.min.css",
          "dev-js": { "data-main": "js/app/config/config.js", "src": "js/libs/requirejs/require.js" },
          "dev-init": "js/app/init/DesktopInit.js",
          "prod-init": "js/app/init/DesktopInit-" + data.options.version + ".min.js",
          "prod-js": { "data-main": "js/app/config/config.js", "src": "js/libs/require/require.js" }
      };

      boilerplateMVC.loadFiles(production, filesToLoad, function() {
          if(!production && window.require) {
              require([filesToLoad["dev-init"]]);
          } else if ( production ) {
              require([filesToLoad["prod-init"]])
          }
      });
    };

    var req = getXmlHttp();
    var pathPrefix = "";
    req.open("GET", pathPrefix + "/app/options");
    req.send();
    req.onreadystatechange = function() {
      if (req.status == 200 && req.readyState == 4) {
        var jsonResponse = JSON.parse(req.response);
        console.log('Initialized detect.js with loading app options:', jsonResponse);
        startLoadFiles({options: jsonResponse});
      }
    };

})(navigator.userAgent || navigator.vendor || window.opera, window, document);
