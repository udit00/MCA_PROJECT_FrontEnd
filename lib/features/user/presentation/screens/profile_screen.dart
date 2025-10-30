import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zymm/common/enums/user_role.dart';
import 'package:zymm/features/auth/presentation/login_screen.dart';
import 'package:zymm/features/user/presentation/screens/change_password_screen.dart';
import 'package:zymm/features/user/presentation/viewmodel/profile_viewmodel.dart';
import 'package:zymm/utils/image_picker_helper.dart';
import 'package:zymm/utils/image_url_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchUserData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.state == ViewState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.state == ViewState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchUserData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final userData = viewModel.userData;
            if (userData == null) {
              return const Center(child: Text('No user data available'));
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.fetchUserData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header with Background Image
                    Stack(
                      children: [
                        // Background Image or Gradient
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: userData.profilePic == null
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).primaryColor.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                          ),
                          child: userData.profilePic != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      ImageUrlHelper.getFullImageUrl(userData.profilePic),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Theme.of(context).primaryColor,
                                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),
                                    // Dark overlay for better text readability
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        
                        // Content overlay
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              // User Name
                              Text(
                                userData.userName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  UserRole.fromId(userData.roleId).displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        
                        // Edit button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: InkWell(
                            onTap: () async {
                              final imageFile = await ImagePickerHelper.showImageSourceDialogFile(context);
                              if (imageFile != null && mounted) {
                                viewModel.uploadProfilePicture(imageFile);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // User Information Cards
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          // Mobile Number
                          _buildInfoCard(
                            icon: Icons.phone_android,
                            title: 'Mobile',
                            value: userData.mobile,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 12),

                          // Email
                          _buildInfoCard(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: userData.email ?? 'Not provided',
                            iconColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),

                          // Gender
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            title: 'Gender',
                            value: userData.genderDisplay,
                            iconColor: Colors.purple,
                          ),
                          const SizedBox(height: 12),

                          // User ID
                          _buildInfoCard(
                            icon: Icons.fingerprint,
                            title: 'User ID',
                            value: '#${userData.userId}',
                            iconColor: Colors.orange,
                          ),

                          const SizedBox(height: 24),

                          // Danger Actions Section
                          Text(
                            'Danger Actions',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                          ),
                          const SizedBox(height: 12),

                          // Delete Account Button (Danger)
                          _buildActionButton(
                            icon: Icons.delete_forever,
                            title: 'Delete Account',
                            subtitle: 'Deactivate your account',
                            iconColor: Colors.red,
                            isDanger: true,
                            onTap: () => _showDeleteAccountDialog(context, viewModel),
                          ),

                          const SizedBox(height: 24),

                          // Account Actions Section
                          Text(
                            'Account Actions',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),

                          // Change Password Button
                          _buildActionButton(
                            icon: Icons.lock_reset,
                            title: 'Change Password',
                            subtitle: 'Update your account password',
                            iconColor: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Logout Button
                          _buildActionButton(
                            icon: Icons.logout,
                            title: 'Logout',
                            subtitle: 'Sign out from your account',
                            iconColor: Colors.orange,
                            onTap: () => _showLogoutDialog(context, viewModel),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDanger ? Colors.red[200]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withOpacity(0.1)
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.red : iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? Colors.red[700] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDanger ? Colors.red[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDanger ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await viewModel.logout();
              if (context.mounted) {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, ProfileViewModel viewModel) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete Account'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to deactivate your account?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'This will:',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                _buildDeleteWarningPoint('Mark your account as inactive'),
                _buildDeleteWarningPoint('Cancel all active memberships'),
                _buildDeleteWarningPoint('Disable access to your account'),
                const SizedBox(height: 16),
                const Text(
                  'Enter your password to confirm:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                if (viewModel.state == ViewState.error &&
                    viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: viewModel.state == ViewState.loading
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: viewModel.state == ViewState.loading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        await viewModel.deleteAccount(
                          passwordController.text.trim(),
                        );
                        if (viewModel.state == ViewState.success) {
                          if (context.mounted) {
                            Navigator.of(dialogContext).pop(); // Close dialog
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (route) => false,
                            ); // Navigate to login
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: viewModel.state == ViewState.loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

