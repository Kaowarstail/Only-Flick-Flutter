#!/bin/bash

# Script de configuration pour OnlyFlick
echo "🚀 Configuration du projet OnlyFlick..."

# Vérifier si Flutter est installé
echo "📱 Vérification de Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou pas dans le PATH"
    echo "📥 Veuillez installer Flutter depuis: https://flutter.dev/docs/get-started/install"
    echo "💡 Installation rapide avec Git:"
    echo "   cd C:\\"
    echo "   git clone https://github.com/flutter/flutter.git -b stable"
    echo "   Ajoutez C:\\flutter\\bin au PATH"
    exit 1
else
    echo "✅ Flutter trouvé"
    flutter --version
fi

# Vérifier si Go est installé
echo "🐹 Vérification de Go..."
if ! command -v go &> /dev/null; then
    echo "❌ Go n'est pas installé"
    echo "📥 Veuillez installer Go depuis: https://golang.org/dl/"
    exit 1
else
    echo "✅ Go trouvé"
    go version
fi

# Aller dans le répertoire Flutter
cd "$(dirname "$0")"
echo "📂 Répertoire actuel: $(pwd)"

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    echo "📄 Création du fichier .env..."
    cat > .env << EOF
# Configuration OnlyFlick Flutter
API_URL=http://localhost:8080
# Ajoutez d'autres variables d'environnement ici
EOF
    echo "✅ Fichier .env créé"
else
    echo "✅ Fichier .env existe déjà"
fi

# Installation des dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dépendances Flutter installées avec succès"
else
    echo "❌ Erreur lors de l'installation des dépendances Flutter"
    exit 1
fi

# Vérifier le backend Go
echo "🔧 Vérification du backend Go..."
if [ -d "../Only-Flick-Go" ]; then
    cd "../Only-Flick-Go"
    
    # Télécharger les dépendances Go
    echo "📦 Installation des dépendances Go..."
    go mod download
    
    # Tenter de compiler le backend
    echo "🔨 Compilation du backend Go..."
    go build -o api cmd/api/main.go
    
    if [ $? -eq 0 ]; then
        echo "✅ Backend Go compilé avec succès"
        
        # Démarrer le backend en arrière-plan pour tester
        echo "🚀 Test de démarrage du backend..."
        ./api &
        BACKEND_PID=$!
        
        # Attendre un peu
        sleep 3
        
        # Tester si le backend répond
        if curl -f http://localhost:8080/health 2>/dev/null; then
            echo "✅ Backend Go fonctionne correctement"
        else
            echo "⚠️  Backend Go compilé mais ne répond pas sur /health"
        fi
        
        # Arrêter le backend de test
        kill $BACKEND_PID 2>/dev/null
        
    else
        echo "❌ Erreur lors de la compilation du backend Go"
        echo "⚠️  Vérifiez les erreurs ci-dessus"
    fi
    
    cd "../Only-Flick-Flutter"
else
    echo "⚠️  Répertoire backend Go non trouvé"
    echo "📂 Assurez-vous que Only-Flick-Go est dans le même répertoire parent"
fi

# Vérifier la configuration Flutter
echo "🔍 Diagnostic Flutter..."
flutter doctor

echo ""
echo "🎉 Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Démarrez le backend Go:"
echo "      cd ../Only-Flick-Go && go run cmd/api/main.go"
echo ""
echo "   2. Dans un autre terminal, démarrez Flutter:"
echo "      cd Only-Flick-Flutter && flutter run"
echo ""
echo "   3. Testez la messagerie via l'onglet Messages dans l'app"
echo ""
echo "📚 Consultez SETUP_MESSAGING.md pour plus de détails"
