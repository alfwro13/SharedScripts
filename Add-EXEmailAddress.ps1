Function Add-EmailAddress {
    param($Identity, $EmailAddress)

    begin {
        $mb = Get-Mailbox $Identity
        if($mb.EmailAddressPolicyEnabled) {
            Set-Mailbox $Identity -EmailAddressPolicyEnabled $false
            $policy += 1
        }
        $addresses = $mb.EmailAddresses += $EmailAddress
    }

    process {
        Set-Mailbox $Identity -EmailAddresses $addresses
    }

    end {
        if($policy) {Set-Mailbox $Identity -EmailAddressPolicyEnabled $true}
    }
}
