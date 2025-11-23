# Corrections apportées

## Problèmes corrigés

### 1. Erreur `parserBuilder()` dans JwtService
**Problème**: La méthode `parserBuilder()` n'était pas reconnue.

**Solution**: Le code a été corrigé pour utiliser la syntaxe correcte de JJWT 0.12.3:
```java
JwtParser parser = Jwts.parserBuilder()
        .setSigningKey(getSignInKey())
        .build();
return parser.parseClaimsJws(token).getBody();
```

**Note**: Si vous avez encore des erreurs de compilation, assurez-vous que:
- Les dépendances Maven sont bien téléchargées: `mvn dependency:resolve`
- L'IDE est synchronisé avec les dépendances Maven
- Vous utilisez bien JJWT 0.12.3

### 2. Erreur `generateToken(UserDetails)` avec `User`
**Problème**: `AuthService` passait un objet `User` à `generateToken()` qui attend un `UserDetails`.

**Solution**: Utilisation de `CustomUserDetailsService` pour convertir `User` en `UserDetails`:
```java
UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
return jwtService.generateToken(userDetails);
```

### 3. Modèle Ollama
**Changement**: Le modèle a été mis à jour de `gpt-oss:20b` à `gpt-oss:20-cloud` dans `application.properties`.

### 4. URL de base pour le téléphone
**Changement**: L'URL dans `app_config.dart` a été mise à jour pour utiliser l'IP locale `192.168.0.122:8080` au lieu de `localhost:8080`.

**Important**: Si votre IP change, modifiez `frontend/lib/core/config/app_config.dart`.

## Pour compiler et lancer le backend

Si Maven n'est pas dans votre PATH, vous pouvez:

1. **Utiliser un IDE** (IntelliJ IDEA, Eclipse, VS Code):
   - Ouvrez le projet backend dans l'IDE
   - L'IDE devrait détecter automatiquement Maven et télécharger les dépendances
   - Lancez `RestaurantApplication.java` directement

2. **Installer Maven**:
   - Téléchargez Maven depuis https://maven.apache.org/download.cgi
   - Ajoutez Maven au PATH système
   - Exécutez: `mvn clean install` puis `mvn spring-boot:run`

3. **Utiliser le Maven Wrapper** (si disponible):
   ```bash
   cd backend
   ./mvnw clean install
   ./mvnw spring-boot:run
   ```

## Vérification

1. **Backend**: Vérifiez que le backend démarre sur http://localhost:8080
2. **Frontend**: L'application Flutter devrait se lancer sur votre téléphone
3. **Connexion**: Assurez-vous que votre téléphone et votre PC sont sur le même réseau WiFi

## Si vous avez encore des erreurs

1. **Erreur `parserBuilder()`**:
   - Vérifiez que vous avez bien JJWT 0.12.3 dans `pom.xml`
   - Nettoyez et recompilez: `mvn clean compile`
   - Redémarrez votre IDE

2. **Erreur de connexion backend**:
   - Vérifiez que MySQL est démarré
   - Vérifiez les credentials dans `application.properties`
   - Vérifiez que le port 8080 n'est pas utilisé

3. **Erreur de connexion depuis le téléphone**:
   - Vérifiez que le téléphone et le PC sont sur le même réseau
   - Vérifiez l'IP dans `app_config.dart`
   - Vérifiez que le firewall Windows autorise les connexions sur le port 8080

