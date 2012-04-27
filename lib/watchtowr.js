(function() {
  var comment, debug, exec, extension, filesToWatch, fs, getAllPaths, getImportPaths, imprts, path, print, space, watchtowr;

  watchtowr = exports;

  fs = require('fs');

  exec = require('child_process').exec;

  path = require('path');

  print = function(x) {
    return console.log(x);
  };

  debug = false;

  space = /\s/;

  imprts = "@import ['\"]([^'\"]+?)['\"];";

  comment = /\/\//;

  extension = {
    less: /\.less$/,
    css: /\.css$/
  };

  filesToWatch = [];

  getImportPaths = function(filename) {
    var data, dir, imports, item, leaf;
    dir = path.dirname(filename);
    if (debug) print(dir);
    try {
      data = fs.readFileSync(filename, 'utf-8');
    } catch (err) {
      print("Something went wrong: " + err.message);
      return;
    }
    if (!(new RegExp(imprts)).test(data)) throw leaf = {};
    imports = data.match(new RegExp(imprts, "g"));
    imports = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = imports.length; _i < _len; _i++) {
        item = imports[_i];
        _results.push(item.match(new RegExp(imprts))[1]);
      }
      return _results;
    })();
    imports = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = imports.length; _i < _len; _i++) {
        item = imports[_i];
        _results.push(path.resolve(dir, item));
      }
      return _results;
    })();
    if (debug) print(imports);
    return imports;
  };

  getAllPaths = function(filename) {
    var eachPath, paths, _i, _j, _len, _len2, _results;
    paths = getImportPaths(filename);
    for (_i = 0, _len = paths.length; _i < _len; _i++) {
      eachPath = paths[_i];
      filesToWatch.push(eachPath);
    }
    _results = [];
    for (_j = 0, _len2 = paths.length; _j < _len2; _j++) {
      eachPath = paths[_j];
      _results.push(getAllPaths(eachPath));
    }
    return _results;
  };

  watchtowr.watch = function(origin, output) {
    var file, _i, _len, _results;
    filesToWatch.push(origin);
    print("Watchtowr is watching");
    try {
      getAllPaths(origin);
    } catch (err) {
      if (err === leaf) {
        return;
      } else {
        throw err;
      }
    }
    _results = [];
    for (_i = 0, _len = filesToWatch.length; _i < _len; _i++) {
      file = filesToWatch[_i];
      _results.push(fs.watch(file, function(evt, filename) {
        print("Detected " + evt + " at " + filename);
        if (evt === "change") {
          return exec("lessc " + (origin.replace(space, '\\ ')) + " " + output, function(err, stdout, stderr) {
            print(stdout);
            if (stderr.length > 0) print(stderr);
            if (typeof error !== "undefined" && error !== null) {
              return print(error);
            } else {
              return print("Update successful.");
            }
          });
        }
      }));
    }
    return _results;
  };

}).call(this);
