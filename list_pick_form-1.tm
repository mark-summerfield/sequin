# Copyright © 2026 Mark Summerfield. All rights reserved.

package require abstract_form
package require ref
package require ui

oo::class create ListPickForm {
    superclass AbstractForm

    variable Reply
}

# Returns "" or an element from the given list
oo::define ListPickForm classmethod show {title body_text lst} {
    set reply [Ref new ""]
    set form [ListPickForm new $reply $title $body_text $lst]
    tkwait window .list_pick_form
    $reply get
}

oo::define ListPickForm constructor {reply title body_text lst} {
    set Reply $reply
    my make_widgets $title $body_text $lst
    my make_layout
    my make_bindings
    next .list_pick_form [callback on_cancel]
    my show_modal .list_pick_form.mf.combobox
}

oo::define ListPickForm method make_widgets {title body_text lst} {
    if {[info exists ::ICON_SIZE]} {
        set size $::ICON_SIZE
    } else {
        set size [expr {max(24, round(16 * [tk scaling]))}]
    }
    tk::toplevel .list_pick_form
    wm resizable .list_pick_form 0 0
    wm title .list_pick_form $title
    ttk::frame .list_pick_form.mf
    ttk::label .list_pick_form.mf.label -text $body_text -anchor center \
        -compound left -padding 3 \
        -image [ui::icon help.svg [expr {2 * $::ICON_SIZE}]]
    ttk::combobox .list_pick_form.mf.combobox -values $lst -state readonly
    .list_pick_form.mf.combobox set [lindex $lst 0]
    ttk::button .list_pick_form.mf.ok_button -text OK -underline 0 \
        -command [callback on_ok] -compound left \
        -image [ui::icon ok.svg $size]
    ttk::button .list_pick_form.mf.cancel_button -text Cancel \
        -underline 0 -command [callback on_cancel] -compound left \
        -image [ui::icon gtk-cancel.svg $size]
}

oo::define ListPickForm method make_layout {} {
    set opts "-padx 3 -pady 3"
    grid .list_pick_form.mf.label -row 0 -column 0 -columnspan 2 \
            -sticky news {*}$opts
    grid .list_pick_form.mf.combobox -row 1 -column 0 -columnspan 2 \
            -sticky news {*}$opts
    grid .list_pick_form.mf.ok_button -row 2 -column 0 -sticky e {*}$opts
    grid .list_pick_form.mf.cancel_button -row 2 -column 1 -sticky w \
            {*}$opts
    grid rowconfigure .list_pick_form 0 -weight 1
    grid rowconfigure .list_pick_form 1 -weight 1
    grid columnconfigure .list_pick_form 0 -weight 1
    grid columnconfigure .list_pick_form 1 -weight 1
    pack .list_pick_form.mf -fill both -expand 1
}

oo::define ListPickForm method make_bindings {} {
    bind .list_pick_form <Escape> [callback on_cancel]
    bind .list_pick_form <Return> [callback on_ok]
    bind .list_pick_form <c> [callback on_cancel]
    bind .list_pick_form <Alt-C> [callback on_cancel]
    bind .list_pick_form <o> [callback on_ok]
    bind .list_pick_form <Alt-O> [callback on_ok]
}

oo::define ListPickForm method on_ok {} {
    $Reply set [.list_pick_form.mf.combobox get]
    my delete
}

oo::define ListPickForm method on_cancel {} { my delete }
