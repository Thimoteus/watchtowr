(function() {
  var args, input, output, path, watchtowr, _ref;

  path = require('path');

  watchtowr = require('../lib/watchtowr.coffee');

  args = process.argv.slice(2);

  input = /\.less$/.test(args[0]) ? args[0] : args[0] + '.less';

  output = (_ref = args[1]) != null ? _ref : input.replace(/\.less$/, ".css");

  watchtowr.watch(input, output);

}).call(this);
