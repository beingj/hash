# file: runme.tcl
# Try to load as a dynamic module.

catch { load ./md5[info sharedlibextension] md5}
# # catch { load ./md5[info sharedlibextension]}
namespace eval md5 {namespace export *}
namespace import ::md5::*

proc md5c_try {} {
  foreach {msg expected} "
    {}
    {d41d8cd98f00b204e9800998ecf8427e}
    {a}
    {0cc175b9c0f1b6a831c399e269772661}
    {abc}
    {900150983cd24fb0d6963f7d28e17f72}
    {message digest}
    {f96b697d7cb7938d525a2f31aaf161d0}
    {abcdefghijklmnopqrstuvwxyz}
    {c3fcd3d76192e4007dfb496cca67e13b}
    {ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789}
    {d174ab98d277d9f5a5611c2c9f419d9f}
    {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
    {57edf4a22be3c955ac49da2e2107b67a}
    [binary format H* 00010200]
    {0f0c725e025036e905dc2ed035406463}
  " {
    puts "testing: md5 \"$msg\""
    binary scan [$::md5 $msg] H* computed
    # set computed [$::md5 $msg]
    puts "computed: $computed"
    if {0 != [string compare $computed $expected]} {
        puts "expected: $expected"
        puts "FAILED\n^^^^^^---------@@@@@@@---@@@@@@@--------------\n"
    } else {
        puts "PASS"
    }
  }

  if 1 {
  foreach len {10 50 100 500 1000 5000 10000} {
  # foreach len {10 50 100 500 } 
    set blanks [format %$len.0s ""]
    puts "input length $len: [time {$::md5 $blanks} 1000]"
  }
  }
}

# puts [md5 abc]
set md5 md5
md5c_try


