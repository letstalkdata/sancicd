function timestamp() {
    return "$((Get-Date).ToString())"
}
#timestamp

$tempFile = New-TemporaryFile

### GO Build ###
function build() {
    Write-Host "$(timestamp) : Started build script ..."
    Write-Host "$(timestamp) : Building cicttest ..."
    go build > $tempFile

    $err = Get-Content $tempFile
    if ($err.Length -gt 0) {
        Write-Host $err
        Write-Host "$(timestamp) : Compilation error! Exiting ..."
        exit 1
    }
}
build

# Build a docker image
function buildDocker() {
	Write-Host "$(timestamp) : building image sancicd:test"
	docker build -t sancicd:test .
}
buildDocker
# Deploy to Minikube using kubectl
function deploy() {
	Write-Host "$(timestamp) : deploying to kubernetes"
	kubectl delete deployment sancicd
	kubectl delete service sancicd
	kubectl apply -f deploy.yml
}
deploy