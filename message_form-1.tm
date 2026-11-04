# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require abstract_form
package require ui

oo::class create MessageForm { superclass AbstractForm }

# kind must be one of: info warning error

oo::define MessageForm classmethod show {title body_text {button_text OK} \
        {kind info}} {
    set form [MessageForm new $title $body_text $button_text \
                $kind]
    tkwait window .message_form
}

oo::define MessageForm constructor {title body_text button_text kind} {
    my make_widgets $title $body_text $button_text $kind
    my make_layout
    my make_bindings $button_text
    next .message_form [callback on_done]
    my show_modal .message_form.mf.the_button
}

oo::define MessageForm method make_widgets {title body_text button_text \
        kind} {
    if {[info exists ::ICON_SIZE]} {
        set size $::ICON_SIZE
    } else {
        set size [expr {max(24, round(16 * [tk scaling]))}]
    }
    switch $kind {
        info    { set color gray92 }
        warning { set color lightyellow }
        error   { set color pink }
    }
    tk::toplevel .message_form
    wm resizable .message_form 0 0
    wm title .message_form $title
    ttk::style configure MessageForm.TFrame -background $color
    ttk::frame .message_form.mf -style MessageForm.TFrame
    ttk::label .message_form.mf.label -text $body_text \
        -background $color -compound left \
        -image [ui::icon dialog-$kind.svg [expr {2 * $size}]]
    ttk::button .message_form.mf.the_button -text $button_text \
        -underline 0 -compound left -command [callback on_done] \
        -image [ui::icon close.svg $size]
}

oo::define MessageForm method make_layout {} {
    set opts "-padx 3 -pady 3"
    pack .message_form.mf.label -fill both -expand 1 {*}$opts
    pack .message_form.mf.the_button -side bottom {*}$opts
    pack .message_form.mf -fill both -expand 1
}

oo::define MessageForm method make_bindings kind {
    bind .message_form <Escape> [callback on_done]
    bind .message_form <Return> [callback on_done]
    bind .message_form \
        <Alt-[string tolower [string index $kind 0]]> [callback on_done]
}

oo::define MessageForm method on_done {} { my delete }
