get-adcomputer -filter * -prop * | ? OperatingSystemVersion -like 10* | select CN,OperatingSystemVersion,CanonicalName,Description | Out-GridView
