import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'visitor_details_screen.dart';

/// Screen 3: Visitor Registration / Edit Form strictly matching the assignment requirements:
/// Fields:
/// 1. Visitor Name (Text, Required)
/// 2. Mobile Number (Numeric, Required, exactly 10 digits)
/// 3. Email (Email, Optional; validated if entered)
/// 4. Visitor Type (Dropdown: Customer, Vendor, Other)
/// 5. Project (Dropdown: Project A, Project B, Project C)
/// 6. Purpose of Visit (Text, Required)
///
/// Features:
/// - Register new visitors / Edit existing visitor information
/// - Save data through REST APIs (POST / PUT)
/// - Validation messages
/// - Confirmation feedback
/// - Generates QR code using visitor ID
/// - Keyboard-friendly scrollable layout
class VisitorFormScreen extends StatefulWidget {
  final Visitor? visitor;

  const VisitorFormScreen({super.key, this.visitor});

  bool get isEditMode => visitor != null;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  late String _selectedVisitorType;
  late String _selectedProject;

  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    _nameController = TextEditingController(text: v?.name ?? '');
    _mobileController = TextEditingController(text: v?.mobile ?? '');
    _emailController = TextEditingController(text: v?.email ?? '');
    _purposeController = TextEditingController(text: v?.purpose ?? '');

    _selectedVisitorType = v?.visitorType ?? Visitor.visitorTypes.first;
    _selectedProject = v?.project ?? Visitor.projects.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visitor name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final clean = value.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(clean)) {
      return 'Mobile number must be exactly 10 digits';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final email = value.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Purpose of visit is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<VisitorProvider>(context, listen: false);

    if (widget.isEditMode) {
      // Edit existing visitor
      final updated = widget.visitor!.copyWith(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        clearEmail: _emailController.text.trim().isEmpty,
        visitorType: _selectedVisitorType,
        project: _selectedProject,
        purpose: _purposeController.text.trim(),
      );

      final result = await provider.updateVisitor(updated);
      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visitor "${result.name}" updated successfully'),
            backgroundColor: AppTheme.onyxDark,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update visitor'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } else {
      // Register new visitor
      final newVisitor = Visitor(
        id: '', // Will be assigned by API or provider (e.g. VIS008)
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        visitorType: _selectedVisitorType,
        project: _selectedProject,
        purpose: _purposeController.text.trim(),
        status: Visitor.statusRegistered,
        createdAt: DateTime.now().toIso8601String(),
      );

      final created = await provider.registerVisitor(newVisitor);
      if (!mounted) return;

      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visitor "${created.name}" registered with ID: ${created.id}'),
            backgroundColor: AppTheme.onyxDark,
            duration: const Duration(seconds: 3),
          ),
        );

        // Replace registration screen with the Visitor Details screen displaying the generated QR
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VisitorDetailsScreen(visitorId: created.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to register visitor'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14120F),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/icon.png',
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            Container(height: 14, width: 1.2, color: const Color(0xFF382F24)),
            const SizedBox(width: 8),
            Text(
              isEdit ? 'Edit Visitor' : 'Visitor Registration',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF26201A), height: 1),
        ),
      ),
      body: Consumer<VisitorProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDE7DD)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primaryGold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEdit
                                  ? 'Update visitor details. Changes will be synced to the REST API.'
                                  : 'A unique Visitor ID and QR code will be generated upon registration.',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Form Container Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE7DD), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Visitor Name Field
                          _buildFieldLabel('Visitor Name', isRequired: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            validator: _validateName,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'Enter full name (e.g. Rahul Sharma)',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 2. Mobile Number Field
                          _buildFieldLabel('Mobile Number', isRequired: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _mobileController,
                            validator: _validateMobile,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: _inputDecoration(
                              hint: '10-digit mobile number',
                              prefixIcon: Icons.phone_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 3. Email Address Field (Optional)
                          _buildFieldLabel('Email Address', isRequired: false),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'Optional (e.g. rahul@example.com)',
                              prefixIcon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 4. Visitor Type Dropdown
                          _buildFieldLabel('Visitor Type', isRequired: true),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedVisitorType,
                            decoration: _inputDecoration(
                              hint: 'Select visitor type',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            items: Visitor.visitorTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedVisitorType = val);
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          // 5. Project Dropdown
                          _buildFieldLabel('Project', isRequired: true),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProject,
                            decoration: _inputDecoration(
                              hint: 'Select residential project',
                              prefixIcon: Icons.location_city_outlined,
                            ),
                            items: Visitor.projects.map((proj) {
                              return DropdownMenuItem(
                                value: proj,
                                child: Text(proj),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedProject = val);
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          // 6. Purpose of Visit Field
                          _buildFieldLabel('Purpose of Visit', isRequired: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _purposeController,
                            validator: _validatePurpose,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              hint: 'Enter visit purpose (e.g. Site Visit, Flat Handover, Inspection)',
                              prefixIcon: Icons.notes_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons (Save & Cancel)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Cancel',
                            isOutlined: true,
                            backgroundColor: const Color(0xFF64748B),
                            textColor: const Color(0xFF475569),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            label: isEdit ? 'Save Changes' : 'Register Visitor',
                            icon: isEdit ? Icons.check_rounded : Icons.person_add_rounded,
                            backgroundColor: AppTheme.primaryGold,
                            isLoading: provider.isActionLoading,
                            onPressed: _submitForm,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }
}
