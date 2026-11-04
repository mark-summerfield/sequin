# Copyright © 2025-26 Mark Summerfield. All rights reserved.

package require sqlite3 3

namespace eval db {}

proc db::sqlite_version {} {
    set db ::DB#[string range [clock clicks] end-8 end]
    sqlite3 $db :memory:
    try {
        return "SQLite [$db version]"
    } finally {
        $db close
    }
}

proc db::dump {db filename} {
    set out [open $filename w]
    try {
        puts $out "PRAGMA USER_VERSION\
            [$db onecolumn "PRAGMA USER_VERSION"];"
        puts $out "BEGIN TRANSACTION;"
        $db transaction {
            puts $out "-- Create Schema"
            $db eval {SELECT sql FROM sqlite_master
                      WHERE sql IS NOT NULL
                      AND type IN ('table','index','trigger','view')
                      AND name NOT LIKE 'sqlite_%'
                      ORDER BY type='table' DESC, type, name} {
                puts $out "$sql;"
            }
            puts $out "-- Insert Data"
            $db eval {SELECT name AS table_name FROM sqlite_master
                      WHERE type='table' AND name NOT LIKE 'sqlite_%'} {
                set column_names [list]
                set quoted_column_names [list]
                $db eval "PRAGMA table_info(\"$table_name\")" {
                    lappend column_names $name
                    lappend quoted_column_names "\"$name\""
                }
                set quoted_column_names [join $quoted_column_names ,]
                set quoted_values [list]
                foreach column_name $column_names {
                    lappend quoted_values "quote(\"$column_name\")"
                }
                set sql "SELECT 'INSERT INTO \"$table_name\"\
                    ($quoted_column_names) VALUES\
                    (' || [join $quoted_values { || ',' || }] || ');' \
                    AS insert_sql FROM \"$table_name\""
                $db eval $sql row { puts $out $row(insert_sql) }
            }
        }
        puts $out "COMMIT;"
    } finally {
        close $out
    }
}
