$i=1
for ($i=1) {
	
$key = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'
date | tee-object -filepath U:\proxySettings_log.txt -Append
(get-itemproperty $key).AutoConfigURL | tee-object -filepath U:\proxySettings_log.txt -Append
write-host "" | tee-object -filepath U:\proxySettings_log.txt -Append
sleep 10
}
