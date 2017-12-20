# Fork of [IDES-Data-Preparation-OpenSSL](https://github.com/IRSgov/IDES-Data-Preparation-OpenSSL)

This fork only serves to provide sample scripts I use from [IDES Data Preparation OpenSSL](http://irsgov.github.io/IDES-Data-Preparation-OpenSSL) as actual files.

##Usage of encrypt.sh
start "" %installpath%\mintty.exe --exec ./encrypt.sh -pubkey encryption-service_services_irs_gov.pem -in %GIIN%_Payload.zip -aeskeyiv 000000.00000.TA.840_Key -out %GIIN%_Payload

##Usage of decrypt.sh
start "" %installpath%\mintty.exe --exec ./decrypt.sh -privatekey %Private-Key%.pem -in 000000.00000.TA.840_Payload -aeskeyiv %GIIN%_Key -out 000000.00000.TA.840_Payload.zip
