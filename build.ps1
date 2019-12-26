param(
        [Parameter(
            Mandatory=$True,
            ValueFromRemainingArguments=$true,
            Position = 0
        )][string[]]
        $listArgs
)

function timestamp() {
    return "$((Get-Date).ToString())"
}
#timestamp

### GO Build ###
function build() {
    Write-Host "$(timestamp) : Started build script ..." -ForegroundColor Green
    Write-Host "$(timestamp) : Building cicttest ..." -ForegroundColor Green
    go build > $tempFile

    $err = Get-Content $tempFile
    if ($err.Length -gt 0) {
        Write-Host $err
        Write-Host "$(timestamp) : Compilation error! Exiting ..." -ForegroundColor Red
        exit 1
    }
}
#build

# Build a docker image
function buildDocker() {
	Write-Host "$(timestamp) : building image sancicd:test" -ForegroundColor Green
	docker build -t sancicd:test .
}
#buildDocker
# Deploy to Minikube using kubectl
function deploy() {
	Write-Host "$(timestamp) : deploying to kubernetes" -ForegroundColor Green
	kubectl delete deployment sancicd
	kubectl delete service sancicd
	kubectl apply -f deploy.yml
}
#deploy


$tempFile = New-TemporaryFile
$count = 0
foreach($listArg in $listArgs) {
    #'Passed_Argument[{0}]: {1}' -f $count, $listArg
    $count++
}

Write-Host "Welcome to the sancicd builder v0.3, written by gitgub.com/letstalkdata" -ForegroundColor Yellow

if ($listArgs[0].ToLower() -eq "build"){
    if ($listArgs[1].ToLower() -eq "docker"){
        if ($listArgs[2].ToLower() -eq "deploy"){
            build
            buildDocker
            deploy
        } else {
            build
            buildDocker
        }
        Write-Host "$(timestamp) : complete." -ForegroundColor Green
        Write-Host "$(timestamp) : exiting ..." -ForegroundColor Green
    } elseif ($listArgs[2].ToLower() -eq "bin") {
        build
        Write-Host "$(timestamp) : complete." -ForegroundColor Green
        Write-Host "$(timestamp) : exiting ..." -ForegroundColor Green
    } else {
        Write-Host "$(timestamp) : Missing build argument" -ForegroundColor Red
    }
} else {
    if ($listArgs[0].ToLower() -eq "--help"){
        Clear-Host
        Write-Host "+---------------------------------------------------+"
        Write-Host "| build - start a build to produce artifacts        |"
        Write-Host "|    docker - produces docker images                |"
        Write-Host "|       deploy   - deploy application to kubernetes |"
        Write-Host "|    bin    - produces executable binaries          |"
        Write-Host "+---------------------------------------------------+"
    }
    else {
        Write-Host "you didn`'t pass any argument to the utility! type --help for a list of argument" -ForegroundColor Yellow
    }
}

Remove-Item $tempFile -Force