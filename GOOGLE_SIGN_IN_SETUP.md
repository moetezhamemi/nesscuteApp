# Configuration Google Sign-In pour Android

L'erreur `ApiException: 10` signifie généralement que le SHA-1 fingerprint n'est pas configuré dans Google Cloud Console.

## Étapes pour corriger :

### 1. Obtenir le SHA-1 fingerprint

**Sur Windows (PowerShell) :**
```powershell
cd android
.\gradlew signingReport
```

**Ou avec keytool directement :**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### 2. Configurer Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Google Sign-In" pour votre projet
4. Allez dans "Credentials" > "Create Credentials" > "OAuth client ID"
5. Sélectionnez "Android" comme type d'application
6. Entrez votre **Package name** : `com.example.nesscute_restaurant`
7. Entrez le **SHA-1 fingerprint** obtenu à l'étape 1
8. Cliquez sur "Create"

### 3. Obtenir le Client ID

Après avoir créé l'OAuth client ID, vous obtiendrez un **Client ID** (format : `xxxxx-xxxxx.apps.googleusercontent.com`)

### 4. Configurer dans Flutter

Créez ou modifiez le fichier `android/app/src/main/res/values/strings.xml` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">VOTRE_CLIENT_ID_ICI</string>
</resources>
```

### 5. Alternative : Configuration dans le code

Vous pouvez aussi configurer directement dans le code Flutter :

```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Optionnel : spécifier le client ID
  // serverClientId: 'VOTRE_CLIENT_ID_ICI',
);
```

### 6. Vérifier la configuration

Assurez-vous que dans `android/app/build.gradle.kts`, vous avez :
- `minSdk >= 21` (requis pour Google Sign-In)
- Les dépendances nécessaires

### Notes importantes :

- Pour la **production**, vous devrez créer un nouveau OAuth client ID avec le SHA-1 de votre keystore de production
- Le SHA-1 de debug est différent du SHA-1 de release
- Si vous testez sur un émulateur, utilisez le SHA-1 de debug
- Si vous testez sur un appareil physique avec une build release, utilisez le SHA-1 de release

### Erreur API 10 - Solutions supplémentaires :

1. Vérifiez que le package name dans `build.gradle.kts` correspond exactement à celui dans Google Cloud Console
2. Vérifiez que le SHA-1 est correctement copié (sans espaces, sans `:`)
3. Attendez quelques minutes après avoir ajouté le SHA-1 dans Google Cloud Console
4. Désinstallez et réinstallez l'application sur votre appareil

