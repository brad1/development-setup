 $bytes = [System.Text.Encoding]::ASCII.GetBytes("mypass")
 $alg = [System.Security.Cryptography.SHA512]::Create()
 $hashBytes = $alg.ComputeHash($bytes)
 $hash =  -Join ($hashBytes | ForEach {"{0:x2}" -f $_})
