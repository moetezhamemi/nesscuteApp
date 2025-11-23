package com.nesscute.restaurant.service;

import com.nesscute.restaurant.dto.AiQueryRequest;
import com.nesscute.restaurant.dto.AiQueryResponse;
import com.nesscute.restaurant.entity.Article;
import com.nesscute.restaurant.entity.Article.ArticleType;
import com.nesscute.restaurant.repository.ArticleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AiService {

    private final ArticleRepository articleRepository;

    @Value("${ollama.base-url}")
    private String ollamaBaseUrl;

    @Value("${ollama.model}")
    private String ollamaModel;

    private final WebClient webClient = WebClient.builder().build();

    public AiQueryResponse processQuery(AiQueryRequest request) {
        String question = request.getQuestion().toLowerCase();

        // Vérifier si la question est pertinente
        if (!isRelevantQuestion(question)) {
            return AiQueryResponse.builder()
                    .answer("Désolé, je ne peux pas vous aider pour cette question. Je peux uniquement répondre aux questions concernant le menu, les articles, les ratings et les commentaires du restaurant NessCute.")
                    .isRelevant(false)
                    .build();
        }

        // Récupérer les données pertinentes (RAG)
        String context = buildContext(question);

        // Construire le prompt pour Ollama
        String prompt = buildPrompt(question, context);

        // Appeler Ollama
        try {
            String response = callOllama(prompt);
            return AiQueryResponse.builder()
                    .answer(response)
                    .isRelevant(true)
                    .build();
        } catch (Exception e) {
            return AiQueryResponse.builder()
                    .answer("Désolé, une erreur s'est produite lors du traitement de votre question.")
                    .isRelevant(false)
                    .build();
        }
    }

    private boolean isRelevantQuestion(String question) {
        String[] relevantKeywords = {
                "menu", "article", "plat", "burger", "sandwich", "boisson", "dessert",
                "sucré", "salé", "prix", "rating", "note", "avis", "commentaire",
                "meilleur", "recommandation", "commande", "restaurant", "nesscute"
        };

        for (String keyword : relevantKeywords) {
            if (question.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private String buildContext(String question) {
        StringBuilder context = new StringBuilder();

        // Rechercher des articles pertinents
        if (question.contains("burger")) {
            List<Article> burgers = articleRepository.findByType(ArticleType.BURGER);
            context.append("Burgers disponibles:\n");
            burgers.forEach(b -> context.append(String.format("- %s: %.2f€ (Note: %.1f/5, %d avis)\n",
                    b.getName(), b.getPrice(), b.getGlobalRating(), b.getRatingCount())));
        }

        if (question.contains("sandwich")) {
            List<Article> sandwiches = articleRepository.findByType(ArticleType.SANDWICH);
            context.append("Sandwiches disponibles:\n");
            sandwiches.forEach(s -> context.append(String.format("- %s: %.2f€ (Note: %.1f/5, %d avis)\n",
                    s.getName(), s.getPrice(), s.getGlobalRating(), s.getRatingCount())));
        }

        if (question.contains("boisson")) {
            List<Article> boissons = articleRepository.findByType(ArticleType.BOISSON);
            context.append("Boissons disponibles:\n");
            boissons.forEach(b -> context.append(String.format("- %s: %.2f€ (Note: %.1f/5, %d avis)\n",
                    b.getName(), b.getPrice(), b.getGlobalRating(), b.getRatingCount())));
        }

        if (question.contains("meilleur") || question.contains("recommandation")) {
            List<Article> topArticles = articleRepository.findByOrderByGlobalRatingDesc();
            context.append("Articles les mieux notés:\n");
            topArticles.stream().limit(5).forEach(a -> context.append(String.format("- %s: %.2f€ (Note: %.1f/5, %d avis)\n",
                    a.getName(), a.getPrice(), a.getGlobalRating(), a.getRatingCount())));
        }

        // Recherche générale
        if (context.length() == 0) {
            List<Article> allArticles = articleRepository.findAll();
            context.append("Articles du menu:\n");
            allArticles.forEach(a -> context.append(String.format("- %s (%s): %.2f€ (Note: %.1f/5)\n",
                    a.getName(), a.getType().name(), a.getPrice(), a.getGlobalRating())));
        }

        return context.toString();
    }

    private String buildPrompt(String question, String context) {
        return String.format(
                "Tu es un assistant intelligent pour le restaurant NessCute. " +
                "Réponds à la question du client en utilisant uniquement les informations suivantes sur le menu:\n\n" +
                "%s\n\n" +
                "Question du client: %s\n\n" +
                "Réponds de manière claire, amicale et concise en français. " +
                "Si tu n'as pas assez d'informations, dis-le poliment.",
                context, question
        );
    }

    private String callOllama(String prompt) {
        try {
            OllamaRequest request = new OllamaRequest(ollamaModel, prompt, false);
            
            String responseText = webClient.post()
                    .uri(ollamaBaseUrl + "/api/generate")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            // Parser la réponse Ollama (format JSON avec champ "response")
            if (responseText != null) {
                try {
                    ObjectMapper mapper = new ObjectMapper();
                    JsonNode jsonNode = mapper.readTree(responseText);
                    if (jsonNode.has("response")) {
                        return jsonNode.get("response").asText();
                    }
                } catch (Exception e) {
                    // Fallback: simple string parsing
                    if (responseText.contains("\"response\"")) {
                        int start = responseText.indexOf("\"response\"") + 12;
                        int end = responseText.indexOf("\"", start);
                        if (end > start) {
                            return responseText.substring(start, end);
                        }
                    }
                }
            }
            
            return "Désolé, je n'ai pas pu générer de réponse.";
        } catch (Exception e) {
            return "Désolé, une erreur s'est produite lors de la communication avec l'IA: " + e.getMessage();
        }
    }

    // Classes internes pour la requête Ollama
    private static class OllamaRequest {
        private String model;
        private String prompt;
        private boolean stream;

        public OllamaRequest(String model, String prompt, boolean stream) {
            this.model = model;
            this.prompt = prompt;
            this.stream = stream;
        }

        public String getModel() { return model; }
        public String getPrompt() { return prompt; }
        public boolean isStream() { return stream; }
    }
}

