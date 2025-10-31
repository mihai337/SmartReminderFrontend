import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/auth_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:smartreminders/services/location_service.dart';
import 'package:smartreminders/services/wifi_service.dart';
import 'package:smartreminders/widgets/category_chip.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

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

    final now = DateTime.now();
    final task = Task(
      id: FirebaseFirestore.instance.collection('tasks').doc().id,
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      triggerType: _selectedTriggerType,
      triggerConfig: triggerConfig,
      stateChange: _selectedStateChange,
      createdAt: now,
      updatedAt: now,
    );

    await _taskService.createTask(task);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'What do you need to remember?',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            Text('Trigger Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildTriggerTypeSelector(),
            const SizedBox(height: 24),
            _buildTriggerConfiguration(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      children: [TaskCategory.home, TaskCategory.work, TaskCategory.school].map((category) {
        return CategoryChip(
          category: category,
          isSelected: _selectedCategory == category,
          onSelected: () => setState(() => _selectedCategory = category),
        );
      }).toList(),
    );
  }

  Widget _buildTriggerTypeSelector() {
    return Column(
      children: TriggerType.values.map((type) {
        return RadioListTile<TriggerType>(
          title: Row(
            children: [
              Icon(_getTriggerTypeIcon(type), color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(_getTriggerTypeLabel(type)),
            ],
          ),
          value: type,
          groupValue: _selectedTriggerType,
          onChanged: (value) => setState(() {
            _selectedTriggerType = value!;
            _selectedStateChange = null;
          }),
        );
      }).toList(),
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
        Text('State Change', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<StateChange>(
          segments: const [
            ButtonSegment(value: StateChange.enter, label: Text('Enter'), icon: Icon(Icons.login)),
            ButtonSegment(value: StateChange.exit, label: Text('Exit'), icon: Icon(Icons.logout)),
          ],
          selected: _selectedStateChange != null ? {_selectedStateChange!} : {},
          onSelectionChanged: (set) => setState(() => _selectedStateChange = set.first),
        ),
        const SizedBox(height: 24),
        Text('Select Location', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        StreamBuilder<List<SavedLocation>>(
          stream: _locationService.getSavedLocations(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No saved locations. Add one from the menu.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((location) {
                final isSelected = _selectedLocation?.id == location.id;
                return Card(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                  child: ListTile(
                    leading: Icon(Icons.place, color: Theme.of(context).colorScheme.primary),
                    title: Text(location.name),
                    subtitle: Text('${location.radiusMeters.toInt()}m radius'),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
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
        Text('Select Date & Time', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
            title: Text(_selectedDateTime != null
                ? _selectedDateTime!.toString().split('.')[0]
                : 'Choose date and time'),
            trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
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
          ),
        ),
      ],
    );
  }

  Widget _buildWiFiConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('State Change', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<StateChange>(
          segments: const [
            ButtonSegment(value: StateChange.connect, label: Text('Connect'), icon: Icon(Icons.wifi)),
            ButtonSegment(value: StateChange.disconnect, label: Text('Disconnect'), icon: Icon(Icons.wifi_off)),
          ],
          selected: _selectedStateChange != null ? {_selectedStateChange!} : {},
          onSelectionChanged: (set) => setState(() => _selectedStateChange = set.first),
        ),
        const SizedBox(height: 24),
        Text('Select WiFi Network', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: _wifiService.getKnownNetworks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Connect to a WiFi network first',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((ssid) {
                final isSelected = _selectedWiFiSSID == ssid;
                return Card(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                  child: ListTile(
                    leading: Icon(Icons.wifi, color: Theme.of(context).colorScheme.primary),
                    title: Text(ssid),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
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

  IconData _getTriggerTypeIcon(TriggerType type) {
    switch (type) {
      case TriggerType.location:
        return Icons.location_on;
      case TriggerType.time:
        return Icons.access_time;
      case TriggerType.wifi:
        return Icons.wifi;
    }
  }

  String _getTriggerTypeLabel(TriggerType type) {
    switch (type) {
      case TriggerType.location:
        return 'Location-based';
      case TriggerType.time:
        return 'Time-based';
      case TriggerType.wifi:
        return 'WiFi-based';
    }
  }
}
