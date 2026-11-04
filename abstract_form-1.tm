# Copyright © 2025-26 Mark Summerfield. All rights reserved.

oo::abstract create AbstractForm { variable Form }

oo::define AbstractForm constructor {form on_close {modal 1}} {
    set Form $form
    wm withdraw $Form
    if {[tk windowingsystem] eq "x11"} { wm attributes $Form -type dialog }
    if {$modal} { wm transient $Form . }
    wm group $Form .
    set parent [winfo parent $Form]
    set x [expr {[winfo x $parent] + ([winfo width $parent] / 5)}]
    set y [expr {[winfo y $parent] + ([winfo height $parent] / 5)}]
    wm geometry $Form +$x+$y
    wm protocol $Form WM_DELETE_WINDOW $on_close
}

oo::define AbstractForm method form {} { set Form }

oo::define AbstractForm method show_modal {{focus_widget ""}} {
    wm deiconify $Form
    update idletasks
    grab set $Form
    raise $Form
    update idletasks
    my MaybeMove
    focus $Form
    if {$focus_widget ne ""} { focus $focus_widget }
}

oo::define AbstractForm method show_modeless {{focus_widget ""}} {
    wm deiconify $Form
    raise $Form
    update idletasks
    my MaybeMove
    focus $Form
    if {$focus_widget ne ""} { focus $focus_widget }
}

oo::define AbstractForm method delete {} {
    grab release $Form
    destroy $Form
}

oo::define AbstractForm method hide {} {
    grab release $Form
    wm withdraw $Form
}

oo::define AbstractForm method MaybeMove {} {
    if {[set xdiff [expr {[winfo screenwidth .] - \
            ([winfo x $Form] + [winfo reqwidth $Form])}]] < 0} {
        wm geometry $Form +[expr {[winfo x $Form] + $xdiff - 20}]+[winfo y \
                $Form]
    }
}
