import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/core/location/location_service.dart';
import 'package:zymm/features/home/presentation/greeting_screen.dart';
import 'package:zymm/features/auth/presentation/viewmodel/owner_registration_viewmodel.dart';
import 'package:zymm/features/auth/presentation/registration_screen.dart';
import 'package:zymm/common/widgets/profile_image_picker.dart';

class OwnerRegistrationScreen extends StatefulWidget {
  const OwnerRegistrationScreen({super.key});

  @override
  State<OwnerRegistrationScreen> createState() => _OwnerRegistrationScreenState();
}

class _OwnerRegistrationScreenState extends State<OwnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal details
  final _displayNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Gym details
  final _gymNameController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _gymAddressController = TextEditingController();
  final _gymContactController = TextEditingController();
  final _gymEmailController = TextEditingController();
  
  String _selectedGender = 'M';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  LocationData? _gymLocation;
  bool _isLoadingLocation = false;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    // Note: We create OwnerRegistrationViewModel in the build method with ChangeNotifierProvider
    // so resetState will be called when the screen is first built
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _mobileController.dispose();
    _ownerEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gymNameController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _gymAddressController.dispose();
    _gymContactController.dispose();
    _gymEmailController.dispose();
    super.dispose();
  }

  Future<void> _fetchGymLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final location = await LocationService.instance.getLocationWithErrorHandling(context);
    
    setState(() {
      _gymLocation = location;
      _isLoadingLocation = false;
    });

    if (location != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym location captured successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerRegistrationViewModel(),
      child: Consumer<OwnerRegistrationViewModel>(
        builder: (context, ownerRegVM, child) {
          if (ownerRegVM.state == ViewState.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GreetingScreen(
                    displayName: ownerRegVM.registrationResponse?.displayName ?? 'Owner',
                  ),
                ),
              );
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Owner Registration'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Switch to Member Registration
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => OwnerRegistrationViewModel(),
                                  child: const RegistrationScreen(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text(
                            "I'm a member",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Register Your Gym',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please fill in your personal and gym details',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // PERSONAL DETAILS SECTION
                      _buildSectionHeader('Personal Details'),
                      const SizedBox(height: 16),

                      // Profile Image Picker
                      ProfileImagePicker(
                        base64Image: _profileImageBase64,
                        onImageSelected: (base64Image) {
                          setState(() {
                            _profileImageBase64 = base64Image;
                          });
                        },
                        size: 100,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to add profile picture (optional)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number *',
                          hintText: 'Enter your mobile',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter mobile number';
                          if (value!.length < 10) return 'Enter valid mobile number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ownerEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Personal Email (Optional)',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'M', child: Text('Male')),
                          DropdownMenuItem(value: 'F', child: Text('Female')),
                          DropdownMenuItem(value: 'O', child: Text('Other')),
                        ],
                        onChanged: (value) => setState(() => _selectedGender = value!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          hintText: 'Create password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter password';
                          if (value!.length < 6) return 'Password must be 6+ characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password *',
                          hintText: 'Re-enter password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please confirm password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // GYM DETAILS SECTION
                      _buildSectionHeader('Gym Details'),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _gymNameController,
                        decoration: const InputDecoration(
                          labelText: 'Gym Name *',
                          hintText: 'Enter gym name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter gym name' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.map),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _gymAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Gym Address *',
                          hintText: 'Enter complete address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 2,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter gym address' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _gymContactController,
                        decoration: const InputDecoration(
                          labelText: 'Gym Contact Number *',
                          hintText: 'Enter gym contact',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_in_talk),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter gym contact';
                          if (value!.length < 10) return 'Enter valid contact number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _gymEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Gym Official Email *',
                          hintText: 'Enter gym email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter gym email';
                          if (!value!.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gym Location
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gym Location *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_gymLocation != null)
                                  const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_gymLocation != null)
                              Text(
                                'Lat: ${_gymLocation!.latitude}\nLong: ${_gymLocation!.longitude}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            else
                              const Text(
                                'Location not captured yet',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isLoadingLocation ? null : _fetchGymLocation,
                                icon: _isLoadingLocation
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.my_location),
                                label: Text(_gymLocation != null ? 'Update Location' : 'Capture Location'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: ownerRegVM.state == ViewState.loading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_gymLocation == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please capture gym location'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    ownerRegVM.registerOwner(
                                      displayName: _displayNameController.text.trim(),
                                      mobile: _mobileController.text.trim(),
                                      password: _passwordController.text,
                                      gender: _selectedGender,
                                      ownerPersonalEmail: _ownerEmailController.text.trim().isNotEmpty
                                          ? _ownerEmailController.text.trim()
                                          : null,
                                      displayPic: _profileImageBase64,
                                      gymName: _gymNameController.text.trim(),
                                      state: _stateController.text.trim(),
                                      city: _cityController.text.trim(),
                                      gymAddress: _gymAddressController.text.trim(),
                                      gymOfficialContactNo: _gymContactController.text.trim(),
                                      gymOfficialEmail: _gymEmailController.text.trim(),
                                      gymOfficialLocationLat: _gymLocation!.latitude,
                                      gymOfficialLocationLong: _gymLocation!.longitude,
                                    );
                                  }
                                },
                          child: ownerRegVM.state == ViewState.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Register as Owner',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      // Error Message
                      if (ownerRegVM.state == ViewState.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ownerRegVM.errorMessage ?? 'An error occurred',
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Already have account
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Already have an account? Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
