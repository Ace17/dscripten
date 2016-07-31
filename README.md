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

  ```
  $ ./fetch_toolchains
  ```

  This will take some time, as we need to build LLVM ... twice.

* Add some directories to your PATH

  First, the python 'emcc' tools
  ```
  $ export PATH=/tmp/toolchains/emscripten:$PATH
  ```

  Then, the JSBackend LLVM 3.9svn toolchain (aka 'fastcomp') (used by emscripten)
  ```
  $ export PATH=/tmp/toolchains/llvm-js/bin:$PATH
  ```

  Then, the native LLVM 3.7 toolchain (here live ldc2 and llvm-cbe)
  ```
  $ export PATH=/tmp/toolchains/llvm-native/bin:$PATH
  ```

* Check your PATH:

  Here's what you should get:

  ```
  $ which -a llvm-config                                                                                                                                                                                                                                                                ~/projects/dscripten
  /tmp/toolchains/llvm-js/bin/llvm-config
  /tmp/toolchains/llvm-native/bin/llvm-config
  ```

  If the llvm-config don't appear in this order, emcc will not work.

* Run make

  ```
  $ make
  ```

  (If it fails, try removing ~/.emscripten (or setting EM_CONFIG to anything else))

* Enjoy the result:

  ```
  $ firefox bin/full.html
  ```

