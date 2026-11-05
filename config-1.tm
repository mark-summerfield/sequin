# Copyright © 2026 Mark Summerfield. All rights reserved.

package require inifile
package require util

# Also handles tk scaling & UIF (user interface font)
oo::singleton create Config {
    variable Filename
    variable Blinking
    variable Geometry
    variable LastFile
    variable HiddenToolbars
}

oo::define Config constructor {{appname {}}} {
    set Filename [util::get_ini_filename \
            [expr {$appname ne "" ? $appname : [tk appname]}]]
    set Blinking 1
    set Geometry ""
    set LastFile ""
    set HiddenToolbars [list]
    if {[file exists $Filename] && [file size $Filename]} {
        set ini [ini::open $Filename -encoding utf-8 r]
        try {
            tk scaling [ini::value $ini General Scale [tk scaling]]
            if {![set Blinking [ini::value $ini General Blinking \
                    $Blinking]]} {
                option add *insertOffTime 0
                ttk::style configure . -insertofftime 0
            }
            set Geometry [ini::value $ini General Geometry $Geometry]
            set ui_family [ini::value $ini General UIFfamily TkDefaultFont]
            set ui_default_size [font configure TkDefaultFont -size]
            set ui_size [ini::value $ini General UIFsize $ui_default_size]
            if {$ui_family ne "TkDefaultFont" || \
                    $ui_size != $ui_default_size} {
                font configure TkDefaultFont -family $ui_family \
                        -size $ui_size
            }
            set LastFile [ini::value $ini General LastFile \
                $LastFile]
            set HiddenToolbars [split [ini::value $ini General \
                    HiddenToolbars [join $HiddenToolbars]] " "]
        } on error err {
            puts "invalid config in '$Filename'; using defaults: $err"
        } finally {
            ini::close $ini
        }
    }
}

oo::define Config method save {} {
    set ini [ini::open $Filename -encoding utf-8 w]
    try {
        ini::set $ini General Scale [tk scaling]
        ini::set $ini General Blinking [my blinking]
        ini::set $ini General Geometry [wm geometry .]
        ini::set $ini General UIFfamily [font configure TkDefaultFont \
                                            -family]
        ini::set $ini General UIFsize [font configure TkDefaultFont -size]
        ini::set $ini General LastFile $LastFile
        ini::set $ini General HiddenToolbars [join $HiddenToolbars]
        ini::commit $ini
    } finally {
        ini::close $ini
    }
}

oo::define Config method filename {} { set Filename }
oo::define Config method set_filename filename { set Filename $filename }

oo::define Config method blinking {} { set Blinking }
oo::define Config method set_blinking blinking { set Blinking $blinking }

oo::define Config method geometry {} { set Geometry }
oo::define Config method set_geometry geometry { set Geometry $geometry }


oo::define Config method lastfile {} { set LastFile }
oo::define Config method set_lastfile lastfile {
    set LastFile $lastfile
}

oo::define Config method hidden_toolbars {} { return $HiddenToolbars }
oo::define Config method set_hidden_toolbars toolbars {
    set HiddenToolbars $toolbars ;# toolbars must be a list
}

oo::define Config method to_string {} {
    set family [font configure TkDefaultFont -family]
    set size [font configure TkDefaultFont -size]
    return "Config filename=$Filename blinking=$Blinking\
        scaling=[tk scaling] geometry=$Geometry fontfamily=$family\
        fontsize=$size lastfile=[my lastfile]\
        hidden_toolbars=$HiddenToolbars"
}
