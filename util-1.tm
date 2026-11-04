# Copyright © 2025-26 Mark Summerfield. All rights reserved.

# See: https://en.wikipedia.org/wiki/ANSI_escape_code
proc ansi str {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        # fg: w=white r=red g=green e=blue c=cyan m=magenta y=yellow k=black
        # bg: W R etc.; b=bold i=italic !=reset
        const COLOR_MAP {
            <w> \x1B\[37m <r> \x1B\[31m <g> \x1B\[32m <e> \x1B\[34m
            <c> \x1B\[36m <m> \x1B\[35m <y> \x1B\[33m <k> \x1B\[30m
            <W> \x1B\[47m <R> \x1B\[41m <G> \x1B\[42m <E> \x1B\[44m
            <C> \x1B\[46m <M> \x1B\[45m <Y> \x1B\[103m <K> \x1B\[40m
            <b> \x1B\[1m <i> \x1B\[3m <u> \x1B\[4m <!> \x1B\[;0m /< < /> >
        }
    } else {
        const COLOR_MAP {
            <w> "" <r> "" <g> "" <e> "" <c> "" <m> "" <y> "" <k> "" <W> ""
            <R> "" <G> "" <E> "" <C> "" <M> "" <Y> "" <K> "" <b> "" <i> ""
            <u> "" <!> "" /< < /> >}
    }
    string map $COLOR_MAP ${str}
}

proc clamp {minimum value maximum} {
    expr {max($minimum, min($value, $maximum))}
}

proc commas n {regsub -all {\d(?=(\d{3})+($|\.))} $n {\0,}}

proc bool_to_str b {expr {$b ? true : false}}

proc list_to_str lst {
    set str [list]
    foreach x $lst { lappend str "'$x'" }
    return "{[join $str " "]}"
}

proc ldelete {lst item} {
    if {[set i [lsearch -exact $lst $item]] != -1} {
        return [lremove $lst $i]
    }
    set lst
}

proc lrandom lst { lindex $lst [expr {int(rand() * [llength $lst])}] }

proc lstride {lst {stride 2}} {
    set strides {}
    for {set i 0; set j [expr {$stride - 1}]} {$i < [llength $lst]} {
            incr i $stride; incr j $stride} {
        lappend strides [lrange $lst $i $j]
    }
    set strides
}

namespace eval util {}

proc util::term_width {{defwidth 72}} {
    if {[dict exists [chan configure stdout] -mode]} { ;# tty
        return [lindex [chan configure stdout -winsize] 0]
    }
    set defwidth ;# redirected
}

proc util::islink filename { expr {![catch {file link $filename}]} }

proc util::uid {} { return #[string range [clock clicks] end-8 end] }

proc util::get_ini_filename appname {
    set name $appname.ini
    set home [file home]
    if {[tk windowingsystem] eq "win32"} {
        set names [list [file join $home $name] $::APPPATH/$name]
        set index 0
    } else {
        set names [list [file join $home .config/$name] \
                        [file join $home .$name] $::APPPATH/$name]
        set index [expr {[file isdirectory [file join $home .config]] ? 0 \
                                                                      : 1}]
    }
    foreach name $names {
        set name [file normalize $name]
        if {[file exists $name]} { return $name }
    }
    lindex $names $index
}

proc util::longestCommonPath paths {
    const SEP [file separator]
    set path [::textutil::string::longestCommonPrefixList $paths]
    if {[string index $path end] ne $SEP} {
        if {[set j [string last $SEP $path]] > -1} {
            set path [string range $path 0 $j-1]
        }
    }
    if {$path ne $SEP} { set path [string trimright $path $SEP] }
    set path
}

proc util::open_url url {
    if {[tk windowingsystem] eq "win32"} {
        set cmd [list {*}[auto_execok start] {}]
    } else {
        set cmd [auto_execok xdg-open]
    }
    # may throw an error
    exec {*}$cmd $url &
}

proc util::n_s {size {comma 0}} {
    if {!$size} { return [list "no" "s"] }
    if {$size == 1} { return [list "one" ""] }
    if {$comma} { return [list [commas $size] "s"] }
    list $size "s"
}

proc util::humanize {value {suffix B}} {
    if {!$value} {
        return "$value $suffix"
    }
    set factor 1
    if {$value < 0} {
        set factor -1
        set value [expr {$value * $factor}]
    }

    set log_n [expr {int(log($value) / log(1024))}]
    set prefix [lindex [list "" "Ki" "Mi" "Gi" "Ti" "Pi" "Ei" "Zi" "Yi"] \
        $log_n]
    set value [expr {$value / (pow(1024, $log_n))}]
    set value [expr {$value * $factor}]
    set dp [expr {$log_n < 2 ? 0 : 1}]
    return "[format %.${dp}f $value] ${prefix}${suffix}"
}
