# Import the CSV file
$contacts = Import-Csv -Path "C:\contacts.csv"

# Loop through each contact in the CSV file and create the AD contact
foreach ($contact in $contacts) {
    # Define the distinguished name (DN) for the new contact object
    $ouPath = "OU=new,OU=Google_contacts,DC=intranet,DC=macro4,DC=com"
    
    # Create a new mail contact using New-ADObject
    New-ADObject -Type Contact `
        -Name $contact.DisplayName `
        -Path $ouPath `
        -OtherAttributes @{
            mail = $contact.EmailAddress
            givenName = $contact.FirstName
            sn = $contact.Surname
            company = $contact.Company
            info = $contact.Notes  # Assign Notes to the 'info' attribute
        }
}
