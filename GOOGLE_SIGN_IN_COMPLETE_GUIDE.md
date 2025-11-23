# Guide Complet - Configuration Google Sign-In (Étape par Étape)

## ⚠️ IMPORTANT : Suivez TOUTES les étapes dans l'ordre

---

## ÉTAPE 1 : Vérifier le SHA-1 Fingerprint

### 1.1 Obtenir le SHA-1 actuel

**Option A - Avec Gradle (Recommandé) :**
```powershell
cd frontend\android
.\gradlew signingReport
```

Cherchez dans la sortie la section "Variant: debug" et copiez le **SHA-1** (format : `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`)

**Option B - Avec keytool directement :**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Copiez le **SHA-1** de la sortie.

### 1.2 Notez le SHA-1
Écrivez votre SHA-1 ici : `_____________________________`

---

## ÉTAPE 2 : Configurer Google Cloud Console

### 2.1 Accéder à Google Cloud Console
1. Allez sur : https://console.cloud.google.com/
2. Connectez-vous avec votre compte Google
3. Sélectionnez votre projet (ou créez-en un nouveau)

### 2.2 Activer l'API Google Sign-In
1. Dans le menu, allez dans **"APIs & Services"** > **"Library"**
2. Recherchez **"Google Sign-In API"** ou **"Identity Toolkit API"**
3. Cliquez sur **"Enable"** si ce n'est pas déjà fait

### 2.3 Créer un OAuth Client ID pour Android
1. Allez dans **"APIs & Services"** > **"Credentials"**
2. Cliquez sur **"+ CREATE CREDENTIALS"** en haut
3. Sélectionnez **"OAuth client ID"**

### 2.4 Configurer le Client ID Android
Si c'est la première fois :
1. Cliquez sur **"Configure consent screen"**
2. Choisissez **"External"** (pour les tests)
3. Remplissez les informations minimales :
   - App name : `NessCute Restaurant`
   - User support email : Votre email
   - Developer contact : Votre email
4. Cliquez sur **"Save and Continue"** pour toutes les étapes
5. Revenez à **"Credentials"**

Maintenant créez le Client ID :
1. Cliquez sur **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
2. Sélectionnez **"Android"** comme Application type
3. Remplissez :
   - **Name** : `NessCute Restaurant Android`
   - **Package name** : `com.example.nesscute_restaurant` (EXACTEMENT comme dans build.gradle.kts)
   - **SHA-1 certificate fingerprint** : Collez le SHA-1 obtenu à l'ÉTAPE 1
4. Cliquez sur **"Create"**

### 2.5 Copier le Client ID Android
Après création, vous verrez une popup avec :
- **Client ID** : `1023968018238-ddphl6i6roc58mqjj4em0fl6gucdee5o.apps.googleusercontent.com`
- **Client secret** : (pas nécessaire pour Android)

**⚠️ IMPORTANT** : Assurez-vous que c'est un Client ID de type **"Android"**, pas "Web" !

Copiez le Client ID Android ici : `1023968018238-ddphl6i6roc58mqjj4em0fl6gucdee5o.apps.googleusercontent.com`

---

## ÉTAPE 3 : Configurer Flutter (strings.xml)

### 3.1 Vérifier/Créer strings.xml
Le fichier doit être à : `frontend/android/app/src/main/res/values/strings.xml`

### 3.2 Contenu du fichier strings.xml
Le fichier doit contenir EXACTEMENT ceci (remplacez par VOTRE Client ID Android) :

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">VOTRE_CLIENT_ID_ANDROID_ICI</string>
</resources>
```

**Exemple avec votre Client ID :**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com</string>
</resources>
```

**⚠️ VÉRIFIEZ** : Le Client ID dans strings.xml doit être le Client ID **Android** créé à l'ÉTAPE 2, pas un Client ID Web !

---

## ÉTAPE 4 : Vérifier build.gradle.kts

### 4.1 Vérifier le package name
Dans `frontend/android/app/build.gradle.kts`, vérifiez :

```kotlin
defaultConfig {
    applicationId = "com.example.nesscute_restaurant"  // Doit correspondre EXACTEMENT à Google Cloud Console
    minSdk = 21  // Minimum requis (ou flutter.minSdkVersion si >= 21)
    ...
}
```

### 4.2 Vérifier minSdk
Le `minSdk` doit être **>= 21** pour Google Sign-In.

---

## ÉTAPE 5 : Vérifier le code Flutter

### 5.1 Vérifier login_page.dart
Dans `frontend/lib/features/auth/presentation/pages/login_page.dart`, la méthode `_handleGoogleLogin` doit être :

```dart
Future<void> _handleGoogleLogin() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      final success = await ref.read(authProvider.notifier).googleLogin(
            account.id,
            account.email,
            account.displayName ?? '',
            account.photoUrl ?? '',
          );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.clientHome);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la connexion Google')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Google: $e')),
      );
    }
  }
}
```

---

## ÉTAPE 6 : Nettoyer et Reconstruire

### 6.1 Nettoyer complètement le projet
```powershell
cd frontend
flutter clean
cd android
.\gradlew clean
cd ..
```

### 6.2 Supprimer les fichiers de build
```powershell
# Supprimez le dossier build si nécessaire
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
```

### 6.3 Réinstaller les dépendances
```powershell
flutter pub get
```

---

## ÉTAPE 7 : Désinstaller l'ancienne version

