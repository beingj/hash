if {![package vsatisfies [package provide Tcl] 8.2]} {return}
package ifneeded md2 0.0 [list load [file join $dir md2[info sharedlibextension]] md2]
