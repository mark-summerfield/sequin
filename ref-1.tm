# Copyright © 2025-26 Mark Summerfield. All rights reserved.

oo::class create Ref {
    variable Value
    constructor value { set Value $value }
    method get {} { set Value }
    method set value { set Value $value }
}
