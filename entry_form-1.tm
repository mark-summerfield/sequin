# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require abstract_form
package require ref
package require ui

oo::class create EntryForm {
    superclass AbstractForm

    variable Reply
    variable Disallowed
}

oo::define EntryForm classmethod show {title body_text {disallowed {}} \
        {default ""}} {
    set reply [Ref new ""]
    set form [EntryForm new $reply $title $body_text $disallowed $default]
    tkwait window .entry_form
    $reply get
}

oo::define EntryForm constructor {reply title body_text disallowed \
        default} {
    set Reply $reply
    set Disallowed $disallowed
    my make_widgets $title $body_text
    my make_layout
    my make_bindings
    next .entry_form [callback on_done 0]
    if {$default ne ""} {
        .entry_form.mf.entry insert 0 $default
        .entry_form.mf.entry selection range 0 end
    }
    my show_modal .entry_form.mf.entry
}

oo::define EntryForm method make_widgets {title body_text} {
    if {[info exists ::ICON_SIZE]} {
        set size $::ICON_SIZE
    } else {
        set size [expr {max(24, round(16 * [tk scaling]))}]
    }
    tk::toplevel .entry_form
    wm resizable .entry_form 0 0
    wm title .entry_form $title
    ttk::frame .entry_form.mf
    ttk::label .entry_form.mf.label -text $body_text
    ttk::entry .entry_form.mf.entry -validate key \
        -validatecommand [callback on_validate %P]
    ui::apply_edit_bindings .entry_form.mf.entry
    ttk::frame .entry_form.mf.bf
    ttk::button .entry_form.mf.bf.ok_button -text OK \
        -underline 0 -compound left -command [callback on_done 1] \
        -image [ui::icon ok.svg $size] -state disabled
    ttk::button .entry_form.mf.bf.cancel_button -text Cancel \
        -underline 0 -compound left -command [callback on_done 0] \
        -image [ui::icon close.svg $size]
}

oo::define EntryForm method make_layout {} {
    set opts "-padx 3 -pady 3"
    pack .entry_form.mf.label -fill both -expand 1 {*}$opts
    pack .entry_form.mf.entry -fill x -expand 1 {*}$opts
    pack .entry_form.mf.bf -side bottom -fill x -expand 1 {*}$opts
    pack .entry_form.mf.bf.ok_button -side left {*}$opts
    pack .entry_form.mf.bf.cancel_button -side right {*}$opts
    pack .entry_form.mf -fill both -expand 1
}

oo::define EntryForm method make_bindings {} {
    bind .entry_form <Escape> {.entry_form.mf.bf.cancel_button invoke}
    bind .entry_form <Return> {.entry_form.mf.bf.ok_button invoke}
    bind .entry_form <Alt-o> {.entry_form.mf.bf.ok_button invoke}
    bind .entry_form <Alt-c> {.entry_form.mf.bf.cancel_button invoke}
}

oo::define EntryForm method on_validate txt {
    set txt [string tolower [string trim $txt]]
    if {$txt ne "" && $txt ni $Disallowed} {
        .entry_form.mf.bf.ok_button configure -state normal
        .entry_form.mf.entry configure -foreground black
    } else {
        .entry_form.mf.bf.ok_button configure -state disabled
        .entry_form.mf.entry configure -foreground red
    }
    return 1
}

oo::define EntryForm method on_done ok {
    if {$ok} { $Reply set [string trim [.entry_form.mf.entry get]] }
    my delete
}
