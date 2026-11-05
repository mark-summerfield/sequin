# Copyright © 2026 Mark Summerfield. All rights reserved.

package require about_form
package require config
package require config_form
package require flowrow
package require mdi
package require ref
package require sqlite3 3
package require ui

const SHORT_TIMEOUT 10_000
const LONG_TIMEOUT 30_000

oo::singleton create App {
    variable Db ;# SQLite database
    variable Filename ;# SQLite filename
    variable Toolbars
    variable MdiArea
    variable StatusLabel
}

oo::define App constructor {} {
    ui::wishinit
    tk appname $::APPNAME
    set Db ""
    set Filename [expr {$::argc ? [lindex $::argv 0] : ""}]
    if {$Filename eq ""} { set Filename [[Config new] lastfile] }
    set Toolbars {}
    my make_ui
}

oo::define App method show {} {
    wm deiconify .
    set config [Config new]
    wm geometry . [$config geometry]
    raise .
    update idletasks
    my on_startup
}

oo::define App method on_startup {} {
    set config [Config new]
    $Toolbars hide_toolbars {*}[$config hidden_toolbars]
    update idletasks
    if {$Filename ne ""} { my file_open }
}

oo::define App method make_ui {} {
    my prepare_ui
    ttk::frame .mf
    my make_toolbars
    my make_widgets
    my make_menus
    my make_layout
    my make_bindings
}

oo::define App method prepare_ui {} {
    wm title . [tk appname]
    wm iconname . [tk appname]
    wm iconphoto . -default [ui::icon icon.svg]
    wm minsize . 640 480
}

oo::define App method make_toolbars {} {
    set Toolbars [Flowrow new .mf.tb]
    my make_file_toolbar
    # TODO
}

oo::define App method make_menus {} {
    menu .menu
    . configure -menu .menu
    my make_file_menu
    # TODO other menus…
    $MdiArea new_window_menu .menu
}

oo::define App method make_file_menu {} {
    menu .menu.file
    .menu add cascade -menu .menu.file -label File -underline 0
    .menu.file add command -command [callback on_file_open] -label Open… \
            -underline 0 -accelerator Ctrl+O -compound left \
            -image [ui::icon document-open.svg $::MENU_ICON_SIZE]
    .menu.file add separator
    # TODO other toolbars…
    $Toolbars new_menu .menu.file {File} \
            [ui::icon preferences-desktop.svg $::MENU_ICON_SIZE]
    .menu.file add command -command [callback on_config] -label Config… \
            -underline 0 -compound left \
            -image [ui::icon preferences-system.svg $::MENU_ICON_SIZE]
    .menu.file add command -command [callback on_about] -label About \
            -underline 1 -compound left \
            -image [ui::icon about.svg $::MENU_ICON_SIZE]
    .menu.file add separator
    .menu.file add command -command [callback on_quit] -label Quit \
            -underline 0 -accelerator Ctrl+Q -compound left \
            -image [ui::icon quit.svg $::MENU_ICON_SIZE]
}

oo::define App method make_file_toolbar {} {
    set tip tooltip::tooltip
    ttk::frame .mf.tb.file
    ttk::button .mf.tb.file.file_open -style Toolbutton \
            -command [callback on_file_open] \
            -image [ui::icon document-open.svg $::ICON_SIZE]
    $tip .mf.tb.file.file_open "File Open"
    $Toolbars add_toolbar .mf.tb.file
}

oo::define App method make_widgets {} {
    set MdiArea [mdi::Area new .mf.mdi]
    ttk::frame .mf.sf
    set StatusLabel [ttk::label .mf.sf.statusLabel]
}

oo::define App method make_layout {} {
    const opts "-pady 3 -padx 3"
    grid .mf.tb -row 0 -column 0 -sticky we {*}$opts
    grid .mf.mdi -row 1 -column 0 -sticky news {*}$opts
    grid .mf.sf -row 2 -column 0 -sticky we {*}$opts
    pack .mf.sf.statusLabel -expand 1 -fill x {*}$opts
    grid rowconfigure .mf 1 -weight 1
    grid columnconfigure .mf 0 -weight 1
    pack .mf -fill both -expand 1
}

oo::define App method make_bindings {} {
    bind [$MdiArea frame] <<MdiTileError>> [callback on_tile_error %d]
    bind . <Control-o> [callback on_file_open]
    bind . <Control-q> [callback on_quit]
    wm protocol . WM_DELETE_WINDOW [callback on_quit]
}

oo::define App method show_message {msg {timeout short}} {
    $StatusLabel configure -text $msg -foreground navy
    set timeout [expr {$timeout eq "short" ? $::SHORT_TIMEOUT \
                                           : $::LONG_TIMEOUT}]
    after $timeout [callback clear_status]
}

oo::define App method show_error err {
    $StatusLabel configure -text $err -foreground red
    after $::LONG_TIMEOUT [callback clear_status]
}

oo::define App method clear_status {} { $StatusLabel configure -text "" }

oo::define App method on_config {} {
    set config [Config new]
    set ok [Ref new 0]
    set form [ConfigForm new $ok]
    tkwait window [$form form]
    if {[$ok get]} {
        # pass
    }
}

oo::define App method on_about {} {
    AboutForm new "A read-only SQLite viewer" \
        https://github.com/mark-summerfield/sequin
}

oo::define App method on_quit {} {
    my save_config
    my file_close
    exit
}

oo::define App method save_config {} {
    set hidden_toolbars [list]
    dict for {toolbar show} [$Toolbars toolbars] {
        if {!$show} { lappend hidden_toolbars $toolbar }
    }
    set config [Config new]
    $config set_hidden_toolbars $hidden_toolbars
    $config set_lastfile [file normalize $Filename]
    $config save
}

oo::define App method on_tile_error message {
    my show_message "$message; cascading instead"
    $MdiArea cascade
}

oo::define App method on_file_open {} {
    set dir [expr {$Filename eq "" ? [file home] \
                                   : [file dirname $Filename]}]
    my file_close
    if {[set filename [tk_getOpenFile -initialdir $dir \
            -filetypes {{{SQLite files} {*.sqlite}} {{All files} {*}}} \
            -title "[tk appname] — Open" -parent .]] ne ""} {
        set Filename $filename
        my file_open
    }
}

oo::define App method file_close {} {
    if {$Filename ne ""} {
        $MdiArea close_all
        $Db close
        set Db ""
        set Filename ""
        wm title . [tk appname]
    }
}

oo::define App method file_open {} {
    sqlite3 $Db $Filename -nomutex 1 -readonly 1
    wm title . "[tk appname] — [file tail $Filename]"
    set version [$Db onecolumn "PRAGMA USER_VERSION"]
    my show_message "Opened $Filename[expr {$version ? " (v$version)" \
                                                     : ""}]"
}
