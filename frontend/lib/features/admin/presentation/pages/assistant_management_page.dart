import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class AssistantManagementPage extends ConsumerStatefulWidget {
  const AssistantManagementPage({super.key});

  @override
  ConsumerState<AssistantManagementPage> createState() => _AssistantManagementPageState();
}

class _AssistantManagementPageState extends ConsumerState<AssistantManagementPage> {
  final ApiService _apiService = ApiService();
  List<UserModel> _assistants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssistants();
  }

  Future<void> _loadAssistants() async {
    try {
      final token = ref.read(authProvider).token;
      _apiService.setToken(token);
      final assistants = await _apiService.getUsersByRole('ASSISTANT');
      setState(() {
        _assistants = assistants;
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

  Future<void> _addAssistant() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    File? selectedImage;
    final picker = ImagePicker();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un assistant'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: selectedImage != null
                          ? ClipOval(child: Image.file(selectedImage!, fit: BoxFit.cover))
                          : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe *',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (value.length < 6) return 'Au moins 6 caractères';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer mot de passe *',
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                      ),
                    ),
                    obscureText: obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (value != passwordController.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Téléphone *'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (!RegExp(r'^\d{8}$').hasMatch(value)) return 'Doit contenir 8 chiffres';
                      return null;
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

                    await _apiService.register({
                      'name': nameController.text,
                      'email': emailController.text,
                      'password': passwordController.text,
                      'phoneNumber': phoneController.text,
                      'role': 'ASSISTANT',
                      'profileImage': imageUrl,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      _loadAssistants();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assistant ajouté avec succès')),
                      );
                    }
                  } catch (e) {
                    String msg = 'Erreur lors de l\'ajout';
                    if (e.toString().contains('Email already exists') || 
                        e.toString().contains('409') ||
                        e.toString().contains('status code of 409')) {
                      msg = 'Cet email existe déjà';
                    } else if (e.toString().contains('400')) {
                      msg = 'Données invalides. Vérifiez les informations saisies.';
                    }
                    setState(() => errorMessage = msg);
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

  Future<void> _editAssistant(UserModel assistant) async {
    final nameController = TextEditingController(text: assistant.name);
    final emailController = TextEditingController(text: assistant.email);
    final phoneController = TextEditingController(text: assistant.phoneNumber);
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    File? selectedImage;
    final picker = ImagePicker();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'assistant'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: selectedImage != null
                          ? ClipOval(child: Image.file(selectedImage!, fit: BoxFit.cover))
                          : assistant.profileImage != null
                              ? ClipOval(
                                  child: Image.network(
                                    assistant.profileImage!.startsWith('http')
                                        ? assistant.profileImage!
                                        : '${AppConfig.baseUrlWithoutApi}${assistant.profileImage}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 40),
                                  ),
                                )
                              : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Téléphone *'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (!RegExp(r'^\d{8}$').hasMatch(value)) return 'Doit contenir 8 chiffres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Réinitialiser le mot de passe (optionnel)', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'Au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmer nouveau mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                      ),
                    ),
                    obscureText: obscureConfirmPassword,
                    validator: (value) {
                      if (passwordController.text.isNotEmpty && value != passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
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
                    String? imageUrl = assistant.profileImage;
                    if (selectedImage != null) {
                      imageUrl = await _apiService.uploadImageFile(selectedImage!);
                    }

                    final updatedAssistant = UserModel(
                      id: assistant.id,
                      email: emailController.text,
                      name: nameController.text,
                      phoneNumber: phoneController.text,
                      role: 'ASSISTANT',
                      profileImage: imageUrl,
                    );
                    
                    await _apiService.updateUser(assistant.id!, updatedAssistant);

                    if (passwordController.text.isNotEmpty) {
                      await _apiService.resetPassword(assistant.id!, passwordController.text);
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      _loadAssistants();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Assistant modifié avec succès')),
                      );
                    }
                  } catch (e) {
                    String msg = 'Erreur lors de la modification';
                    if (e.toString().contains('Email already exists') || 
                        e.toString().contains('409') ||
                        e.toString().contains('status code of 409')) {
                      msg = 'Cet email existe déjà';
                    } else if (e.toString().contains('400')) {
                      msg = 'Données invalides. Vérifiez les informations saisies.';
                    }
                    setState(() => errorMessage = msg);
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

  Future<void> _deleteAssistant(UserModel assistant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${assistant.name} ?'),
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
        await _apiService.deleteUser(assistant.id!);
        _loadAssistants();
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
        title: const Text('Gestion des assistants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAssistant,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assistants.isEmpty
              ? const Center(child: Text('Aucun assistant'))
              : ListView.builder(
                  itemCount: _assistants.length,
                  itemBuilder: (context, index) {
                    final assistant = _assistants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: assistant.profileImage != null
                              ? NetworkImage(
                                  assistant.profileImage!.startsWith('http')
                                      ? assistant.profileImage!
                                      : '${AppConfig.baseUrlWithoutApi}${assistant.profileImage}',
                                )
                              : null,
                          child: assistant.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(assistant.name),
                        subtitle: Text(assistant.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editAssistant(assistant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteAssistant(assistant),
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

