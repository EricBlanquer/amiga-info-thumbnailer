var PNG = require("pngjs").PNG;
var fs = require("fs");
var Icon = require("../icon.js");
var BinaryStream = require("../lib/file.js");

var inputPath = process.argv[2];
var outputPath = process.argv[3];

if (!inputPath || !outputPath) {
    process.exit(1);
}

var buffer = fs.readFileSync(inputPath);
var ab = new ArrayBuffer(buffer.length);
var view = new Uint8Array(ab);
for (var i = 0; i < buffer.length; ++i) {
    view[i] = buffer[i];
}

var file = BinaryStream(ab, true);
var isIcon = Icon.detect(file);
if (!isIcon) {
    process.exit(1);
}

Icon.parse(file, function(icon) {
    var png = icon2Png(icon, 0);
    if (!png) {
        process.exit(1);
    }
    png.pack().pipe(fs.createWriteStream(outputPath))
        .on('finish', function() {
            process.exit(0);
        });
});

function icon2Png(icon, stateIndex) {
    stateIndex = stateIndex || 0;
    var iconData = icon.colorIcon || icon.newIcon;
    if (iconData) {
        var w = iconData.width;
        var h = iconData.height;
        var state = iconData.states[stateIndex];

        if (state) {
            var png = new PNG({width: w, height: h});

            for (var y = 0; y < h; y++) {
                for (var x = 0; x < w; x++) {
                    var index = y * w + x;
                    var pixel = state.pixels[index];
                    if (state.rgba) {
                        var color = pixel;
                    } else {
                        color = state.palette[pixel] || [0, 0, 0, 0];
                    }
                    if (color.length < 4) color[3] = 1;
                    if (pixel === 0) color = [0, 0, 0, 0];

                    var idx = index << 2;
                    png.data[idx] = color[0];
                    png.data[idx + 1] = color[1];
                    png.data[idx + 2] = color[2];
                    png.data[idx + 3] = Math.ceil(color[3] * 255);
                }
            }
            return png;
        }
    } else {
        Icon.setPalette(icon, stateIndex);
        var img = stateIndex ? icon.img2 : icon.img;

        if (!img) return;

        var w = img.width;
        var h = img.height;
        var png = new PNG({width: w, height: h});

        for (var y = 0; y < img.height; y++) {
            for (var x = 0; x < img.width; x++) {
                var index = y * w + x;
                var pixel = img.pixels[y][x];
                var color = img.palette[pixel] || [0, 0, 0, 0];
                if (color.length < 4) color[3] = 1;
                if (pixel === 0) color = [0, 0, 0, 0];
                var idx = index << 2;
                png.data[idx] = color[0];
                png.data[idx + 1] = color[1];
                png.data[idx + 2] = color[2];
                png.data[idx + 3] = Math.ceil(color[3] * 255);
            }
        }
        return png;
    }
}
