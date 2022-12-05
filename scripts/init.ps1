$tenant_id = $env:BACKEND_TENANT_ID
$subscription_id = $env:BACKEND_SUBSCRIPTION_ID
$client_id = $env:BACKEND_CLIENT_ID
$client_secret = $env:BACKEND_CLIENT_SECRET
$resource_group_name = $env:BACKEND_RESOURCE_GROUP_NAME
$storage_account_name = $env:BACKEND_STORAGE_ACCOUNT_NAME

terraform init `
    -backend-config="tenant_id=$tenant_id" `
    -backend-config="subscription_id=$subscription_id" `
    -backend-config="client_id=$client_id" `
    -backend-config="client_secret=$client_secret" `
    -backend-config="resource_group_name=$resource_group_name" `
    -backend-config="storage_account_name=$storage_account_name" `
    -reconfigure `
    -upgrade