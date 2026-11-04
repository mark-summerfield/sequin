# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require abstract_form
package require db
package require ui
package require util

oo::class create AboutForm {
    superclass AbstractForm

    variable Height
    variable Desc
    variable Url
    variable License
}

# Uses [tk appname] and $::VERSION and images/icon.svg
oo::define AboutForm constructor {desc {url ""} {license GPLv3}} {
    set Desc $desc
    set Url $url
    set License $license
    set Height [expr {12 + [regexp -all \n $desc]}]
    my make_widgets
    my make_layout
    my make_bindings
    next .aboutForm [callback on_close]
    my show_modal .aboutForm.frame.closeButton
}

oo::define AboutForm method make_widgets {} {
    tk::toplevel .aboutForm
    wm title .aboutForm "[tk appname] — About"
    wm resizable .aboutForm 0 0
    ttk::frame .aboutForm.frame
    set background [ttk::style lookup TFrame -background]
    tk::text .aboutForm.frame.text -width 50 \
        -wrap word -spacing1 3 -spacing3 3 -relief flat \
        -background $background
    my Populate
    .aboutForm.frame.text configure -state disabled -height $Height
    ttk::button .aboutForm.frame.closeButton -text Close \
        -compound left -command [callback on_close] \
        -image [ui::icon close.svg $::ICON_SIZE]
}

oo::define AboutForm method make_layout {} {
    pack .aboutForm.frame.text -side top -fill both -expand 1 -pady 3
    pack .aboutForm.frame.closeButton -side bottom -pady 6
    pack .aboutForm.frame -fill both -expand 1 -pady 6
}

oo::define AboutForm method make_bindings {} {
    bind .aboutForm <Escape> [callback on_close]
    bind .aboutForm <Return> [callback on_close]
    .aboutForm.frame.text tag bind url <Double-1> \
        [callback on_click_url @%x,%y]
}

oo::define AboutForm method on_click_url index {
    set indexes [.aboutForm.frame.text tag prevrange url $index]
    if {[set url [string trim [.aboutForm.frame.text get {*}$indexes]]] \
            ne ""} {
        if {![string match -nocase http*://* $url]} {
            set url [string cat http:// $url]
        }
        util::open_url $url
    }
}

oo::define AboutForm method on_close {} { my delete }

oo::define AboutForm method Populate {} {
    set txt .aboutForm.frame.text
    my AddTextTags $txt
    set img [$txt image create end -align center \
             -image [ui::icon icon.svg 64]]
    $txt tag add spaceabove $img
    $txt tag add center $img
    set add [list $txt insert end]
    {*}$add "\n[tk appname] $::VERSION\n" {center title}
    {*}$add "$Desc.\n\n" {center navy}
    if {[set year [clock format [clock seconds] -format %Y]] > 2026} {
        set year "2026-[string range $year end-1 end]"
    }
    set bits [expr {8 * $::tcl_platform(wordSize)}]
    if {[tk windowingsystem] eq "x11"} {
        catch {
            set distro [exec lsb_release -ds]
            incr Height
        }
    }
    if {$Url ne ""} {
        {*}$add "$Url\n" {center green url}
        incr Height
    }
    {*}$add "Copyright © $year Mark Summerfield.\nAll\
        Rights Reserved.\n" {center green}
    {*}$add "License: $License.\n" {center green}
    {*}$add "[string repeat " " 60]\n" {center hr}
    {*}$add "Tcl/Tk $::tcl_patchLevel (${bits}-bit)\n" center
    {*}$add [db::sqlite_version]\n center
    if {[info exists distro] && $distro != ""} {
        {*}$add "$distro\n" center
        incr Height
    }
    {*}$add "$::tcl_platform(os) $::tcl_platform(osVersion)\
        ($::tcl_platform(machine))\n" center
}

oo::define AboutForm method AddTextTags txt {
    set margin 12
    $txt configure -font TkTextFont
    set cmd [list $txt tag configure]
    {*}$cmd spaceabove -spacing1 6
    {*}$cmd margins -lmargin1 $margin -lmargin2 $margin -rmargin $margin
    {*}$cmd center -justify center
    {*}$cmd title -foreground navy -font H1
    {*}$cmd gray -foreground gray
    {*}$cmd navy -foreground navy
    {*}$cmd green -foreground darkgreen
    {*}$cmd bold -font bold
    {*}$cmd italic -font italic
    {*}$cmd url -underline 1 -underlinefg darkgreen
    {*}$cmd hr -overstrike 1 -overstrikefg gray67 -spacing3 10
}
