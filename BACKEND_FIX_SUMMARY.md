# Corrections Backend - Problèmes d'authentification

## ✅ Problèmes corrigés

### 1. Erreur JWT Secret Key
**Problème** : Le code essayait de décoder le secret JWT en Base64 alors qu'il était en texte brut.

**Solution** : Modification de `getSignInKey()` pour utiliser directement la chaîne comme bytes UTF-8 au lieu de décoder en Base64.

**Fichier modifié** : `backend/src/main/java/com/nesscute/restaurant/service/JwtService.java`

```java
// Avant (incorrect)
byte[] keyBytes = Decoders.BASE64.decode(secretKey);

// Après (correct)
byte[] keyBytes = secretKey.getBytes(java.nio.charset.StandardCharsets.UTF_8);
```

### 2. Gestion des erreurs dans JwtAuthenticationFilter
**Problème** : Les exceptions lors du parsing JWT n'étaient pas gérées, causant des erreurs 500.

**Solution** : Ajout d'un bloc try-catch pour gérer les erreurs de token invalide sans bloquer les requêtes publiques.

**Fichier modifié** : `backend/src/main/java/com/nesscute/restaurant/security/JwtAuthenticationFilter.java`

## 🔧 Fichiers modifiés

1. **JwtService.java**
   - Correction de `getSignInKey()` pour utiliser UTF-8 au lieu de Base64
   - Suppression de l'import `Decoders` inutile

2. **JwtAuthenticationFilter.java**
   - Ajout de gestion d'erreur avec try-catch
   - Les erreurs JWT sont maintenant loggées mais n'interrompent pas le filtre

## 🚀 Test de l'application

Maintenant vous devriez pouvoir :

1. ✅ **Créer un compte** via `/api/auth/register`
2. ✅ **Se connecter** via `/api/auth/login`
3. ✅ **Se connecter avec Google** via `/api/auth/google`

## 📝 Notes importantes

- Le secret JWT dans `application.properties` doit faire au moins 32 caractères pour HS256
- Les routes `/api/auth/**` sont publiques et ne nécessitent pas de token
- Les erreurs JWT sont maintenant gérées gracieusement sans bloquer les requêtes

## 🔄 Redémarrer le backend

Après ces corrections, redémarrez le backend Spring Boot pour que les changements prennent effet.

