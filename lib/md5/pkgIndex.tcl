if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded md5 0.0 [list load [file join $dir md5[info sharedlibextension]] md5]
