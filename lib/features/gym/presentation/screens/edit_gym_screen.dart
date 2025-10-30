import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:zymm/features/gym/presentation/viewmodel/gym_viewmodel.dart';

class EditGymScreen extends StatefulWidget {
  final int gymId;

  const EditGymScreen({super.key, required this.gymId});

  @override
  State<EditGymScreen> createState() => _EditGymScreenState();
}

class _EditGymScreenState extends State<EditGymScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  // Form controllers
  late TextEditingController _gymNameController;
  late TextEditingController _contactNoController;
  late TextEditingController _officialEmailController;
  late TextEditingController _gymAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _locationLatController;
  late TextEditingController _locationLongController;
  
  // Owner details (read-only)
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerMobileController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _gymNameController = TextEditingController();
    _contactNoController = TextEditingController();
    _officialEmailController = TextEditingController();
    _gymAddressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _locationLatController = TextEditingController();
    _locationLongController = TextEditingController();
    _ownerNameController = TextEditingController();
    _ownerMobileController = TextEditingController();

    // Fetch gym data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGymData();
    });
  }

  Future<void> _loadGymData() async {
    await context.read<GymViewModel>().getGymById(widget.gymId);
    final gym = context.read<GymViewModel>().selectedGym;
    
    if (gym != null) {
      setState(() {
        _gymNameController.text = gym.gymName;
        _contactNoController.text = gym.contactNo;
        if (gym.officialEmail != null) {
          _officialEmailController.text = gym.officialEmail!;
        }
        _gymAddressController.text = gym.gymAddress;
        _cityController.text = gym.city;
        _stateController.text = gym.state;
        _locationLatController.text = gym.locationLat ?? '';
        _locationLongController.text = gym.locationLong ?? '';
        // Owner details would need to be added to the GymModel if not already present
        // For now, we'll leave them empty or fetch separately
      });
    }
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    _contactNoController.dispose();
    _officialEmailController.dispose();
    _gymAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _locationLatController.dispose();
    _locationLongController.dispose();
    _ownerNameController.dispose();
    _ownerMobileController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isFetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationLatController.text = position.latitude.toString();
        _locationLongController.text = position.longitude.toString();
        _isFetchingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location fetched successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveGymDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final gymData = {
      'gymId': widget.gymId,
      'gymName': _gymNameController.text.trim(),
      'contactNo': _contactNoController.text.trim(),
      'officialEmail': _officialEmailController.text.trim(),
      'gymAddress': _gymAddressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'locationLat': _locationLatController.text.trim(),
      'locationLong': _locationLongController.text.trim(),
    };


    final success = await context.read<GymViewModel>().updateGym(gymData);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym details updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      final errorMessage = context.read<GymViewModel>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to update gym details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gym Details'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Consumer<GymViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == GymViewState.loading && viewModel.selectedGym == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == GymViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load gym data',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadGymData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gym Information Section (Editable)
                    _buildSectionHeader('Gym Information', Icons.fitness_center, Theme.of(context).primaryColor),
                    _buildCard(
                      children: [
                        _buildTextField(
                          controller: _gymNameController,
                          label: 'Gym Name *',
                          icon: Icons.business,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Gym name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _contactNoController,
                          label: 'Contact Number *',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Contact number is required';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                              return 'Enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _officialEmailController,
                          label: 'Official Email *',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _gymAddressController,
                          label: 'Gym Address *',
                          icon: Icons.location_on,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cityController,
                          label: 'City *',
                          icon: Icons.location_city,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'City is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _stateController,
                          label: 'State *',
                          icon: Icons.map,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'State is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Location Section (Optional)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildSectionHeader('Location Coordinates (Optional)', Icons.gps_fixed, Colors.orange),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                          icon: _isFetchingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.my_location, size: 18),
                          label: Text(_isFetchingLocation ? 'Fetching...' : 'Get Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildCard(
                      children: [
                        _buildTextField(
                          controller: _locationLatController,
                          label: 'Latitude',
                          icon: Icons.my_location,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _locationLongController,
                          label: 'Longitude',
                          icon: Icons.location_searching,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveGymDetails,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }
}

