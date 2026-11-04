# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require abstract_form
package require ref
package require ui

oo::class create MaybeSaveForm {
    superclass AbstractForm

    variable Reply
}

# Returns save | dontsave | cancel
oo::define MaybeSaveForm classmethod show {title body_text} {
    set reply [Ref new save]
    set form [MaybeSaveForm new $reply $title $body_text]
    tkwait window .maybe_save_form
    $reply get
}

oo::define MaybeSaveForm constructor {reply title body_text} {
    set Reply $reply
    my make_widgets $title $body_text
    my make_layout
    my make_bindings
    next .maybe_save_form [callback on_done cancel]
    my show_modal .maybe_save_form.frame.save_button
}

oo::define MaybeSaveForm method make_widgets {title body_text} {
    if {[info exists ::ICON_SIZE]} {
        set size $::ICON_SIZE
    } else {
        set size [expr {max(24, round(16 * [tk scaling]))}]
    }
    tk::toplevel .maybe_save_form
    wm resizable .maybe_save_form 0 0
    wm title .maybe_save_form $title
    ttk::frame .maybe_save_form.frame
    ttk::label .maybe_save_form.frame.label -text $body_text \
        -anchor center -compound left -padding 3 \
        -image [ui::icon help.svg [expr {2 * $::ICON_SIZE}]]
    ttk::button .maybe_save_form.frame.save_button -text Save \
        -underline 0 -command [callback on_done save] -compound left \
        -image [ui::icon document-save.svg $size]
    ttk::button .maybe_save_form.frame.dontsave_button -text "Don't Save" \
        -underline 0 -command [callback on_done dontsave] -compound left \
        -image [ui::icon edit-clear.svg $size]
    ttk::button .maybe_save_form.frame.cancel_button -text Cancel \
        -underline 0 -command [callback on_done cancel] -compound left \
        -image [ui::icon gtk-cancel.svg $size]
}

oo::define MaybeSaveForm method make_layout {} {
    set opts "-padx 3 -pady 3"
    pack .maybe_save_form.frame.label -side top -fill both -expand 1 \
            {*}$opts
    pack .maybe_save_form.frame.save_button -side left -anchor e {*}$opts
    pack .maybe_save_form.frame.dontsave_button -side left -anchor e \
            {*}$opts
    pack .maybe_save_form.frame.cancel_button -side left -anchor w {*}$opts
    pack .maybe_save_form.frame -fill both -expand 1
}

oo::define MaybeSaveForm method make_bindings {} {
    bind .maybe_save_form <Return> [callback on_done save]
    bind .maybe_save_form <Alt-s> [callback on_done save]
    bind .maybe_save_form <Alt-d> [callback on_done dontsave]
    bind .maybe_save_form <Escape> [callback on_done cancel]
    bind .maybe_save_form <Alt-c> [callback on_done cancel]
}

oo::define MaybeSaveForm method on_done action {
    $Reply set $action
    my delete
}
