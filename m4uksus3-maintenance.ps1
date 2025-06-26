get-service | where name -eq w3svc | stop-service
get-service | where name -eq w3svc | start-service

get-service | where name -eq WIDWriter | stop-service
get-service | where name -eq WIDWriter | start-service

get-service | where name -eq WsusService | stop-service
get-service | where name -eq WsusService | start-service