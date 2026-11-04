# Copyright © 2025-26 Mark Summerfield. All rights reserved.

namespace eval ui {}

proc ui::wishinit {} {
    wm withdraw .
    option add *tearOff 0
    ttk::style theme use clam
    set ::LINEHEIGHT [expr {[font metrics TkDefaultFont -linespace] * 1.5}]
    ttk::style configure Treeview -rowheight $::LINEHEIGHT
    ttk::style configure Treeview.Heading -font TkDefaultFont
    ttk::style configure TCheckbutton -indicatorsize \
        [expr {$::LINEHEIGHT * 0.75}]
    set ::ICON_SIZE [expr {max(20, round(16 * [tk scaling]))}]
    set ::MENU_ICON_SIZE [expr {max(16, round(12 * [tk scaling]))}]
}

proc ui::icon {svg {width 0}} {
    if {!$width} {
        return [image create photo -file $::APPPATH/images/$svg]
    }
    image create photo -file $::APPPATH/images/$svg \
        -format "svg -scaletowidth $width"
}

# Use for ttk::entry, ttk::combobox, and ttk::spinbox
proc ui::apply_edit_bindings widget {
    bind $widget <Control-Delete> { ui::on_ctrl_del %W ; break }
    bind $widget <Control-BackSpace> { ui::on_ctrl_bs %W ; break }
    bind $widget <Control-a> { ui::on_ctrl_a %W ; break }
}

proc ui::on_ctrl_del widget {
    set txt [$widget get]
    set i [$widget index insert]
    set j [expr {$i + 1}]
    while {$j < [string length $txt] && \
            [string is alnum [string index $txt $j]]} {
        incr j
    }
    $widget delete $i $j
}

proc ui::on_ctrl_bs widget {
    set txt [$widget get]
    set j [$widget index insert]
    set i [expr {$j - 1}]
    while {$i >= 0 && [string is alnum [string index $txt $i]]} {
        incr i -1
    }
    $widget delete $i $j
}

proc ui::on_ctrl_a widget { $widget selection range 0 end }

# Use for ttk::treeview
proc ui::apply_treeview_bindings widget {
    bind $widget <Home> { ui::on_treeview_home %W ; break }
    bind $widget <End> { ui::on_treeview_end %W ; break }
}

proc ui::on_treeview_home tree {
    if {[set children [$tree children {}]] ne {}} {
        set id [lindex $children 0]
        $tree selection set $id
        $tree see $id
        $tree focus $id
    }
}

proc ui::on_treeview_end tree {
    if {[set children [$tree children {}]] ne {}} {
        set id [lindex $children end]
        $tree selection set $id
        $tree see $id
        $tree focus $id
    }
}

proc ui::popup_menu {menu widget} {
    tk_popup $menu [expr {[winfo rootx $widget]}] \
        [expr {[winfo rooty $widget] + [winfo height $widget]}]
}
