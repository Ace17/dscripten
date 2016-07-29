# dscripten
An example of D to asmjs using Emscripten
 
Authors
=======

- Ace17 (Sebastien Alaiwan: sebastien.alaiwan@gmail.com)

Purpose
=======

  This is a demonstration on how D code can be compiled to Javascript using
  a combination of existing tools.

Usage
-----

* Fetch and build the toolchains

  $ ./fetch_toolchains

  This will take some time, as we need to build LLVM ... twice.

* Add some directories to your PATH

  $ export PATH=/tmp/emsd-source/emscripten:/tmp/toolchains/emsd/emscripten/bin:/tmp/toolchains/emsd/bin:$PATH

* Run make

  $ make

* Enjoy the result:

  $ firefox bin/index.html

