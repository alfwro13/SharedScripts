function Get-XADUserPasswordExpirationDate() {

    Param ([Parameter(Mandatory=$true,  Position=0,  ValueFromPipeline=$true, HelpMessage="Identity of the Account")]

    [Object] $accountIdentity)

    PROCESS {

        $accountObj = Get-ADUser $accountIdentity -properties PasswordExpired, PasswordNeverExpires, PasswordLastSet

        if ($accountObj.PasswordExpired) {

            echo ("Password of account: " + $accountObj.Name + " already expired!")

        } else { 

            if ($accountObj.PasswordNeverExpires) {

                echo ("Password of account: " + $accountObj.Name + " is set to never expires!")

            } else {

                $passwordSetDate = $accountObj.PasswordLastSet

                if ($passwordSetDate -eq $null) {

                    echo ("Password of account: " + $accountObj.Name + " has never been set!")

                }  else {

                    $maxPasswordAgeTimeSpan = $null

                    $dfl = (get-addomain).DomainMode

                    if ($dfl -ge 3) { 

                        ## Greater than Windows2008 domain functional level

                        $accountFGPP = Get-ADUserResultantPasswordPolicy $accountObj

                        if ($accountFGPP -ne $null) {

                            $maxPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge

                        } else {

                            $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

                        }

                    } else {

                        $maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

                    }

                    if ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0) {

                        echo ("MaxPasswordAge is not set for the domain or is set to zero!")

                    } else {

                        echo ("Password of account: " + $accountObj.Name + " expires on: " + ($passwordSetDate + $maxPasswordAgeTimeSpan))

                    }

                }

            }

        }

    }

}

function Check-IsPatchInstalled {
    #Øyvind Nilsen, oyvindnilsen.com
    PARAM (
       [Parameter(Mandatory=$false,ValueFromPipeline=$false)][String]$computer = "127.0.0.1",
       [Parameter(Mandatory=$true,ValueFromPipeline=$false)][String]$id
    )
 
    $patches = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $computer | select description,hotfixid,installedon
 
    if ($patches | ? { $_.Hotfixid -like $id }) {
        return $true
    } else {
        return $false
    }
}