# Copyright © 2026 Mark Summerfield. All rights reserved.

package require abstract_form
package require tooltip 2
package require ui

oo::class create ConfigForm {
    superclass AbstractForm

    variable Ok
    variable Blinking
    variable FontFamily
    variable FontSize
}

oo::define ConfigForm constructor ok {
    set Ok $ok
    set config [Config new]
    set Blinking [$config blinking]
    set FontFamily [$config family]
    set FontSize [$config size]
    my make_widgets 
    my make_layout
    my make_bindings
    next .configForm [callback on_cancel]
    my show_modal .configForm.mf.scaleSpinbox
}

oo::define ConfigForm method make_widgets {} {
    set config [Config new]
    tk::toplevel .configForm
    wm resizable .configForm 0 0
    wm title .configForm "[tk appname] — Options"
    ttk::frame .configForm.mf
    set tip tooltip::tooltip
    ttk::label .configForm.mf.scaleLabel -text "Application Scale" \
        -underline 12
    ttk::spinbox .configForm.mf.scaleSpinbox -format %.2f -from 1.0 \
        -to 10.0 -increment 0.1
    ui::apply_edit_bindings .configForm.mf.scaleSpinbox
    $tip .configForm.mf.scaleSpinbox "Application’s scale factor.\n\
        Restart to apply."
    .configForm.mf.scaleSpinbox set [format %.2f [tk scaling]]
    ttk::checkbutton .configForm.mf.blinkCheckbutton \
        -text "Cursor Blink" -underline 7 \
        -variable [my varname Blinking]
    if {$Blinking} { .configForm.mf.blinkCheckbutton state selected }
    $tip .configForm.mf.blinkCheckbutton \
        "Whether the text cursor should blink."
    set opts "-compound left -width 15"
    ttk::button .configForm.mf.fontButton -text Font… -underline 0 \
        -image [ui::icon preferences-desktop-font.svg $::ICON_SIZE] \
        -command [callback on_font] {*}$opts
    $tip .configForm.mf.fontButton "The font to use.\nBest to set the\
        application’s scale (and restart) first."
    ttk::label .configForm.mf.fontLabel -relief sunken \
            -text "$FontFamily $FontSize" \
            -font [font create -family $FontFamily]
    ttk::label .configForm.mf.configFileLabel -foreground gray25 \
        -text "Config file"
    ttk::label .configForm.mf.configFilenameLabel -foreground gray25 \
        -text [$config filename] -relief sunken
    ttk::frame .configForm.mf.buttons
    ttk::button .configForm.mf.buttons.okButton -text OK -underline 0 \
        -compound left -image [ui::icon ok.svg $::ICON_SIZE] \
        -command [callback on_ok]
    ttk::button .configForm.mf.buttons.cancelButton -text Cancel \
        -compound left -command [callback on_cancel] \
        -image [ui::icon gtk-cancel.svg $::ICON_SIZE]
}

oo::define ConfigForm method make_layout {} {
    const opts "-padx 3 -pady 3"
    grid .configForm.mf.scaleLabel -row 0 -column 0 -sticky w {*}$opts
    grid .configForm.mf.scaleSpinbox -row 0 -column 1 -columnspan 2 \
        -sticky we {*}$opts
    grid .configForm.mf.fontButton -row 1 -column 0 -sticky w {*}$opts
    grid .configForm.mf.fontLabel -row 1 -column 1 -columnspan 2 \
        -sticky news {*}$opts
    grid .configForm.mf.blinkCheckbutton -row 2 -column 1 -sticky we
    grid .configForm.mf.configFileLabel -row 8 -column 0 -sticky we {*}$opts
    grid .configForm.mf.configFilenameLabel -row 8 -column 1 \
        -columnspan 2 -sticky we {*}$opts
    grid .configForm.mf.buttons -row 9 -column 0 -columnspan 3 \
        -sticky we
    pack [ttk::frame .configForm.mf.buttons.pad1] -side left -expand 1
    pack .configForm.mf.buttons.okButton -side left {*}$opts
    pack .configForm.mf.buttons.cancelButton -side left {*}$opts
    pack [ttk::frame .configForm.mf.buttons.pad2] -side right -expand 1
    grid columnconfigure .configForm.mf 1 -weight 1
    pack .configForm.mf -fill both -expand 1
}

oo::define ConfigForm method make_bindings {} {
    bind .configForm <Escape> [callback on_cancel]
    bind .configForm <Return> [callback on_ok]
    bind .configForm <Alt-b> {.configForm.mf.blinkCheckbutton invoke}
    bind .configForm <Alt-f> [callback on_font]
    bind .configForm <Alt-o> [callback on_ok]
    bind .configForm <Alt-s> {focus .configForm.mf.scaleSpinbox}
}

oo::define ConfigForm method on_font {} {
    tk fontchooser configure -parent .configForm \
            -title "[tk appname] — Choose Font" \
            -font [font create -family $FontFamily] \
            -command [callback on_font_chosen]
    tk fontchooser show
}

oo::define ConfigForm method on_font_chosen args {
    if {[llength $args] > 0} {
        set args [lindex $args 0]
        if {[llength $args] > 1} {
            set FontFamily [lindex $args 0]
            set FontSize [lindex $args 1]
            .configForm.mf.fontLabel configure \
                -text "$FontFamily $FontSize" \
                -font [font create -family $FontFamily]
        }
    }
    focus .configForm
}

oo::define ConfigForm method on_ok {} {
    set config [Config new]
    tk scaling [.configForm.mf.scaleSpinbox get]
    $config set_blinking $Blinking
    $config set_family $FontFamily
    $config set_size $FontSize
    $Ok set 1
    my delete
}

oo::define ConfigForm method on_cancel {} { my delete }
