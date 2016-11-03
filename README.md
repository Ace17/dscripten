# dscripten
An example of D to asmjs using Emscripten

Authors
=======

- Ace17 (Sebastien Alaiwan: sebastien.alaiwan@gmail.com)

Purpose
=======

  This is a demonstration on how D code can be compiled to Javascript using
  a combination of existing tools.

Demo
====

  You can try an online demo here: http://code.alaiwan.org/dscripten/full.html

Usage
-----

* Fetch and build the toolchains

  ```
  $ ./fetch_toolchains
  ```

  This will take some time, as we need to build LLVM ... twice.

* Now configure emscripten.
  This will create a '.emscripten' configuration file in your home,
  containing the path to LLVM 3.9svn (aka 'fastcomp', which implements the JSBackend).
  "emcc" will use this path to find its Javascript-enabled clang and llc.

  ```
  rm -f ~/.emscripten
  EMMAKEN_JUST_CONFIGURE=1 PATH=/tmp/toolchains/llvm-js/bin:$PATH /tmp/toolchains/emscripten/emcc
  ```

* Add some directories to your PATH

  First, add the python 'emcc' tool family, which relies on the JSBackend LLVM toolchain
  ```
  $ export PATH=/tmp/toolchains/emscripten:$PATH
  ```

  Then, the native LLVM 3.9 toolchain (providing ldc2 and llvm-cbe)
  ```
  $ export PATH=/tmp/toolchains/llvm-native/bin:$PATH
  ```

* Check your PATH:

  Here's what you should get:

  ```
  $ which -a llvm-config
  /tmp/toolchains/llvm-native/bin/llvm-config
  ```

  If you have more than one llvm-config appearing in this list, you're asking
  for trouble and the build might not work.

* Run the build script (it just sets some variables before calling the makefile)

  ```
  $ ./build_asmjs
  ```

  (If it fails, try removing ~/.emscripten (or setting EM_CONFIG to anything else))

* Enjoy the result:

  ```
  $ firefox bin/asmjs/full.html
  ```

* You can also play the native version:

  ```
  $ ./build_native
  $ ./bin/native/full.exe
  ```

