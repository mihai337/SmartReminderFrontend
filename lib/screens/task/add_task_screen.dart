import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/services/location_service.dart';
import 'package:smartreminders/services/wifi_service.dart';

class AddTaskScreen extends StatefulWidget {
  /// When [isModal] is true the widget renders without a Scaffold so it can be
  /// embedded inside a bottom sheet or dialog without being clipped.
  const AddTaskScreen({super.key, this.isModal = false, this.scrollController});

  final bool isModal;
  final ScrollController? scrollController;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final LocationService _locationService = LocationService();
  final WiFiService _wifiService = WiFiService();

  TaskCategory _selectedCategory = TaskCategory.home;
  TriggerType _selectedTriggerType = TriggerType.time;
  StateChange? _selectedStateChange;
  SavedLocation? _selectedLocation;
  String? _selectedWiFiSSID;
  DateTime? _selectedDateTime;

  // UI constants for a richer, smoother look
  final Duration _animDuration = const Duration(milliseconds: 300);
  final Curve _animCurve = Curves.easeInOut;
  final Color _primaryColor = const Color(0xFF4F46E5); // rich indigo
  final Color _mutedBg = const Color(0xFFF7F9FF);

  // helper to avoid using deprecated withOpacity in some SDK versions
  Color _withOpacity(Color color, double opacity) => color.withAlpha((opacity * 255).round());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    Map<String, dynamic> triggerConfig = {};

