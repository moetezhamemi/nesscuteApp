# Vérification finale Google Sign-In

## ✅ Configuration vérifiée

### 1. Fichiers de configuration
- ✅ `strings.xml` : Client ID configuré
  - Client ID : `1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com`
- ✅ `build.gradle.kts` : Package name correct
  - Package : `com.example.nesscute_restaurant`
- ✅ `minSdk` : Défini à 21 (minimum requis)
- ✅ Code Flutter : `GoogleSignIn` configuré avec scopes

### 2. Google Cloud Console
- ✅ OAuth Client ID créé pour Android
- ✅ SHA-1 fingerprint ajouté
- ✅ Package name correspond

## ⚠️ Points critiques à vérifier

### 1. Type de Client ID
**IMPORTANT** : Assurez-vous que le Client ID dans `strings.xml` est un **Client ID Android**, pas un Client ID Web !

Dans Google Cloud Console :
- Vérifiez que vous avez créé un OAuth Client ID de type **"Android"**
- Le Client ID Web ne fonctionnera pas pour l'authentification mobile

### 2. Vérification du Client ID
Le Client ID actuel : `1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com`

Pour vérifier :
1. Allez dans [Google Cloud Console](https://console.cloud.google.com/)
2. Naviguez vers "APIs & Services" > "Credentials"
3. Vérifiez que ce Client ID est de type **"Android"**
4. Vérifiez que le package name est : `com.example.nesscute_restaurant`
5. Vérifiez que le SHA-1 est correctement configuré

### 3. Délai de propagation
Après avoir ajouté/modifié le SHA-1 dans Google Cloud Console :
- ⏱️ Attendez **10-15 minutes** avant de tester
- Les changements peuvent prendre du temps à se propager

### 4. Nettoyage complet
Avant de tester, faites un nettoyage complet :

```bash
cd frontend
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### 5. Désinstallation de l'ancienne version
Si l'app est déjà installée, désinstallez-la complètement :

```bash
adb uninstall com.example.nesscute_restaurant
```

Puis réinstallez avec `flutter run`.

## 🔍 Tests de diagnostic

### Test 1 : Vérifier le SHA-1 actuel
```bash
cd frontend/android
./gradlew signingReport
```

Comparez le SHA-1 affiché avec celui dans Google Cloud Console.

### Test 2 : Vérifier les logs
Lancez l'app et essayez de vous connecter avec Google, puis regardez les logs :

```bash
flutter logs
```

Cherchez les erreurs liées à Google Sign-In.

### Test 3 : Vérifier Google Play Services
Assurez-vous que Google Play Services est installé sur votre appareil :
- Sur un émulateur : Installez Google Play Services
- Sur un appareil physique : Vérifiez qu'il est à jour

## 🐛 Solutions aux problèmes courants

### Problème : Erreur API 10 persiste
**Solutions** :
1. Vérifiez que le SHA-1 dans Google Cloud Console correspond exactement à celui de votre keystore
2. Vérifiez que le package name est identique partout
3. Attendez 15 minutes après modification
4. Désinstallez et réinstallez l'app
5. Vérifiez que vous utilisez le Client ID Android, pas Web

### Problème : "Sign in failed"
**Solutions** :
1. Vérifiez votre connexion Internet
2. Vérifiez que Google Play Services est installé
3. Vérifiez que l'API Google Sign-In est activée dans Google Cloud Console
4. Vérifiez les logs pour plus de détails

### Problème : L'app se ferme lors du sign-in
**Solutions** :
1. Vérifiez les logs : `flutter logs`
2. Vérifiez que le Client ID est correct dans `strings.xml`
3. Vérifiez que les permissions Internet sont dans `AndroidManifest.xml`
4. Vérifiez que `minSdk >= 21`

## 📋 Checklist finale avant test

- [ ] SHA-1 ajouté dans Google Cloud Console (Android OAuth Client ID)
- [ ] Package name correspond : `com.example.nesscute_restaurant`
- [ ] Client ID Android configuré dans `strings.xml`
- [ ] `minSdk = 21` dans `build.gradle.kts`
- [ ] Attendu 10-15 minutes après modification dans Google Cloud Console
- [ ] Application désinstallée et réinstallée
- [ ] `flutter clean` exécuté
- [ ] Google Play Services installé sur l'appareil/émulateur

## 🚀 Test final

Une fois toutes les vérifications faites :

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

Essayez de vous connecter avec Google. Si l'erreur persiste, vérifiez les logs et comparez le SHA-1.

