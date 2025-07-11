# Script de configuration pour OnlyFlick (Windows PowerShell)
Write-Host "🚀 Configuration du projet OnlyFlick..." -ForegroundColor Green

# Vérifier si Flutter est installé
Write-Host "📱 Vérification de Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter trouvé" -ForegroundColor Green
        Write-Host $flutterVersion
    } else {
        throw "Flutter non trouvé"
    }
} catch {
    Write-Host "❌ Flutter n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    Write-Host "📥 Veuillez installer Flutter depuis: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "💡 Installation rapide avec Git:" -ForegroundColor Cyan
    Write-Host "   cd C:\" -ForegroundColor White
    Write-Host "   git clone https://github.com/flutter/flutter.git -b stable" -ForegroundColor White
    Write-Host "   Ajoutez C:\flutter\bin au PATH" -ForegroundColor White
    exit 1
}

# Vérifier si Go est installé
Write-Host "🐹 Vérification de Go..." -ForegroundColor Yellow
try {
    $goVersion = go version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Go trouvé" -ForegroundColor Green
        Write-Host $goVersion
    } else {
        throw "Go non trouvé"
    }
} catch {
    Write-Host "❌ Go n'est pas installé" -ForegroundColor Red
    Write-Host "📥 Veuillez installer Go depuis: https://golang.org/dl/" -ForegroundColor Yellow
    exit 1
}

# Obtenir le répertoire du script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
Write-Host "📂 Répertoire actuel: $(Get-Location)" -ForegroundColor Cyan

# Créer le fichier .env s'il n'existe pas
if (-not (Test-Path ".env")) {
    Write-Host "📄 Création du fichier .env..." -ForegroundColor Yellow
    @"
# Configuration OnlyFlick Flutter
API_URL=http://localhost:8080
# Ajoutez d'autres variables d'environnement ici
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "✅ Fichier .env créé" -ForegroundColor Green
} else {
    Write-Host "✅ Fichier .env existe déjà" -ForegroundColor Green
}

# Installation des dépendances Flutter
Write-Host "📦 Installation des dépendances Flutter..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dépendances Flutter installées avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'installation des dépendances Flutter" -ForegroundColor Red
    exit 1
}

# Vérifier le backend Go
Write-Host "🔧 Vérification du backend Go..." -ForegroundColor Yellow
$backendPath = Join-Path (Split-Path $scriptDir -Parent) "Only-Flick-Go"
if (Test-Path $backendPath) {
    Set-Location $backendPath
    
    # Télécharger les dépendances Go
    Write-Host "📦 Installation des dépendances Go..." -ForegroundColor Yellow
    go mod download
    
    # Tenter de compiler le backend
    Write-Host "🔨 Compilation du backend Go..." -ForegroundColor Yellow
    go build -o api.exe cmd/api/main.go
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backend Go compilé avec succès" -ForegroundColor Green
        
        # Démarrer le backend en arrière-plan pour tester
        Write-Host "🚀 Test de démarrage du backend..." -ForegroundColor Yellow
        $backendProcess = Start-Process -FilePath ".\api.exe" -PassThru
        
        # Attendre un peu
        Start-Sleep -Seconds 3
        
        # Tester si le backend répond
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ Backend Go fonctionne correctement" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Backend Go compilé mais ne répond pas sur /health" -ForegroundColor Yellow
        }
        
        # Arrêter le backend de test
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
        
    } else {
        Write-Host "❌ Erreur lors de la compilation du backend Go" -ForegroundColor Red
        Write-Host "⚠️  Vérifiez les erreurs ci-dessus" -ForegroundColor Yellow
    }
    
    Set-Location $scriptDir
} else {
    Write-Host "⚠️  Répertoire backend Go non trouvé" -ForegroundColor Yellow
    Write-Host "📂 Assurez-vous que Only-Flick-Go est dans le même répertoire parent" -ForegroundColor Cyan
}

# Vérifier la configuration Flutter
Write-Host "🔍 Diagnostic Flutter..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "🎉 Configuration terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "   1. Démarrez le backend Go:" -ForegroundColor White
Write-Host "      cd ..\Only-Flick-Go && go run cmd/api/main.go" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Dans un autre terminal, démarrez Flutter:" -ForegroundColor White
Write-Host "      cd Only-Flick-Flutter && flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Testez la messagerie via l'onglet Messages dans l'app" -ForegroundColor White
Write-Host ""
Write-Host "📚 Consultez SETUP_MESSAGING.md pour plus de détails" -ForegroundColor Cyan
