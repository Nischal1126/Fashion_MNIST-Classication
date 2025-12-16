import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dress Classifer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ClassifierPage(),
    );
  }
}

// Fashion MNIST class labels
const List<String> fashionClasses = [
  'T-shirt/Top',
  'Trouser',
  'Pullover',
  'Dress',
  'Coat',
  'Sandal',
  'Shirt',
  'Sneaker',
  'Bag',
  'Ankle Boot',
];

// Icons for each class
const List<IconData> fashionIcons = [
  Icons.dry_cleaning_outlined,
  Icons.accessibility_new,
  Icons.checkroom,
  Icons.dry_cleaning,
  Icons.person_outline,
  Icons.flip_outlined,
  Icons.checkroom_outlined,
  Icons.directions_run,
  Icons.shopping_bag_outlined,
  Icons.ice_skating,
];

class ClassifierPage extends StatefulWidget {
  const ClassifierPage({super.key});

  @override
  State<ClassifierPage> createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage> {
  Uint8List? _imageBytes;
  String? _fileName;
  int? _predictedClass;
  bool _isHovering = false;
  bool _isClassifying = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
        _predictedClass = null;
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isClassifying = true;
    });

    // Simulate classification delay (replace with actual API call)
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock prediction - In production, send image to your backend API
    // which runs the PyTorch model
    setState(() {
      _predictedClass = DateTime.now().millisecond % 10;
      _isClassifying = false;
    });
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _fileName = null;
      _predictedClass = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 60),

                // Main content
                _buildMainContent(),

                const SizedBox(height: 60),

                // Class labels reference
                _buildClassReference(),

                const SizedBox(height: 40),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Dress',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Classification',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Colors.white54,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Upload a clothing image to classify',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          // Upload area
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: _isHovering
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isHovering ? Colors.white54 : Colors.white24,
                    width: _isHovering ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageBytes != null
                    ? _buildImagePreview()
                    : _buildUploadPlaceholder(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          if (_imageBytes != null) _buildActionButtons(),

          // Result
          if (_predictedClass != null) ...[
            const SizedBox(height: 40),
            _buildResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 64,
          color: Colors.white.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Click to upload image',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PNG, JPG, or JPEG',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_imageBytes!, fit: BoxFit.contain, height: 280),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: IconButton(
            onPressed: _clearImage,
            icon: const Icon(Icons.close, color: Colors.white70),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
          ),
        ),
        if (_fileName != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fileName!,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Change Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isClassifying ? null : _classifyImage,
            icon: _isClassifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isClassifying ? 'Classifying...' : 'Classify'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Prediction',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Icon(fashionIcons[_predictedClass!], size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            fashionClasses[_predictedClass!],
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Class ${_predictedClass!}',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassReference() {
    return Column(
      children: [
        Text(
          'ALL CLASSES',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(10, (index) {
            final isSelected = _predictedClass == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white54 : Colors.white12,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fashionIcons[index],
                    size: 16,
                    color: isSelected ? Colors.white : Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fashionClasses[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'Dress Classification • Deep Learning Project',
      style: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
    );
  }
}
