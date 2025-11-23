# NessCute Restaurant App

Application mobile complète pour la gestion d'un restaurant avec intégration IA.

## Architecture

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.2.0
- **Base de données**: MySQL
- **Sécurité**: JWT + OAuth2 Google
- **IA**: Ollama (gpt-oss:20b) avec RAG

### Frontend (Flutter)
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Architecture**: Clean Architecture + MVVM

## Structure du projet

```
NessCute/
├── backend/                 # Backend Spring Boot
│   ├── src/
│   │   └── main/
│   │       ├── java/com/nesscute/restaurant/
│   │       │   ├── config/         # Configuration
│   │       │   ├── controller/     # REST Controllers
│   │       │   ├── dto/            # Data Transfer Objects
│   │       │   ├── entity/         # JPA Entities
│   │       │   ├── repository/     # Spring Data Repositories
│   │       │   ├── security/       # JWT Security
│   │       │   └── service/        # Business Logic
│   │       └── resources/
│   │           └── application.properties
│   └── pom.xml
│
└── frontend/               # Application Flutter
    └── lib/
        ├── core/           # Core functionality
        │   ├── config/
        │   ├── models/
        │   ├── providers/
        │   ├── routing/
        │   ├── services/
        │   └── theme/
        └── features/       # Feature modules
            ├── admin/
            ├── assistant/
            ├── auth/
            ├── client/
            └── ai/
```

## Installation

### Backend

1. Prérequis:
   - Java 17+
   - Maven 3.6+
   - MySQL 8.0+

2. Configuration:
   - Créer la base de données MySQL: `nesscute_db`
   - Modifier `application.properties` avec vos credentials MySQL
   - Configurer Ollama (défaut: http://localhost:11434)

3. Lancer:
   ```bash
   cd backend
   mvn spring-boot:run
   ```

### Frontend

1. Prérequis:
   - Flutter 3.0+
   - Dart 3.0+

2. Installation:
   ```bash
   cd frontend
   flutter pub get
   ```

3. Lancer:
   ```bash
   flutter run
   ```

## Fonctionnalités

### Rôles

#### Admin
- Gestion des articles (CRUD)
- Gestion des assistants (CRUD)
- Dashboard avec statistiques

#### Assistant
- Gestion des commandes
- Changement d'état des commandes
- Vue des détails de commande

#### Client
- Consultation du menu
- Ajout au panier
- Passer commande (retrait/livraison)
- Rating et commentaires
- Chat IA pour questions

### IA (RAG + Ollama)

Le chatbot IA utilise RAG (Retrieval Augmented Generation) pour répondre aux questions sur:
- Le menu et les articles
- Les ratings et commentaires
- Les recommandations

## API Endpoints

### Auth
- `POST /api/auth/login` - Connexion
- `POST /api/auth/register` - Inscription
- `POST /api/auth/google` - Connexion Google

### Articles
- `GET /api/articles` - Liste des articles
- `GET /api/articles/{id}` - Détails article
- `POST /api/articles` - Créer article (Admin)
- `PUT /api/articles/{id}` - Modifier article (Admin)
- `DELETE /api/articles/{id}` - Supprimer article (Admin)

### Commandes
- `GET /api/orders` - Liste des commandes
- `POST /api/orders` - Créer commande
- `PUT /api/orders/{id}/status` - Changer statut

### IA
- `POST /api/ai/query` - Question IA

## Configuration Ollama

1. Installer Ollama: https://ollama.ai
2. Télécharger le modèle:
   ```bash
   ollama pull gpt-oss:20b
   ```
3. Vérifier que Ollama tourne sur http://localhost:11434

## Couleurs

- Orange doux: #FF8A00
- Rouge tomate: #FF3D3D
- Beige crème: #FFF3E0
- Marron cacao: #6B3E2E

## Notes

- Le backend utilise JWT pour l'authentification
- Les images sont stockées localement (dossier `uploads/`)
- La géolocalisation est requise pour les livraisons
- Les notifications push peuvent être ajoutées pour les changements d'état de commande

## Développement

Pour contribuer:
1. Créer une branche feature
2. Implémenter les fonctionnalités
3. Tester
4. Créer une pull request

## Licence

Propriétaire - NessCute Restaurant

