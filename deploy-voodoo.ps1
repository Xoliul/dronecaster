# Deploy only Voodoo drone to norns
# Usage: .\deploy-voodoo.ps1

$nornsIP = "192.168.11.161"
$nornsUser = "we"
$nornsPassword = "sleep"  # Default norns password
$nornsDronePath = "/home/we/dust/code/dronecaster/engine/drones"
$localDroneFile = "G:\Code\dronecaster\engine\drones\Voodoo.scd"

Write-Host "Deploying Voodoo drone to norns at $nornsIP..." -ForegroundColor Cyan

# Check if local file exists
if (-not (Test-Path $localDroneFile)) {
    Write-Host "ERROR: Voodoo.scd not found at $localDroneFile" -ForegroundColor Red
    exit 1
}

# Test connection first
Write-Host "Testing connection..." -ForegroundColor Yellow
$testResult = Test-Connection -ComputerName $nornsIP -Count 1 -Quiet

if (-not $testResult) {
    Write-Host "ERROR: Cannot reach norns at $nornsIP" -ForegroundColor Red
    exit 1
}

Write-Host "Connection OK!" -ForegroundColor Green

# Ensure the target directory exists on norns
Write-Host "Ensuring drones directory exists..." -ForegroundColor Yellow
ssh "${nornsUser}@${nornsIP}" "mkdir -p ${nornsDronePath}"

# Copy just the Voodoo drone
Write-Host "Copying Voodoo.scd..." -ForegroundColor Yellow
scp "$localDroneFile" "${nornsUser}@${nornsIP}:${nornsDronePath}/"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Voodoo drone deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Dronecaster from the norns menu" -ForegroundColor White
    Write-Host "  2. Use encoder 1 to scroll to 'Voodoo' in the drone list" -ForegroundColor White
    Write-Host "  3. Adjust with encoder 2 (hz) and encoder 3 (amp)" -ForegroundColor White
    Write-Host ""
    Write-Host "Maiden interface: http://$nornsIP" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Failed to copy file" -ForegroundColor Red
    exit 1
}
