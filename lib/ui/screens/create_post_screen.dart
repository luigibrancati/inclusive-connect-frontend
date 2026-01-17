import 'dart:io';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_connect/ui/widgets/audio_post_widget.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/feed_service.dart';
import '../../data/services/gemini_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Audio Mode
  File? _audioFile;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  Color? _selectedColor;

  final List<Color> _audioBackgroundColorAvailableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // Tone Analysis
  bool _isAnalyzingTone = false;
  String? _toneEmoji;
  String? _toneExplanation;

  // Alt Text
  final Map<String, String> _imageAltTexts = {};

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    // Listen to animation to update UI during swipes if desired,
    // or just index changes. For simple buttons, index change via _handleTabSelection
    // might be enough but it only setStates on specific conditions.
    // Let's ensure we rebuild to update button states.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // This handles swipe completion
        setState(() {});
      }
    });
  }

  void _handleTabSelection() {
    // Only reacting to index changes for logic handling
    if (_tabController.indexIsChanging) {
      setState(() {}); // Ensure buttons update immediately on tap
    }

    // Check if we switched to Text/Image tab
    if (_tabController.index == 0) {
      if (_audioFile != null || _recordedPath != null) {
        setState(() {
          _audioFile = null;
          _recordedPath = null;
          if (_isPlaying) _audioPlayer.stop();
          _isPlaying = false;
          _selectedColor = null;
        });
      }
    }
    // Check if we switched to Audio tab
    else if (_tabController.index == 1) {
      if (_titleController.text.isNotEmpty ||
          _bodyController.text.isNotEmpty ||
          _selectedImages.isNotEmpty ||
          _toneEmoji != null) {
        setState(() {
          _titleController.clear();
          _bodyController.clear();
          _selectedImages.clear();
          _imageAltTexts.clear();
          _toneEmoji = null;
          _toneExplanation = null;
        });
      }
    }
  }

  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
      _generateAltText(File(image.path));
    }
  }

  Future<void> _generateAltText(File image) async {
    try {
      final gemini = context.read<GeminiService>();
      final bytes = await image.readAsBytes();
      final altText = await gemini.generateAltText(bytes);

      if (mounted) {
        setState(() {
          _imageAltTexts[image.path] = altText;
        });
        debugPrint("Generated Alt Text for ${image.path}: $altText");
      }
    } catch (e) {
      debugPrint("Error generating alt text: $e");
    }
  }

  Future<void> _analyzeTone() async {
    final text = "${_titleController.text}. ${_bodyController.text}";
    if (text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.analyzeToneWriteAtLeastOneWord,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzingTone = true;
      _toneEmoji = null;
      _toneExplanation = null;
    });

    try {
      final gemini = context.read<GeminiService>();
      final result = await gemini.analyzeTone(text);
      if (mounted) {
        setState(() {
          _toneEmoji = result['emoji'];
          _toneExplanation = result['explanation'];
        });
      }
    } catch (e) {
      debugPrint("Tone analysis failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzingTone = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      final file = _selectedImages[index];
      _imageAltTexts.remove(file.path);
      _selectedImages.removeAt(index);
    });
  }

  // Audio Logic
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
        if (path != null) {
          _audioFile = File(path);
        }
      });
    } catch (e) {
      debugPrint('Error stopping record: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _audioFile = File(path);
        _recordedPath = path;
      });
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  Future<void> _submitPost() async {
    // Determine mode based on active tab
    final isAudioMode = _tabController.index == 1;

    if (isAudioMode) {
      if (_audioFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please record or select an audio file'),
          ),
        );
        return;
      }
      _titleController.clear();
      _bodyController.clear();
    } else {
      if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.submitPostFillAllFields,
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? colorHex;
      if (_selectedColor != null) {
        colorHex =
            '#${_selectedColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Simple hex
      }

      debugPrint(
        "Creating audio post with color $_selectedColor (hex: $colorHex)",
      );
      await context.read<FeedService>().createPost(
        _titleController.text,
        _bodyController.text,
        images: isAudioMode ? [] : _selectedImages,
        audio: isAudioMode ? _audioFile : null,
        audioBackgroundColorHex: colorHex,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.postCreatedSuccessfully,
            ),
          ),
        );
        context.go('/home'); // Or pop
      }
    } catch (e) {
      debugPrint("Error creating post: $e (${e.toString()})");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.postCreationFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newPostTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    AppLocalizations.of(context)!.newPostActionButtonPost,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModeSwitcher(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Text & Image
                  _buildTextAndImageTab(),
                  // Tab 2: Audio
                  _buildAudioTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          _buildSwitchItem("Text / Image", Icons.article, 0),
          _buildSwitchItem("Audio", Icons.audiotrack, 1),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String label, IconData icon, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(21.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAndImageTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.newPostTitleHint,
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // Tone Analysis Result
          if (_toneEmoji != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(_toneEmoji!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _toneExplanation ?? "",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.newPostBodyHint,
                border: InputBorder.none,
              ),
              maxLines: null,
              expands: true,
            ),
          ),
          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  final file = _selectedImages[index];
                  final alt = _imageAltTexts[file.path];

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (alt != null)
                              Container(
                                width: 80,
                                padding: const EdgeInsets.all(2),
                                color: Colors.black54,
                                child: Text(
                                  AppLocalizations.of(context)!.altText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              const SizedBox(
                                width: 80,
                                child: LinearProgressIndicator(minHeight: 4),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const Divider(),
          Row(
            children: [
              IconButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.image),
              ),
              IconButton(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
              ),
              const Spacer(),
              // Tone Analysis Button
              TextButton.icon(
                onPressed: _isAnalyzingTone ? null : _analyzeTone,
                icon: _isAnalyzingTone
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.emoji_emotions_outlined),
                label: Text(AppLocalizations.of(context)!.analyzeToneButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_audioFile != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AudioPostWidget(
                  colorHex:
                      _selectedColor?.value.toRadixString(16) ??
                      Colors.blue.value.toRadixString(16),
                  filePath: _recordedPath,
                ),
              ),
              const SizedBox(height: 20),
              // Color Picker
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _audioBackgroundColorAvailableColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    onPressed: _togglePlayback,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _audioFile = null;
                        _recordedPath = null;
                        _selectedColor = null;
                      });
                      _audioPlayer.stop();
                    },
                  ),
                ],
              ),
            ] else ...[
              Text(
                _isRecording ? "Recording..." : "Tap mic to record",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTapUp: (_) => _stopRecording(),
                onTapDown: (_) => _startRecording(),
                // Also support simple tap toggle for convenience
                onTap: () {
                  if (_isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("OR"),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Audio File"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
