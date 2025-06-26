Function Combine-Objects {
    Param (
        [Parameter(mandatory=$true)]$Object1, 
        [Parameter(mandatory=$true)]$Object2
    )
    
    $arguments = [Pscustomobject]@()

    foreach ( $Property in $Object1.psobject.Properties){
        $arguments += @{$Property.Name = $Property.value}
        
    }

    foreach ( $Property in $Object2.psobject.Properties){
        $arguments += @{ $Property.Name= $Property.value}
        
    }
    
    
    $Object3 = [Pscustomobject]$arguments
    

    return $Object3
}