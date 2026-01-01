import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/user_api.dart';
import '../services/token_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color kPurple = Color(0xFF5B288E);
  static const Color kBorder = Color(0xFFD7CDE3);

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  final _location = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  String avatarUrl = "";
  File? pickedImageFile;

  bool loading = true;
  bool saving = false;
  String? error;

  bool _looksLikeUuid(String v) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(v.trim());
  }

  String _displayFromClaims(Map<String, dynamic> c) {
    String s(dynamic v) => (v ?? '').toString().trim();

    final preferred = s(c['preferred_username']);
    final cognitoUsername = s(c['cognito:username']);
    final username = s(c['username']);
    final name = s(c['name']);
    final email = s(c['email']);
    final sub = s(c['sub']);

    final candidates = [preferred, cognitoUsername, username, name, email];
    for (final v in candidates) {
      if (v.isNotEmpty && !_looksLikeUuid(v)) return v;
    }
    return sub.isNotEmpty ? sub : "";
  }

  Future<String> _tokenDisplayName() async {
    final idToken = await TokenStorage.getIdToken();
    if (idToken == null || idToken.isEmpty) return "";
    try {
      final claims = JwtDecoder.decode(idToken);
      return _displayFromClaims(claims);
    } catch (_) {
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final me = await UserApi.getMe();

      _name.text = (me['name'] ?? '').toString();
      _bio.text = (me['bio'] ?? '').toString();
      _location.text = (me['location'] ?? '').toString();
      _phone.text = (me['phone'] ?? '').toString();
      final backendEmail = (me['email'] ?? '').toString().trim();

      // if backend doesn't send email, take from idToken
      final idToken = await TokenStorage.getIdToken();
      String tokenEmail = "";
      if (idToken != null && idToken.isNotEmpty) {
        try {
          final claims = JwtDecoder.decode(idToken);
          tokenEmail = (claims['email'] ?? '').toString().trim();
        } catch (_) {}
      }

      _email.text = backendEmail.isNotEmpty ? backendEmail : tokenEmail;

      final rawUsername = (me['username'] ?? '').toString().trim();

      // ✅ If backend has UUID, replace with token-based username (Test 33)
      final tokenName = await _tokenDisplayName();
      final fixedUsername =
          (rawUsername.isNotEmpty && !_looksLikeUuid(rawUsername))
          ? rawUsername
          : (tokenName.isNotEmpty ? tokenName : "");

      _username.text = fixedUsername;

      final url = await UserApi.getAvatarUrl();
      avatarUrl = url ?? '';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;

    setState(() => pickedImageFile = File(xfile.path));
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
    });

    try {
      // ✅ Never save UUID as username
      var usernameToSave = _username.text.trim();
      if (usernameToSave.isEmpty || _looksLikeUuid(usernameToSave)) {
        final tokenName = await _tokenDisplayName();
        if (tokenName.isNotEmpty) {
          usernameToSave = tokenName;
          _username.text = tokenName;
        }
      }

      // 1) Upload avatar if selected
      if (pickedImageFile != null) {
        final file = pickedImageFile!;
        final lower = file.path.toLowerCase();
        final contentType = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';

        final presign = await UserApi.presignAvatarUpload(
          contentType: contentType,
        );

        final uploadUrl = presign['uploadUrl'] as String;
        final key = presign['key'] as String;

        await UserApi.uploadToS3Presigned(
          uploadUrl: uploadUrl,
          file: file,
          contentType: contentType,
        );

        await UserApi.confirmAvatar(key: key);

        final signed = await UserApi.getAvatarUrl();
        if (signed != null) avatarUrl = signed;

        pickedImageFile = null;
      }

      // 2) Save profile fields
      await UserApi.updateMe(
        name: _name.text.trim(),
        username: usernameToSave,
        bio: _bio.text.trim(),
        location: _location.text.trim(),
        phone: _phone.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    _location.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final ImageProvider avatarProvider = pickedImageFile != null
        ? FileImage(pickedImageFile!)
        : (avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const NetworkImage('https://via.placeholder.com/150'))
              as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPurple),
          onPressed: saving ? null : () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Edit your profile",
          style: TextStyle(color: kPurple, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : _save,
            child: const Text(
              "Save",
              style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kBorder, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 14,
                          offset: Offset(0, 10),
                          color: Color(0x11000000),
                        ),
                      ],
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: avatarProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: InkWell(
                      onTap: saving ? null : _pickPhoto,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: kPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _Label("Name"),
            _Field(controller: _name, hint: "Enter name"),

            const SizedBox(height: 14),
            _Label("Username"),
            _Field(controller: _username, hint: "@username"),

            const SizedBox(height: 14),
            _Label("Bio"),
            _Field(controller: _bio, hint: "Write something...", maxLines: 3),

            const SizedBox(height: 14),
            _Label("Location"),
            _Field(controller: _location, hint: "City, State"),

            const SizedBox(height: 14),
            _Label("Phone number"),
            _Field(controller: _phone, hint: "123-456-7890"),

            const SizedBox(height: 14),
            _Label("Email"),
            _Field(controller: _email, hint: "email", enabled: false),

            if (error != null) ...[
              const SizedBox(height: 14),
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],

            const SizedBox(height: 20),
            if (saving) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: kPurple,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool enabled;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.enabled = true,
  });

  static const Color kBorder = Color(0xFFD7CDE3);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 2),
        ),
      ),
    );
  }
}