### 7.1 Désinstaller l'app de l'appareil
```powershell
adb uninstall com.example.nesscute_restaurant
```

Si vous avez plusieurs appareils connectés :
```powershell
adb devices
adb -s DEVICE_ID uninstall com.example.nesscute_restaurant
```

---

## ÉTAPE 8 : Attendre la propagation

### 8.1 Délai de propagation
**⏱️ IMPORTANT** : Après avoir créé/modifié le Client ID dans Google Cloud Console, attendez **15-20 minutes** avant de tester !

Les changements peuvent prendre du temps à se propager sur les serveurs Google.

---

## ÉTAPE 9 : Reconstruire et Tester

### 9.1 Reconstruire l'application
```powershell
cd frontend
flutter run
```

Ou pour un appareil spécifique :
```powershell
flutter devices
flutter run -d DEVICE_ID
```

### 9.2 Tester Google Sign-In
1. Lancez l'application
2. Cliquez sur "Se connecter avec Google"
3. Sélectionnez votre compte Google
4. Autorisez l'application

---

## 🔍 VÉRIFICATIONS FINALES

### Checklist avant de tester :

- [ ] SHA-1 obtenu et copié
- [ ] API Google Sign-In activée dans Google Cloud Console
- [ ] OAuth Client ID **Android** créé (pas Web !)
- [ ] Package name dans Google Cloud Console : `com.example.nesscute_restaurant`
- [ ] SHA-1 ajouté dans le Client ID Android
- [ ] Client ID Android copié dans `strings.xml`
- [ ] `minSdk >= 21` dans `build.gradle.kts`
- [ ] Package name dans `build.gradle.kts` correspond à Google Cloud Console
- [ ] `flutter clean` exécuté
- [ ] `flutter pub get` exécuté
- [ ] Ancienne version désinstallée
- [ ] **Attendu 15-20 minutes** après création du Client ID
- [ ] Application reconstruite et installée

---

## 🐛 DÉPANNAGE

### Erreur API 10 persiste

**Vérifications :**
1. ✅ Le Client ID dans `strings.xml` est un Client ID **Android**, pas Web
2. ✅ Le SHA-1 dans Google Cloud Console correspond EXACTEMENT à celui de votre keystore
3. ✅ Le package name est identique partout : `com.example.nesscute_restaurant`
4. ✅ Vous avez attendu 15-20 minutes après modification
5. ✅ L'application a été complètement désinstallée et réinstallée

**Solution :**
```powershell
# 1. Vérifiez le SHA-1 actuel
cd frontend\android
.\gradlew signingReport

# 2. Comparez avec celui dans Google Cloud Console
# 3. Si différent, mettez à jour dans Google Cloud Console
# 4. Attendez 15 minutes
# 5. Désinstallez et réinstallez
adb uninstall com.example.nesscute_restaurant
cd ..\..
flutter clean
flutter pub get
flutter run
```

### Erreur "Sign in failed" ou "Sign in cancelled"

**Vérifications :**
1. ✅ Google Play Services installé sur l'appareil/émulateur
2. ✅ Connexion Internet active
3. ✅ API Google Sign-In activée dans Google Cloud Console
4. ✅ Consent screen configuré dans Google Cloud Console

### L'app se ferme lors du sign-in

**Vérifications :**
1. ✅ Vérifiez les logs : `flutter logs`
2. ✅ Vérifiez que `minSdk >= 21`
3. ✅ Vérifiez les permissions Internet dans `AndroidManifest.xml`

---

## 📝 NOTES IMPORTANTES

1. **Client ID Android vs Web** : 
   - Pour l'authentification mobile, vous devez utiliser un Client ID **Android**
   - Un Client ID Web ne fonctionnera pas

2. **SHA-1 Debug vs Release** :
   - Pour le développement : utilisez le SHA-1 du keystore debug
   - Pour la production : créez un nouveau Client ID avec le SHA-1 de votre keystore de production

3. **Délai de propagation** :
   - Les changements dans Google Cloud Console peuvent prendre 15-20 minutes
   - Ne testez pas immédiatement après modification

4. **Package name** :
   - Doit être EXACTEMENT identique dans :
     - `build.gradle.kts` (applicationId)
     - Google Cloud Console (OAuth Client ID Android)
   - Même une majuscule/minuscule différente causera une erreur

---

## ✅ RÉSUMÉ RAPIDE

1. Obtenir SHA-1 : `cd frontend\android && .\gradlew signingReport`
2. Google Cloud Console : Créer OAuth Client ID Android avec SHA-1 et package name
3. `strings.xml` : Ajouter le Client ID Android
4. Attendre 15-20 minutes
5. `flutter clean && flutter pub get`
6. Désinstaller : `adb uninstall com.example.nesscute_restaurant`
7. Tester : `flutter run`

---

## 🆘 Si ça ne fonctionne toujours pas

1. Vérifiez les logs détaillés :
   ```powershell
   flutter logs
   ```

2. Vérifiez que vous utilisez le bon Client ID :
   - Dans Google Cloud Console, vérifiez le type du Client ID
   - Il doit être "Android", pas "Web"

3. Vérifiez le SHA-1 :
   - Comparez le SHA-1 de votre keystore avec celui dans Google Cloud Console
   - Ils doivent être identiques

4. Contactez-moi avec :
   - Le SHA-1 de votre keystore
   - Le type du Client ID dans Google Cloud Console
   - Les logs d'erreur complets

