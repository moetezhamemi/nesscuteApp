# 🚀 GUIDE COMPLET - Google Sign-In (Toutes les Étapes)

## ⚠️ SUIVEZ CES ÉTAPES DANS L'ORDRE EXACT

---

## 📋 ÉTAPE 1 : Obtenir le SHA-1 Fingerprint

### Commande à exécuter :

```powershell
cd C:\NessCute\frontend\android
.\gradlew.bat signingReport
```

### Ce que vous devez faire :

1. Ouvrez PowerShell dans le dossier `C:\NessCute`
2. Exécutez les commandes ci-dessus
3. Cherchez dans la sortie la ligne qui contient **"SHA1"**
4. Copiez le SHA-1 (format : `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`)

**Exemple de sortie :**
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: A1:B2:C3:D4:E5:F6:... (copiez cette ligne)
```

**📝 Notez votre SHA-1 ici :** `4C:8D:BE:FF:64:A5:21:6B:10:D4:E0:FE:53:D6:B6:31:E1:C9:19:30
________________________`

---

## 📋 ÉTAPE 2 : Configurer Google Cloud Console

### 2.1 Accéder à Google Cloud Console

1. Allez sur : **https://console.cloud.google.com/**
2. Connectez-vous avec votre compte Google
3. Sélectionnez votre projet (ou créez-en un nouveau)

### 2.2 Activer l'API Google Sign-In

1. Dans le menu de gauche, cliquez sur **"APIs & Services"** > **"Library"**
2. Dans la barre de recherche, tapez : **"Google Sign-In API"** ou **"Identity Toolkit API"**
3. Cliquez sur le résultat
4. Si ce n'est pas activé, cliquez sur **"ENABLE"**

### 2.3 Configurer l'écran de consentement (OAuth consent screen)

1. Allez dans **"APIs & Services"** > **"OAuth consent screen"**
2. Si ce n'est pas configuré :
   - Choisissez **"External"** (pour les tests)
   - Cliquez sur **"CREATE"**
   - Remplissez :
     - **App name** : `NessCute Restaurant`
     - **User support email** : Votre email
     - **Developer contact information** : Votre email
   - Cliquez sur **"SAVE AND CONTINUE"** pour toutes les étapes
   - Cliquez sur **"BACK TO DASHBOARD"**

### 2.4 Créer un OAuth Client ID pour Android

1. Allez dans **"APIs & Services"** > **"Credentials"**
2. En haut, cliquez sur **"+ CREATE CREDENTIALS"**
3. Sélectionnez **"OAuth client ID"**

### 2.5 Configurer le Client ID Android

**⚠️ IMPORTANT : Sélectionnez "Android", pas "Web" !**

1. Dans "Application type", sélectionnez **"Android"**
2. Remplissez :
   - **Name** : `NessCute Restaurant Android`
   - **Package name** : `com.example.nesscute_restaurant` (EXACTEMENT comme ça, sans espaces)
   - **SHA-1 certificate fingerprint** : Collez le SHA-1 que vous avez copié à l'ÉTAPE 1
3. Cliquez sur **"CREATE"**

### 2.6 Copier le Client ID Android

Après création, une popup s'affiche avec :
- **Your Client ID** : `1023968018238-xxxxxxxxxxxxx.apps.googleusercontent.com`

**⚠️ VÉRIFIEZ** : Le type doit être **"Android"**, pas "Web" !

**📝 Copiez ce Client ID Android ici :** `_____________________________`

---

## 📋 ÉTAPE 3 : Mettre à jour strings.xml

### 3.1 Ouvrir le fichier

Ouvrez le fichier : `C:\NessCute\frontend\android\app\src\main\res\values\strings.xml`

### 3.2 Contenu exact du fichier

Le fichier doit contenir **EXACTEMENT** ceci (remplacez par VOTRE Client ID Android de l'ÉTAPE 2) :

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">VOTRE_CLIENT_ID_ANDROID_ICI</string>
</resources>
```

