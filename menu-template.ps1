cls
do {
    do {
 ""
 "Press x for"
 "Press y for"
 ""

        write-host "_________________________________________________________________________"
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[12x]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "1"
        {
         execute-script bla bla
		}
        
        "2"
        {
         excecute-script bla bla
		}

	}
} until ( $choice -match "X" )