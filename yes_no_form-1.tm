# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require abstract_form
package require ref
package require ui

oo::class create YesNoForm {
    superclass AbstractForm

    variable Reply
}

# Returns yes | no
oo::define YesNoForm classmethod show {title body_text {default yes}} {
    set reply [Ref new $default]
    set form [YesNoForm new $reply $title $body_text $default]
    tkwait window .yesno_form
    $reply get
}

oo::define YesNoForm constructor {reply title body_text default} {
    set Reply $reply
    my make_widgets $title $body_text
    my make_layout
    my make_bindings $default
    next .yesno_form [callback on_done no]
    my show_modal [expr {$default eq "yes" \
        ? {.yesno_form.frame.yes_button} \
        : {.yesno_form.frame.no_button}}]
}

oo::define YesNoForm method make_widgets {title body_text} {
    if {[info exists ::ICON_SIZE]} {
        set size $::ICON_SIZE
    } else {
        set size [expr {max(24, round(16 * [tk scaling]))}]
    }
    tk::toplevel .yesno_form
    wm resizable .yesno_form 0 0
    wm title .yesno_form $title
    ttk::frame .yesno_form.frame
    ttk::label .yesno_form.frame.label -text $body_text -anchor center \
        -compound left -padding 3 \
        -image [ui::icon help.svg [expr {2 * $::ICON_SIZE}]]
    ttk::button .yesno_form.frame.yes_button -text Yes -underline 0 \
        -command [callback on_done yes] -compound left \
        -image [ui::icon yes.svg $size]
    ttk::button .yesno_form.frame.no_button -text No -underline 0 \
        -command [callback on_done no] -compound left \
        -image [ui::icon no.svg $size]
}

oo::define YesNoForm method make_layout {} {
    set opts "-padx 3 -pady 3"
    grid .yesno_form.frame.label -row 0 -column 0 -columnspan 2 \
        -sticky news {*}$opts
    grid .yesno_form.frame.yes_button -row 1 -column 0 -sticky e {*}$opts
    grid .yesno_form.frame.no_button -row 1 -column 1 -sticky w {*}$opts
    grid rowconfigure .yesno_form 0 -weight 1
    grid columnconfigure .yesno_form 0 -weight 1
    grid columnconfigure .yesno_form 1 -weight 1
    pack .yesno_form.frame -fill both -expand 1
}

oo::define YesNoForm method make_bindings default {
    bind .yesno_form <Escape> [callback on_done no]
    if {$default eq "yes"} {
        bind .yesno_form <Return> [callback on_done yes]
    } else {
        bind .yesno_form <Return> [callback on_done no]
    }
    bind .yesno_form <n> [callback on_done no]
    bind .yesno_form <Alt-n> [callback on_done no]
    bind .yesno_form <y> [callback on_done yes]
    bind .yesno_form <Alt-y> [callback on_done yes]
}

oo::define YesNoForm method on_done action {
    $Reply set $action
    my delete
}
