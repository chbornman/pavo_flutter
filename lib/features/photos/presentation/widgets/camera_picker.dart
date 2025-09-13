import 'package:flutter/material.dart';

/// Camera filter picker widget
/// Allows selection of camera make and model
class CameraPicker extends StatefulWidget {
  final Function(Map<String, String?>) onSelect;
  final Map<String, String?> initialFilter;

  const CameraPicker({
    super.key,
    required this.onSelect,
    required this.initialFilter,
  });

  @override
  State<CameraPicker> createState() => _CameraPickerState();
}

class _CameraPickerState extends State<CameraPicker> {
  late String? selectedMake;
  late String? selectedModel;

  // Mock data - in real app, this would come from API
  final List<String> cameraMakes = [
    'Apple',
    'Samsung',
    'Google',
    'Sony',
    'Canon',
    'Nikon',
    'Fujifilm',
    'Panasonic',
    'Olympus',
    'Leica',
  ];

  final Map<String, List<String>> modelsByMake = {
    'Apple': ['iPhone 15 Pro', 'iPhone 15', 'iPhone 14 Pro', 'iPhone 14', 'iPhone 13', 'iPad Pro'],
    'Samsung': ['Galaxy S24 Ultra', 'Galaxy S24', 'Galaxy S23', 'Galaxy Note 20', 'Galaxy A54'],
    'Google': ['Pixel 8 Pro', 'Pixel 8', 'Pixel 7', 'Pixel 6', 'Pixel 5'],
    'Sony': ['α7R V', 'α7 IV', 'α6000', 'RX100 VII', 'A7S III'],
    'Canon': ['EOS R5', 'EOS R6', 'EOS 5D Mark IV', 'EOS 90D', 'PowerShot G7 X'],
    'Nikon': ['Z9', 'Z7 II', 'D850', 'D750', 'Coolpix P1000'],
    'Fujifilm': ['X-T5', 'X-S20', 'X100V', 'GFX 100S'],
    'Panasonic': ['Lumix S5 II', 'Lumix GH6', 'Lumix G9'],
    'Olympus': ['OM-D E-M1 Mark III', 'PEN-F', 'Tough TG-6'],
    'Leica': ['Q3', 'SL2-S', 'M11'],
  };

  @override
  void initState() {
    super.initState();
    selectedMake = widget.initialFilter['make'];
    selectedModel = widget.initialFilter['model'];
  }

  void _onSelectionChanged() {
    widget.onSelect({
      'make': selectedMake,
      'model': selectedModel,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Camera Make Dropdown
        DropdownButtonFormField<String?>(
          value: selectedMake,
          decoration: const InputDecoration(
            labelText: 'Camera Make',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Any Make'),
            ),
            ...cameraMakes.map((make) => DropdownMenuItem(
              value: make,
              child: Text(make),
            )),
          ],
          onChanged: (value) {
            setState(() {
              selectedMake = value;
              selectedModel = null; // Reset model when make changes
            });
            _onSelectionChanged();
          },
        ),

        const SizedBox(height: 16),

        // Camera Model Dropdown (only show if make is selected)
        if (selectedMake != null && modelsByMake[selectedMake] != null)
          DropdownButtonFormField<String?>(
            value: selectedModel,
            decoration: const InputDecoration(
              labelText: 'Camera Model',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Any Model'),
              ),
              ...modelsByMake[selectedMake]!.map((model) => DropdownMenuItem(
                value: model,
                child: Text(model),
              )),
            ],
            onChanged: (value) {
              setState(() {
                selectedModel = value;
              });
              _onSelectionChanged();
            },
          ),

        // Show popular combinations if no make selected
        if (selectedMake == null) ...[
          const SizedBox(height: 24),
          Text(
            'Popular Combinations',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPopularChip('iPhone 15 Pro', 'Apple'),
              _buildPopularChip('Galaxy S24 Ultra', 'Samsung'),
              _buildPopularChip('Pixel 8 Pro', 'Google'),
              _buildPopularChip('EOS R5', 'Canon'),
              _buildPopularChip('α7R V', 'Sony'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPopularChip(String model, String make) {
    return FilterChip(
      label: Text('$make $model'),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedMake = make;
            selectedModel = model;
          });
          _onSelectionChanged();
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}