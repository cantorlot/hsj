A hop, skip and a jump
======================

A flash game made with [haXe](http://haxe.org) and [swfmill](http://swfmill.org/).

### Building 

The first time, you will need to install the __TweenerHX__ library bundled as __TweenerHX-1,33,74.zip__. It can also be linked to locally instead of installing.

    unzip TweenerHX-1,33,74.zip
    ln -s TweenerHX/caurina .

To build:

    haxe hsj.hxml

Without traces:

    haxe hsj-final.hxml

(Re)building library.swf containing resources/assets:

    ./makelib

(On systems without a bash-like shell, you will have to manually run __swfmill__ and also create the __LibraryClasses.hx__ file for declaring classes.)

### Bundled programs

- a slightly modified version of the swfmill XML generator
  - [Homepage](http://www.cactusflower.org/learning-flash-with-haxe#swfml_gen)
  - [Google code page](http://code.google.com/p/eduardonunespcodes/source/browse/trunk/actionscript/HaxeFlixel/?r=182)
- a slightly modified version of MemoryTracker from libs4hx
  - [Google code page](http://code.google.com/p/libs4hx/source/browse/trunk/lib/me/cunity/debug/MemoryTracker.hx?spec=svn50&r=50)
- a slightly modified version of the haXe version of SWFProfiler
  - [haXe page](http://haxe.org/doc/snip/swfprofiler) (the actual homepage seems to be down)
- the TweenerHX library 1,33,74
  - [haXe page](http://lib.haxe.org/p/TweenerHX) (the actual homepage seems to be down)