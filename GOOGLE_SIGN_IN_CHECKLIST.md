# Checklist de vérification Google Sign-In

## ✅ Configuration complétée

### 1. SHA-1 Fingerprint
- [x] SHA-1 obtenu via `gradlew signingReport` ou `keytool`
- [x] SHA-1 ajouté dans Google Cloud Console

### 2. Google Cloud Console
- [x] OAuth Client ID créé pour Android
- [x] Package name : `com.example.nesscute_restaurant`
- [x] SHA-1 fingerprint configuré

### 3. Configuration Flutter
- [x] `strings.xml` avec `default_web_client_id` configuré
- [x] Client ID : `1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com`

### 4. Code Flutter
- [x] `GoogleSignIn` configuré avec scopes `['email', 'profile']`
- [x] Gestion des erreurs implémentée

## ⚠️ Points à vérifier

### 1. MinSdk Version
**Important** : Google Sign-In nécessite `minSdk >= 21`

Vérifiez dans `frontend/android/app/build.gradle.kts` :
```kotlin
defaultConfig {
    minSdk = 21  // Doit être >= 21
}
```

Si vous utilisez `flutter.minSdkVersion`, vérifiez dans `pubspec.yaml` ou définissez explicitement `minSdk = 21`.

### 2. Package Name
Assurez-vous que le package name dans :
- `build.gradle.kts` : `applicationId = "com.example.nesscute_restaurant"`
- Google Cloud Console : `com.example.nesscute_restaurant`

**Doivent être identiques !**

### 3. Délai de propagation
Après avoir ajouté le SHA-1 dans Google Cloud Console, attendez **5-10 minutes** avant de tester.

### 4. Nettoyage et rebuild
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

### 5. Désinstaller l'ancienne version
Si vous avez déjà installé l'app, désinstallez-la complètement avant de réinstaller :
```bash
adb uninstall com.example.nesscute_restaurant
```

## 🔍 Tests de vérification

### Test 1 : Vérifier le SHA-1
```bash
cd frontend/android
./gradlew signingReport
```
Cherchez la section "Variant: debug" et copiez le SHA-1.

### Test 2 : Vérifier le package name
```bash
# Dans build.gradle.kts
grep -r "applicationId" frontend/android/app/build.gradle.kts
```

### Test 3 : Vérifier strings.xml
```bash
cat frontend/android/app/src/main/res/values/strings.xml
```
Doit contenir votre Client ID.

## 🐛 Dépannage

### Erreur API 10 persiste
1. Vérifiez que le SHA-1 est correct (sans espaces, sans `:`)
2. Vérifiez que le package name correspond exactement
3. Attendez 10 minutes après modification dans Google Cloud Console
4. Désinstallez et réinstallez l'application
5. Vérifiez que `minSdk >= 21`

### Erreur "Sign in failed"
1. Vérifiez votre connexion Internet
2. Vérifiez que Google Play Services est installé sur l'appareil
3. Vérifiez que l'API Google Sign-In est activée dans Google Cloud Console

### L'app se ferme lors du sign-in
1. Vérifiez les logs : `flutter logs`
2. Vérifiez que le Client ID est correct dans `strings.xml`
3. Vérifiez que les permissions Internet sont dans `AndroidManifest.xml`

## 📝 Notes importantes

- **Firebase n'est pas requis** pour Google Sign-In seul
- Le fichier `google-services.json` est pour Firebase, pas pour Google Sign-In
- Vous pouvez utiliser Google Sign-In sans Firebase
- Pour la production, créez un nouveau OAuth Client ID avec le SHA-1 de votre keystore de production

