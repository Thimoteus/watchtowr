watchtowr
=========

Watch and compile LESS files.

Very much in alpha. Enough to do basic file watching. Probably shouldn't be used by anyone.

Example: a.less imports b.less and c.less. b imports d.less. watchtowr will watch a, b, c and d and recompile a anytime it detects a change.

Usage: Put the ./bin/ folder into your PATH variable. Then:

```
$ watchtowr a.less, a.css
```

To do:

1.  Deal with circular imports

2.  Deal with css imports

3.  Lots of error handling

4.  Directory watching

Known issues:

1. Does not respect commented imports