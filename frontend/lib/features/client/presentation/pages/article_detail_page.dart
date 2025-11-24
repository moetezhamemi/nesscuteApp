import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/article_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/cart_provider.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  final int? articleId;

  const ArticleDetailPage({super.key, this.articleId});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final ApiService _apiService = ApiService();
  ArticleModel? _article;
  bool _isLoading = true;
  double _userRating = 0;
  int _quantity = 1;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    if (widget.articleId == null) return;

    try {
      final token = ref.read(authProvider).token;
      final userId = ref.read(authProvider).user?.id;
      _apiService.setToken(token);
      
      final article = await _apiService.getArticleById(widget.articleId!);
      
      // Load user's rating if logged in
      if (userId != null) {
        final userRating = await _apiService.getUserRating(widget.articleId!, userId);
        setState(() {
          _article = article;
          _userRating = userRating.toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  Future<void> _addRating(double rating) async {
    if (widget.articleId == null) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      await _apiService.addRating(widget.articleId!, userId, rating.toInt());
      _loadArticle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note ajoutée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _addComment() async {
    if (widget.articleId == null) return;
    if (_commentController.text.trim().isEmpty) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      await _apiService.addComment(
        widget.articleId!,
        userId,
        _commentController.text,
      );
      _commentController.clear();
      _loadArticle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return const Scaffold(
        body: Center(child: Text('Article non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_article!.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_article!.imageUrl != null)
              CachedNetworkImage(
                imageUrl: _article!.imageUrl!.startsWith('http')
                    ? _article!.imageUrl!
                    : '${AppConfig.baseUrlWithoutApi}${_article!.imageUrl}',
                height: 250,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant_menu, size: 80),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _article!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_article!.price}€',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: _article!.globalRating,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('(${_article!.ratingCount})'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_article!.description != null)
                    Text(
                      _article!.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Votre note',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: _userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _userRating = rating;
                      });
                      _addRating(rating);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Commentaires',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _addComment,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_article!.comments != null)
                    ..._article!.comments!.map((comment) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(comment.userName),
                            subtitle: Text(comment.content),
                            trailing: Text(
                              comment.createdAt != null
                                  ? '${comment.createdAt!.day}/${comment.createdAt!.month}/${comment.createdAt!.year}'
                                  : '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_article != null) {
                    for (int i = 0; i < _quantity; i++) {
                      ref.read(cartProvider.notifier).addItem(_article!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$_quantity x ${_article!.name} ajouté(s) au panier'),
                        action: SnackBarAction(
                          label: 'Voir panier',
                          onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
                        ),
                      ),
                    );
                    setState(() => _quantity = 1);
                  }
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Ajouter au panier'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

