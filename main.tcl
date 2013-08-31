array set APP {
    name hash
    version 0.3
    date 2013/8/27
    author beingj@gmail.com
}

lappend auto_path [file join [file dirname [info script]] lib]
package require md2
package require md5
package require sha1
package require aes

proc ui {} {
    global APP
    global ui_var

    foreach {i} [winfo children .] {
        destroy $i
    }
    
    wm withdraw .
    wm title . "$APP(name) $APP(version) $APP(date)"
    
    set fr .f0
    ttk::frame $fr
    pack $fr -fill x -expand 1 -padx 5 -pady 5
    
    set ui_var(input) [text $fr.t1]
    pack $ui_var(input) -fill both -expand 1
    
    set fr .f1
    ttk::frame $fr
    pack $fr -fill x -expand 0 -padx 5 -pady 2

    set hashs {
        ascii ASCII
        md2 MD2
        md5 MD5
        hmac_sha1 HMAC-SHA1
        aes_cbc_encrypt AES-CBC-128(encrypt)
        aes_cbc_decrypt AES-CBC-128(decrypt)
    }
    set n 0
    foreach {i j} $hashs {
        ttk::radiobutton $fr.rb$n -text $j -variable ui_var(hash) -value $i
        pack $fr.rb$n  -side left -fill y -expand 0 
        incr n
    }
    set ui_var(go) [ttk::button $fr.go -text "GO" -command on_go]
    pack $ui_var(go) -side right -fill y -expand 0 
    
    set fr .f2
    ttk::frame $fr
    pack $fr -fill x -expand 1 -padx 5 -pady 2
    
    set ele {
        Key key key_entry
        IV iv iv_entry
    }
    set i 1
    foreach {text textvar ui} $ele {
        ttk::label $fr.l$text -text $text
        set ui_var($ui) [ttk::entry $fr.$ui  -textvariable ui_var($textvar)]
        grid $fr.l$text -row [expr $i-1] -column 0  -rowspan 1 -columnspan 1 -sticky news -padx 3 -pady 2
        grid $fr.$ui    -row [expr $i-1] -column 1  -rowspan 1 -columnspan 1 -sticky news -padx 3 -pady 2
        incr i
    }
	grid columnconfig $fr 1 -weight 1 -minsize 0   
    
    set fr .f3
    ttk::frame $fr
    pack $fr -fill x -expand 1 -padx 5 -pady 5
    set ui_var(output) [text $fr.t1]
    pack $ui_var(output) -fill both -expand 0
    
    trace add variable ui_var(hash) write on_hash_change
    $ui_var(input) configure -width 60 -height 10
    $ui_var(output) configure -width 60 -height 10
    set ui_var(hash) ascii
    
    input "input window"
    output "output window"

    update
    wm deiconify .
    wm resizable . 0 0
    bind . <Control-F12> [list console show]
}

proc on_hash_change {args} {
    global ui_var
    if {$ui_var(hash) == "hmac_sha1"} {
        $ui_var(key_entry) configure -state normal
        $ui_var(iv_entry) configure -state disabled
    } elseif {$ui_var(hash) == "aes_cbc_encrypt" || $ui_var(hash) == "aes_cbc_decrypt"} {
        $ui_var(key_entry) configure -state normal
        $ui_var(iv_entry) configure -state normal
    } else {
        $ui_var(key_entry) configure -state disabled
        $ui_var(iv_entry) configure -state disabled
    }
}

proc on_go {} {
    clear_output
    set data [get_data_from_input]
    set res [hash_data $data]
    output $res
}

proc get_data_from_input {} {
    global ui_var
    set data [$ui_var(input) get 1.0 end]
    if {$ui_var(hash) == "ascii"} {
        return [string trim $data]
    }
    # 0000   9f 83 44 9e 81 56 95 6c 4d fa 0d 77 08 96 7d b4
    set res_list [list]
    foreach {i} [split $data \n] {
        set i [string trim $i]
        foreach {j} $i {
            if {[string length $j] == 2} {
                lappend res_list $j
            }
        }
    }
    return $res_list
}

proc hash_data {data} {
    global ui_var
    set res "ERROR: can not hash data with $ui_var(hash)"
    switch -- $ui_var(hash) {
        "ascii" {
            set res [c2a $data]
        }
        "md2" {
            set res [bin2hexlst [calc_auth_code_md2 [hexlst2bin $data]]]
        }
        "md5" {
            set res [bin2hexlst [calc_auth_code_md5 [hexlst2bin $data]]]
        }
        "hmac_sha1" {
            set res [hmac_sha1 [hexlst2bin $ui_var(key)] [hexlst2bin $data]]
        }
        "aes_cbc_encrypt" {
            set res [aes_cbc encrypt [hexlst2bin $ui_var(key)] [hexlst2bin $ui_var(iv)] [hexlst2bin $data]]
        }
        "aes_cbc_decrypt" {
            set res [aes_cbc decrypt [hexlst2bin $ui_var(key)] [hexlst2bin $ui_var(iv)] [hexlst2bin $data]]
        }
    }
    return $res
}

proc c2a {data} {
    set res [list]
    foreach {i} [split $data ""] {
        lappend res [_c2a $i]
    }
    return $res
}

proc _c2a {character} {
	binary scan $character H2 hex
	set ascii [string toupper $hex]	
	return $ascii
}

proc calc_auth_code_md2 {bin} {
    return [::md2::md2 $bin]
}

proc calc_auth_code_md5 {bin} {
    return [::md5::md5 $bin]
}

proc hmac_sha1 {bin_key bin_data} {
    # ::sha1::hmac [padbin [hexlst2bin 33]] [hexlst2bin {20 18 c8 81 04 3b 04 3c}]
    # ==> 6283aa4045a0021078530f1d30f4ff8d85d9466a ==> 20 bytes
    return [split_hex [::sha1::hmac -- $bin_key $bin_data]]
}

proc aes_cbc {dir bin_key bin_iv bin_data} {
    # ::aes::aes -hex -mode cbc -dir encrypt -key [string repeat 3 16] -iv [string repeat 3 16] 12345
    # ==> 695cffa08590886a5c59084cc542542d ==> 16 bytes
    return [split_hex [::aes::aes -hex -mode cbc -dir $dir -key $bin_key -iv $bin_iv -- $bin_data]]
}

proc split_hex {hex} {
	set hexlst [list]
	for {set i 0} {$i<[expr [string length $hex]/2]} {incr i} {
		lappend hexlst [string range $hex [expr $i*2] [expr $i*2+1]]
	}
	return $hexlst
}

proc bin2hexlst {bin} {
	binary scan $bin H* hex
	set hexlst [list]
	for {set i 0} {$i<[expr [string length $hex]/2]} {incr i} {
		lappend hexlst [string range $hex [expr $i*2] [expr $i*2+1]]
	}
	return $hexlst
}

proc hexlst2bin {hexlst} {
	return [hexlst2bin0 [format_hexlst $hexlst]]
}

proc hexlst2bin0 {hexlst} {
	return [binary format H* [join $hexlst ""]]
}

proc format_hexlst {hexlst} {
	set hexlst2 [list]
	foreach hex $hexlst {
		lappend hexlst2 [format %02s $hex]
	}
	return $hexlst2
}

proc clear_output {} {
    global ui_var
    $ui_var(output) delete 1.0 end
}

proc input {msg} {
    global ui_var
    $ui_var(input) insert end $msg
}

proc output {msg} {
    global ui_var
    $ui_var(output) insert end $msg
}

ui
