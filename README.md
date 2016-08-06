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

* Add some directories to your PATH

  First, the native LLVM 3.8 toolchain (providing ldc2 and llvm-cbe)
  ```
  $ export PATH=/tmp/toolchains/llvm-native/bin:$PATH
  ```

  Then, the JSBackend LLVM 3.9svn toolchain (aka 'fastcomp') (used by emscripten)
  ```
  $ export PATH=/tmp/toolchains/llvm-js/bin:$PATH
  ```

  Finally, the python 'emcc' tools, which rely on the JSBackend LLVM toolchain
  ```
  $ export PATH=/tmp/toolchains/emscripten:$PATH
  ```

* Check your PATH:

  Here's what you should get:

  ```
  $ which -a llvm-config                                                                                                                                                                                                                                                                ~/projects/dscripten
  /tmp/toolchains/llvm-js/bin/llvm-config
  /tmp/toolchains/llvm-native/bin/llvm-config
  ```

  If the llvm-config don't appear in this order, emcc will not work.

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

