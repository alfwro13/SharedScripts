
# Get the state of any services starting TSM Sched* from computer M4UKTSM5
$service = Search-ADAccount -AccountDisabled | select name,enabled,passwordexpired | ft | Out-String
# Specify a sender email address
$emailFrom = "andre.wroblewski@macro4.com"
# Specify a recipient email address
$emailTo = "andre.wroblewski@macro4.com"
# Put in a subject line
$subject = "Test"
# Add the Service state from line 6 to some body text
$body = $service
# Put the DNS name or IP address of your SMTP Server
$smtpServer = "10.0.24.100"
#$smtp = new-object Net.Mail.SmtpClient($smtpServer)
# This line pieces together all the info into an email and sends it
Send-MailMessage -SmtpServer $smtpServer -From $emailFrom -to $emailTo -Subject $subject -Body $body -BodyAsHtml

#$smtp.Send($emailFrom, $emailTo, $subject, $body)