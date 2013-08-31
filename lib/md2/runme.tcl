# file: runme.tcl
# Try to load as a dynamic module.

catch { load ./md2[info sharedlibextension] md2}
# # catch { load ./md2[info sharedlibextension]}
namespace eval md2 {namespace export *}
namespace import ::md2::*

proc md2c_try {} {
  foreach {msg expected} "
    {}
     8350e5a3e24c153df2275c9f80692773
    {a}
     32ec01ec4a6dac72c0ab96fb34c0b5d1
    {abc}
     da853b0d3f88d99b30283a69e6ded6bb
    {message digest}
     ab4f496bfb2a530b219ff33031fe06b0
    {abcdefghijklmnopqrstuvwxyz}
     4e8ddff3650292ab5a4108c3aa47940b
    {ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789}
     da33def2a42df13975352846c30338cd
    {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
     d5976f79d83d3a0dc9806c3c66f3efd8
    [binary format H* 00010200]
     d5f00f1d8ec04b1e41376b53cef54101
  " {
    puts "testing: md2 \"$msg\""
    binary scan [$::md2 $msg] H* computed
    # set computed [$::md2 $msg]
    puts "computed: $computed"
    if {0 != [string compare $computed $expected]} {
        puts "expected: $expected"
        puts "FAILED\n^^^^^^---------@@@@@@@---@@@@@@@--------------\n"
    } else {
        puts "PASS"
    }
  }

  if 1 {
  # foreach len {10 50 100 500 1000 5000 10000} 
  foreach len {10 50 100 500 } {
    set blanks [format %$len.0s ""]
    puts "input length $len: [time {$::md2 $blanks} 1000]"
  }
  }
}

# puts [md2 abc]
set md2 md2
md2c_try


