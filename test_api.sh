#!/bin/bash

# Script de test pour l'API de messagerie OnlyFlick
echo "🧪 Test de l'API de messagerie OnlyFlick"

# URL de base du backend
BASE_URL="http://localhost:8080"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local url=$1
    local method=${2:-GET}
    local description=$3
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "URL: $method $url"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" 2>/dev/null)
    fi
    
    if [ $? -eq 0 ]; then
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
            echo -e "${GREEN}✅ SUCCESS: HTTP $http_code${NC}"
            if [ -n "$body" ] && [ "$body" != "" ]; then
                echo "Response: $body"
            fi
        elif [ "$http_code" -eq 401 ]; then
            echo -e "${YELLOW}⚠️  AUTHENTICATION REQUIRED: HTTP $http_code${NC}"
            echo "Note: This is expected for protected endpoints without token"
        else
            echo -e "${RED}❌ FAILED: HTTP $http_code${NC}"
            if [ -n "$body" ]; then
                echo "Response: $body"
            fi
        fi
    else
        echo -e "${RED}❌ CONNECTION FAILED${NC}"
        echo "Is the backend running on $BASE_URL?"
    fi
}

echo "🚀 Starting API tests..."

# Test basic connectivity
test_endpoint "$BASE_URL/health" "GET" "Health check"

# Test messaging endpoints (these will require authentication)
test_endpoint "$BASE_URL/api/conversations" "GET" "Get user conversations"
test_endpoint "$BASE_URL/api/conversations" "POST" "Create conversation"

# Test notifications endpoints
test_endpoint "$BASE_URL/api/notifications" "GET" "Get notifications"
test_endpoint "$BASE_URL/api/notifications/unread-count" "GET" "Get unread notifications count"

echo -e "\n${YELLOW}📋 Test Summary:${NC}"
echo "- Health check should return 200"
echo "- Protected endpoints should return 401 (authentication required)"
echo "- If you see connection failures, make sure the backend is running:"
echo "  cd ../Only-Flick-Go && go run cmd/api/main.go"

echo -e "\n${GREEN}🎯 Next steps:${NC}"
echo "1. If backend is not running, start it first"
echo "2. Configure authentication in Flutter app"
echo "3. Test the messaging UI in Flutter"

echo -e "\n${YELLOW}📱 Flutter testing:${NC}"
echo "1. Run: flutter run"
echo "2. Navigate to the Messages tab"
echo "3. Check the MessagingTestPage for detailed API testing"