**Exemple avec votre Client ID actuel :**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com</string>
</resources>
```

**⚠️ VÉRIFIEZ** : 
- Le Client ID doit être celui créé pour **Android** (pas Web)
- Le Client ID doit être entre les balises `<string>` et `</string>`
- Pas d'espaces avant ou après

### 3.3 Sauvegarder le fichier

Sauvegardez le fichier après modification.

---

## 📋 ÉTAPE 4 : Vérifier build.gradle.kts

### 4.1 Ouvrir le fichier

Ouvrez : `C:\NessCute\frontend\android\app\build.gradle.kts`

### 4.2 Vérifier le package name

Cherchez la ligne :
```kotlin
applicationId = "com.example.nesscute_restaurant"
```

**⚠️ VÉRIFIEZ** : 
- Le package name doit être **EXACTEMENT** : `com.example.nesscute_restaurant`
- Il doit correspondre EXACTEMENT à celui dans Google Cloud Console
- Même une majuscule/minuscule différente causera une erreur

### 4.3 Vérifier minSdk

Cherchez la ligne :
```kotlin
minSdk = 21
```

**⚠️ VÉRIFIEZ** : 
- `minSdk` doit être **21 ou plus**
- Si vous voyez `minSdk = flutter.minSdkVersion`, vérifiez que Flutter utilise au moins 21

---

## 📋 ÉTAPE 5 : Nettoyer le projet

### Commandes à exécuter :

```powershell
cd C:\NessCute\frontend
flutter clean
cd android
.\gradlew.bat clean
cd ..
```

**Exécutez ces commandes une par une dans PowerShell.**

---

## 📋 ÉTAPE 6 : Désinstaller l'ancienne version

### Commande à exécuter :

```powershell
adb uninstall com.example.nesscute_restaurant
```

**Si vous avez plusieurs appareils :**
```powershell
adb devices
adb -s DEVICE_ID uninstall com.example.nesscute_restaurant
```

**⚠️ IMPORTANT** : Désinstallez complètement l'application de votre appareil avant de réinstaller.

---

## 📋 ÉTAPE 7 : Attendre la propagation

### ⏱️ DÉLAI CRITIQUE

**Après avoir créé/modifié le Client ID dans Google Cloud Console :**

**ATTENDEZ 15-20 MINUTES** avant de tester !

Les changements peuvent prendre du temps à se propager sur les serveurs Google.

**⏰ Notez l'heure de création du Client ID :** `1023968018238-1q28thaa5esbnp03svs7l00qlp0fhsv4.apps.googleusercontent.com___________________________`

**⏰ Heure à laquelle vous pouvez tester (15 minutes après) :** `_____________________________`

---

## 📋 ÉTAPE 8 : Réinstaller les dépendances

### Commandes à exécuter :

```powershell
cd C:\NessCute\frontend
flutter pub get
```

---

## 📋 ÉTAPE 9 : Reconstruire et Tester

### Commandes à exécuter :

```powershell
cd C:\NessCute\frontend
flutter run
```

**Ou pour un appareil spécifique :**
```powershell
flutter devices
flutter run -d DEVICE_ID
```

### Test de connexion Google

1. Lancez l'application
2. Cliquez sur **"Se connecter avec Google"**
3. Sélectionnez votre compte Google
4. Autorisez l'application

---

## ✅ CHECKLIST FINALE

Avant de tester, vérifiez que TOUT est fait :

- [ ] **ÉTAPE 1** : SHA-1 obtenu et noté
- [ ] **ÉTAPE 2.2** : API Google Sign-In activée
- [ ] **ÉTAPE 2.3** : OAuth consent screen configuré
- [ ] **ÉTAPE 2.5** : OAuth Client ID **Android** créé (pas Web !)
- [ ] **ÉTAPE 2.5** : Package name dans Google Cloud : `com.example.nesscute_restaurant`
- [ ] **ÉTAPE 2.5** : SHA-1 ajouté dans le Client ID Android
- [ ] **ÉTAPE 2.6** : Client ID Android copié
- [ ] **ÉTAPE 3** : Client ID Android ajouté dans `strings.xml`
- [ ] **ÉTAPE 4** : Package name vérifié dans `build.gradle.kts`
- [ ] **ÉTAPE 4** : `minSdk = 21` vérifié
- [ ] **ÉTAPE 5** : `flutter clean` exécuté
- [ ] **ÉTAPE 6** : Ancienne version désinstallée
- [ ] **ÉTAPE 7** : **15-20 minutes attendues** après création du Client ID
- [ ] **ÉTAPE 8** : `flutter pub get` exécuté
- [ ] **ÉTAPE 9** : Application reconstruite et testée

---

## 🐛 SI ÇA NE FONCTIONNE TOUJOURS PAS

### Vérification 1 : Type de Client ID

**Dans Google Cloud Console :**
1. Allez dans "Credentials"
2. Cliquez sur votre Client ID
3. **VÉRIFIEZ** : Le type doit être **"Android"**, pas "Web"
4. Si c'est "Web", créez un nouveau Client ID de type "Android"

### Vérification 2 : SHA-1

**Comparez les SHA-1 :**
1. Obtenez le SHA-1 actuel :
   ```powershell
   cd C:\NessCute\frontend\android
   .\gradlew.bat signingReport
   ```
2. Comparez avec celui dans Google Cloud Console
3. Ils doivent être **IDENTIQUES** (même les deux-points `:`)

### Vérification 3 : Package Name

**Vérifiez que le package name est identique partout :**
- `build.gradle.kts` : `applicationId = "com.example.nesscute_restaurant"`
- Google Cloud Console : `com.example.nesscute_restaurant`
- **Doivent être EXACTEMENT identiques !**

### Vérification 4 : Délai de propagation

**Si vous venez de créer le Client ID :**
- Attendez encore 10-15 minutes
- Les changements peuvent prendre jusqu'à 30 minutes

### Vérification 5 : Logs d'erreur

**Obtenez les logs détaillés :**
```powershell
cd C:\NessCute\frontend
flutter logs
```

Cherchez les erreurs liées à Google Sign-In.

---

## 📞 INFORMATIONS À ME DONNER SI ÇA NE FONCTIONNE PAS

Si après avoir suivi TOUTES les étapes ça ne fonctionne toujours pas, donnez-moi :

1. **Le SHA-1 de votre keystore** (de l'ÉTAPE 1)
2. **Le type du Client ID** dans Google Cloud Console (Android ou Web ?)
3. **Le package name** dans Google Cloud Console
4. **Les logs d'erreur complets** (`flutter logs`)
5. **Le contenu de strings.xml** (sans le Client ID complet, juste confirmez qu'il est là)

---

## 🎯 RÉSUMÉ RAPIDE DES COMMANDES

```powershell
# 1. Obtenir SHA-1
cd C:\NessCute\frontend\android
.\gradlew.bat signingReport

# 2. Nettoyer
cd C:\NessCute\frontend
flutter clean
cd android
.\gradlew.bat clean
cd ..

# 3. Désinstaller
adb uninstall com.example.nesscute_restaurant

# 4. Réinstaller dépendances
flutter pub get

# 5. Tester (APRÈS 15-20 MINUTES)
flutter run
```

---

## ⚠️ POINTS CRITIQUES À RETENIR

1. **Client ID Android, pas Web** : Le Client ID dans `strings.xml` doit être de type "Android"
2. **Package name identique** : Doit être exactement `com.example.nesscute_restaurant` partout
3. **SHA-1 identique** : Le SHA-1 dans Google Cloud Console doit correspondre à celui de votre keystore
4. **Délai de propagation** : Attendez 15-20 minutes après création/modification
5. **Désinstallation** : Désinstallez toujours l'ancienne version avant de réinstaller

---

**Bonne chance ! 🍀**