    if (_selectedTriggerType == TriggerType.location) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')),
        );
        return;
      }
      triggerConfig = {
        'locationId': _selectedLocation!.id,
        'locationName': _selectedLocation!.name,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'radius': _selectedLocation!.radiusMeters,
      };
    } else if (_selectedTriggerType == TriggerType.time) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }
      triggerConfig = {'dateTime': _selectedDateTime!.toIso8601String()};
    } else if (_selectedTriggerType == TriggerType.wifi) {
      if (_selectedWiFiSSID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a WiFi network')),
        );
        return;
      }
      triggerConfig = {'ssid': _selectedWiFiSSID!};
    }

    final task = Task(
      id: FirebaseFirestore.instance.collection('tasks').doc().id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      triggerType: _selectedTriggerType,
      triggerConfig: triggerConfig,
      stateChange: _selectedStateChange,
    );

    await _taskService.createTask(task);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        controller: widget.isModal ? widget.scrollController : null,
        padding: const EdgeInsets.all(24),
        shrinkWrap: widget.isModal ? false : true,
        physics: widget.isModal ? const ClampingScrollPhysics() : const AlwaysScrollableScrollPhysics(),
        children: [
          const Text(
            'Title',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'What do you need to remember?',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: _mutedBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 24),
          const Text(
            'Description (optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Add any details...',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: _mutedBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          _buildCategorySelector(),
          const SizedBox(height: 24),
          const Text(
            'Remind me when',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 12),
          _buildTriggerTypeSelector(),
          const SizedBox(height: 24),
          _buildTriggerConfiguration(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: _withOpacity(_primaryColor, 0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text('Add Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isModal) {
      // Render a compact modal layout without a Scaffold so the parent
      // bottom sheet controls sizing and scrolling. Respect viewInsets so
      // the keyboard won't clip inputs.
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('New Reminder', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildFormContent()),
            ],
          ),
        ),
      );
    }

    // Default full-screen route uses Scaffold
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Reminder'),
        centerTitle: true,
      ),
      body: _buildFormContent(),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: [
        _buildCategoryButton(Icons.home, 'Home', TaskCategory.home),
        const SizedBox(width: 12),
        _buildCategoryButton(Icons.work, 'Work', TaskCategory.work),
        const SizedBox(width: 12),
        _buildCategoryButton(Icons.school, 'School', TaskCategory.school),
      ],
    );
  }

  Widget _buildCategoryButton(IconData icon, String label, TaskCategory category) {
    final isSelected = _selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _withOpacity(_primaryColor, 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryColor : const Color(0xFFE8E8E8),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: _withOpacity(_primaryColor, 0.08), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _primaryColor : const Color(0xFF666666)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _primaryColor : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTriggerTypeSelector() {
    return Row(
      children: [
        _buildTriggerButton(Icons.access_time, 'Time', TriggerType.time),
        const SizedBox(width: 12),
        _buildTriggerButton(Icons.location_on, 'Location', TriggerType.location),
        const SizedBox(width: 12),
        _buildTriggerButton(Icons.wifi, 'WiFi', TriggerType.wifi),
        const SizedBox(width: 12),
        _buildDisabledTriggerButton(Icons.person, 'Friend'),
      ],
    );
  }

  Widget _buildTriggerButton(IconData icon, String label, TriggerType type) {
    final isSelected = _selectedTriggerType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTriggerType = type;
          _selectedStateChange = null;
        }),
        child: AnimatedContainer(
          duration: _animDuration,
          curve: _animCurve,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _withOpacity(_primaryColor, 0.10) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryColor : const Color(0xFFE8E8E8),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: _withOpacity(_primaryColor, 0.06), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _primaryColor : const Color(0xFF666666)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _primaryColor : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledTriggerButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFCCCCCC)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFCCCCCC)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerConfiguration() {
    switch (_selectedTriggerType) {
      case TriggerType.location:
        return _buildLocationConfig();
      case TriggerType.time:
        return _buildTimeConfig();
      case TriggerType.wifi:
        return _buildWiFiConfig();
    }
  }

  Widget _buildLocationConfig() {
    final userId = _authService.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State Change',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        SegmentedButton<StateChange>(
          segments: const [
            ButtonSegment(value: StateChange.enter, label: Text('Enter'), icon: Icon(Icons.login)),
            ButtonSegment(value: StateChange.exit, label: Text('Exit'), icon: Icon(Icons.logout)),
          ],
          selected: _selectedStateChange != null ? <StateChange>{_selectedStateChange!} : <StateChange>{},
          emptySelectionAllowed: true,
          onSelectionChanged: (set) => setState(() => _selectedStateChange = set.isNotEmpty ? set.first : null),
          showSelectedIcon: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<SavedLocation>>(
          stream: _locationService.getSavedLocations(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No saved locations. Add one from the menu.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((location) {
                final isSelected = _selectedLocation?.id == location.id;
                return AnimatedContainer(
                  duration: _animDuration,
                  curve: _animCurve,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _withOpacity(_primaryColor, 0.08) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.place, color: isSelected ? _primaryColor : const Color(0xFF666666)),
                    title: Text(location.name),
                    subtitle: Text('${location.radiusMeters.toInt()}m radius'),
                    trailing: isSelected ? Icon(Icons.check_circle, color: _primaryColor) : null,
                    onTap: () => setState(() => _selectedLocation = location),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF666666)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateTime != null
                        ? '${_selectedDateTime!.toString().split('.')[0]}'
                        : 'e.g., 9:00 AM, 3:30 PM',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedDateTime != null ? const Color(0xFF1A1A1A) : const Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWiFiConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State Change',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        SegmentedButton<StateChange>(
          segments: const [
            ButtonSegment(value: StateChange.connect, label: Text('Connect'), icon: Icon(Icons.wifi)),
            ButtonSegment(value: StateChange.disconnect, label: Text('Disconnect'), icon: Icon(Icons.wifi_off)),
          ],
          selected: _selectedStateChange != null ? <StateChange>{_selectedStateChange!} : <StateChange>{},
          emptySelectionAllowed: true,
          onSelectionChanged: (set) => setState(() => _selectedStateChange = set.isNotEmpty ? set.first : null),
          showSelectedIcon: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Select WiFi Network',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: _wifiService.getKnownNetworks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Connect to a WiFi network first',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((ssid) {
                final isSelected = _selectedWiFiSSID == ssid;
                return AnimatedContainer(
                  duration: _animDuration,
                  curve: _animCurve,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _withOpacity(_primaryColor, 0.08) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.wifi, color: isSelected ? _primaryColor : const Color(0xFF666666)),
                    title: Text(ssid),
                    trailing: isSelected ? Icon(Icons.check_circle, color: _primaryColor) : null,
                    onTap: () => setState(() => _selectedWiFiSSID = ssid),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
