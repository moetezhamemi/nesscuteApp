import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/article_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class ArticleManagementPage extends ConsumerStatefulWidget {
  const ArticleManagementPage({super.key});

  @override
  ConsumerState<ArticleManagementPage> createState() => _ArticleManagementPageState();
}

class _ArticleManagementPageState extends ConsumerState<ArticleManagementPage> {
  final ApiService _apiService = ApiService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;
  final List<String> _articleTypes = [
    'SUCRE',
    'SALE',
    'BURGER',
    'SANDWICH',
    'BOISSON',
    'DESSERT',
    'PIZZA'
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      final articles = await _apiService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _addArticle() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String selectedType = _articleTypes.first;
    File? selectedImage;
    final picker = ImagePicker();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un article'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur image: $e')),
                        );
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Prix *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null) return 'Prix invalide';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: _articleTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    String? imageUrl;
                    if (selectedImage != null) {
                      imageUrl = await _apiService.uploadImageFile(selectedImage!);
                    }

                    final price = double.parse(priceController.text.replaceAll(',', '.'));

                    final article = ArticleModel(
                      name: nameController.text,
                      description: descriptionController.text,
                      price: price,
                      type: selectedType,
                      imageUrl: imageUrl,
                    );

                    await _apiService.createArticle(article);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadArticles();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Article ajouté avec succès')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editArticle(ArticleModel article) async {
    final nameController = TextEditingController(text: article.name);
    final descriptionController = TextEditingController(text: article.description);
    final priceController = TextEditingController(text: article.price.toString());
    String selectedType = article.type;
    File? selectedImage;
    final picker = ImagePicker();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'article'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur image: $e')),
                        );
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : article.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: article.imageUrl!.startsWith('http')
                                      ? article.imageUrl!
                                      : '${AppConfig.baseUrlWithoutApi}${article.imageUrl}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                              : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Prix *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null) return 'Prix invalide';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _articleTypes.contains(selectedType) ? selectedType : _articleTypes.first,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: _articleTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    String? imageUrl = article.imageUrl;
                    if (selectedImage != null) {
                      imageUrl = await _apiService.uploadImageFile(selectedImage!);
                    }

                    final price = double.parse(priceController.text.replaceAll(',', '.'));

                    final updatedArticle = ArticleModel(
                      id: article.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      price: price,
                      type: selectedType,
                      imageUrl: imageUrl,
                      globalRating: article.globalRating,
                      ratingCount: article.ratingCount,
                    );

                    await _apiService.updateArticle(article.id!, updatedArticle);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadArticles();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Article modifié avec succès')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la modification: $e')),
                    );
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteArticle(ArticleModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${article.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteArticle(article.id!);
        _loadArticles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addArticle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? const Center(child: Text('Aucun article'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: article.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: article.imageUrl!.startsWith('http')
                                    ? article.imageUrl!
                                    : '${AppConfig.baseUrlWithoutApi}${article.imageUrl}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.restaurant_menu),
                              )
                            : const Icon(Icons.restaurant_menu),
                        title: Text(article.name),
                        subtitle: Text('${article.price}€ - ${article.type}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editArticle(article),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteArticle(article),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

