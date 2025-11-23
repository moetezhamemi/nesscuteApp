# Guide de démarrage rapide - NessCute Restaurant App

## Prérequis

### Backend
- Java 17 ou supérieur
- Maven 3.6+
- MySQL 8.0+
- Ollama (pour l'IA)

### Frontend
- Flutter 3.0+
- Dart 3.0+
- Android Studio / Xcode (pour le développement mobile)

## Installation Backend

### 1. Configuration MySQL

```sql
CREATE DATABASE nesscute_db;
```

### 2. Configuration application.properties

Modifier `backend/src/main/resources/application.properties`:

```properties
# Mettre vos credentials MySQL
spring.datasource.username=votre_username
spring.datasource.password=votre_password

# JWT Secret (générer une clé sécurisée)
jwt.secret=votre_secret_key_tres_longue_et_securisee

# OAuth Google (optionnel)
spring.security.oauth2.client.registration.google.client-id=VOTRE_CLIENT_ID
spring.security.oauth2.client.registration.google.client-secret=VOTRE_CLIENT_SECRET
```

### 3. Installation Ollama

```bash
# Télécharger Ollama depuis https://ollama.ai
# Installer le modèle
ollama pull gpt-oss:20b

# Vérifier que Ollama tourne
curl http://localhost:11434/api/tags
```

### 4. Lancer le backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Le backend sera accessible sur `http://localhost:8080`

## Installation Frontend

### 1. Installer les dépendances

```bash
cd frontend
flutter pub get
```

### 2. Configuration

Modifier `frontend/lib/core/config/app_config.dart` si nécessaire:

```dart
static const String baseUrl = 'http://VOTRE_IP:8080/api';
```

Pour Android Emulator, utiliser `http://10.0.2.2:8080/api`
Pour iOS Simulator, utiliser `http://localhost:8080/api`
Pour appareil physique, utiliser l'IP de votre machine.

### 3. Lancer l'application

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (pour test)
flutter run -d chrome
```

## Création d'un compte Admin

Par défaut, aucun admin n'existe. Vous pouvez:

1. Créer un compte via l'API:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin",
    "email": "admin@nesscute.com",
    "password": "admin123",
    "role": "ADMIN"
  }'
```

2. Ou modifier directement la base de données après création d'un compte CLIENT.

## Structure des rôles

- **ADMIN**: Accès complet (gestion articles, assistants, commandes)
- **ASSISTANT**: Gestion des commandes uniquement
- **CLIENT**: Consultation menu, commandes, chat IA

## Test de l'API

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@nesscute.com", "password": "admin123"}'
```

### Créer un article (nécessite token JWT)
```bash
curl -X POST http://localhost:8080/api/articles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -d '{
    "name": "Cheese Burger",
    "description": "Délicieux burger au fromage",
    "price": 12.50,
    "type": "BURGER"
  }'
```

## Dépannage

### Backend ne démarre pas
- Vérifier que MySQL est démarré
- Vérifier les credentials dans `application.properties`
- Vérifier le port 8080 n'est pas utilisé

### Frontend ne se connecte pas au backend
- Vérifier l'URL dans `app_config.dart`
- Vérifier que le backend tourne
- Vérifier les permissions CORS

### Ollama ne répond pas
- Vérifier que Ollama est démarré: `ollama serve`
- Vérifier le modèle est installé: `ollama list`
- Vérifier l'URL dans `application.properties`

## Prochaines étapes

1. Ajouter des articles via l'interface Admin
2. Créer des assistants
3. Tester les commandes
4. Tester le chat IA

## Support

Pour toute question, consulter le README.md principal.

