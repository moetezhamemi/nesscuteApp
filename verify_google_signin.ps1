# Script de vérification Google Sign-In
Write-Host "=== Vérification Google Sign-In ===" -ForegroundColor Cyan
Write-Host ""

# Étape 1: Obtenir le SHA-1
Write-Host "ÉTAPE 1: Obtention du SHA-1 fingerprint..." -ForegroundColor Yellow
Write-Host ""

Set-Location frontend\android
.\gradlew signingReport | Out-Null

Write-Host "Recherche du SHA-1 dans le rapport..." -ForegroundColor Green
$sha1 = Get-Content .\app\build\outputs\apk\debug\output-metadata.json | Select-String -Pattern "SHA1" | Select-Object -First 1

if ($sha1) {
    Write-Host "SHA-1 trouvé!" -ForegroundColor Green
    Write-Host $sha1 -ForegroundColor White
} else {
    Write-Host "SHA-1 non trouvé dans le fichier. Exécutez manuellement:" -ForegroundColor Red
    Write-Host "cd frontend\android" -ForegroundColor Yellow
    Write-Host ".\gradlew signingReport" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Vérifications ===" -ForegroundColor Cyan
Write-Host ""

# Vérifier strings.xml
Write-Host "Vérification de strings.xml..." -ForegroundColor Yellow
$stringsPath = "frontend\android\app\src\main\res\values\strings.xml"
if (Test-Path $stringsPath) {
    $stringsContent = Get-Content $stringsPath -Raw
    if ($stringsContent -match "default_web_client_id") {
        Write-Host "✓ strings.xml trouvé avec default_web_client_id" -ForegroundColor Green
        $clientId = ([regex]::Match($stringsContent, 'default_web_client_id">([^<]+)')).Groups[1].Value
        Write-Host "  Client ID: $clientId" -ForegroundColor White
    } else {
        Write-Host "✗ default_web_client_id non trouvé dans strings.xml" -ForegroundColor Red
    }
} else {
    Write-Host "✗ strings.xml non trouvé!" -ForegroundColor Red
}

# Vérifier build.gradle.kts
Write-Host ""
Write-Host "Vérification de build.gradle.kts..." -ForegroundColor Yellow
$buildGradlePath = "frontend\android\app\build.gradle.kts"
if (Test-Path $buildGradlePath) {
    $buildContent = Get-Content $buildGradlePath -Raw
    if ($buildContent -match "applicationId\s*=\s*""com\.example\.nesscute_restaurant""") {
        Write-Host "✓ Package name correct: com.example.nesscute_restaurant" -ForegroundColor Green
    } else {
        Write-Host "✗ Package name incorrect ou non trouvé" -ForegroundColor Red
    }
    
    if ($buildContent -match "minSdk\s*=\s*21|minSdk\s*=\s*flutter\.minSdkVersion") {
        Write-Host "✓ minSdk configuré (vérifiez qu'il est >= 21)" -ForegroundColor Green
    } else {
        Write-Host "✗ minSdk non trouvé ou < 21" -ForegroundColor Red
    }
} else {
    Write-Host "✗ build.gradle.kts non trouvé!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Instructions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copiez le SHA-1 ci-dessus" -ForegroundColor Yellow
Write-Host "2. Allez sur https://console.cloud.google.com/" -ForegroundColor Yellow
Write-Host "3. Créez un OAuth Client ID de type 'Android'" -ForegroundColor Yellow
Write-Host "4. Ajoutez le SHA-1 et le package name: com.example.nesscute_restaurant" -ForegroundColor Yellow
Write-Host "5. Copiez le Client ID Android dans strings.xml" -ForegroundColor Yellow
Write-Host "6. Attendez 15-20 minutes" -ForegroundColor Yellow
Write-Host "7. Exécutez: flutter clean && flutter pub get && flutter run" -ForegroundColor Yellow
Write-Host ""

Set-Location ..\..

