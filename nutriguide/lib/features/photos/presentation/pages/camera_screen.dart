import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriguide/core/services/logging_service.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/photos/presentation/providers/camera_provider.dart';
import 'package:nutriguide/features/photos/presentation/widgets/scan_animation.dart';
// Assuming RecipeCard exists or will be created in next step
import 'package:nutriguide/features/recipes/presentation/widgets/recipe_card.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Select back camera
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset
            .medium, // Medium resolution is sufficient for ingredient recognition while keeping performance good
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      // We catch camera initialization errors silently (logging instead of crashing)
      // because permission denials are expected - the UI should gracefully show the gallery option instead.
      LoggingService.instance.error('Camera initialization failed', e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized ||
        _controller == null ||
        _controller!.value.isTakingPicture) {
      return;
    }

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      await ref.read(cameraProvider.notifier).analyzePhoto(bytes);
    } catch (e) {
      LoggingService.instance.error('Failed to capture photo', e);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        await ref.read(cameraProvider.notifier).analyzePhoto(bytes);
      }
    } catch (e) {
      LoggingService.instance.error('Failed to pick image from gallery', e);
    }
  }

  void _resetScan() {
    ref.read(cameraProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Viewfinder
          if (_isCameraInitialized)
            Center(child: CameraPreview(_controller!))
          else
            const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),

          // 2. Overlays based on State
          cameraState.when(
            // --- IDLE STATE: Viewfinder & Controls ---
            data: (photo) {
              if (photo == null) return _buildControls();

              // --- SUCCESS STATE: Results Overlay ---
              return _buildResults(photo);
            },

            // --- LOADING STATE: Scan Animation ---
            loading: () => const ScanAnimation(),

            // --- ERROR STATE ---
            error: (err, stack) => _buildError(err.toString()),
          ),

          // Back Button (always visible unless loading)
          if (!cameraState.isLoading)
            Positioned(
              top: 50,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 50),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Gallery Button
            IconButton(
              icon: const Icon(Icons.photo_library,
                  color: Colors.white, size: 32),
              onPressed: _pickFromGallery,
            ),

            // Shutter Button
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Flash/Settings (Placeholder)
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(photo) {
    return Container(
      color: Colors.black54, // Dim background
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scan Results',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: _resetScan,
                            child: const Text('Scan Again'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Detected Ingredients
                      Text(
                        'Found Ingredients:',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: photo.ingredientsDetected.map<Widget>((ing) {
                          return Chip(
                            label: Text(ing),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle:
                                const TextStyle(color: AppColors.primary),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Suggested Recipes
                      if (photo.suggestedRecipes != null &&
                          photo.suggestedRecipes!.isNotEmpty) ...[
                        Text(
                          'What you can cook:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ...photo.suggestedRecipes!.map((recipe) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              // This widget will be available after next step
                              child: RecipeCard(recipe: recipe),
                            )),
                      ] else
                        const Text(
                            'No direct recipes found. Try the chat to ask specifically!'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetScan,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
