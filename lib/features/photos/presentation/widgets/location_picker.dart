import 'package:flutter/material.dart';

/// Location filter picker widget
/// Allows selection of country, state, and city
class LocationPicker extends StatefulWidget {
  final Function(Map<String, String?>) onSelected;
  final Map<String, String?> initialFilter;

  const LocationPicker({
    super.key,
    required this.onSelected,
    required this.initialFilter,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late String? selectedCountry;
  late String? selectedState;
  late String? selectedCity;

  // Mock data - in real app, this would come from API
  final List<String> countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Japan',
    'Australia',
  ];

  final Map<String, List<String>> statesByCountry = {
    'United States': ['California', 'New York', 'Texas', 'Florida', 'Illinois'],
    'Canada': ['Ontario', 'British Columbia', 'Quebec', 'Alberta'],
    'United Kingdom': ['England', 'Scotland', 'Wales'],
    'Germany': ['Bavaria', 'North Rhine-Westphalia', 'Baden-Württemberg'],
    'France': ['Île-de-France', 'Provence-Alpes-Côte d\'Azur'],
    'Japan': ['Tokyo', 'Osaka', 'Kyoto'],
    'Australia': ['New South Wales', 'Victoria', 'Queensland'],
  };

  final Map<String, List<String>> citiesByState = {
    'California': ['Los Angeles', 'San Francisco', 'San Diego', 'Sacramento'],
    'New York': ['New York City', 'Buffalo', 'Albany'],
    'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio'],
    'Florida': ['Miami', 'Orlando', 'Tampa'],
    'Ontario': ['Toronto', 'Ottawa', 'Hamilton'],
    'British Columbia': ['Vancouver', 'Victoria'],
    'England': ['London', 'Manchester', 'Birmingham'],
    'Scotland': ['Edinburgh', 'Glasgow'],
    'Bavaria': ['Munich', 'Nuremberg'],
    'Tokyo': ['Tokyo'],
    'Osaka': ['Osaka'],
    'New South Wales': ['Sydney', 'Newcastle'],
    'Victoria': ['Melbourne'],
  };

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialFilter['country'];
    selectedState = widget.initialFilter['state'];
    selectedCity = widget.initialFilter['city'];
  }

  void _onSelectionChanged() {
    widget.onSelected({
      'country': selectedCountry,
      'state': selectedState,
      'city': selectedCity,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        DropdownButtonFormField<String?>(
          value: selectedCountry,
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Any Country'),
            ),
            ...countries.map((country) => DropdownMenuItem(
              value: country,
              child: Text(country),
            )),
          ],
          onChanged: (value) {
            setState(() {
              selectedCountry = value;
              selectedState = null; // Reset state when country changes
              selectedCity = null; // Reset city when country changes
            });
            _onSelectionChanged();
          },
        ),

        const SizedBox(height: 16),

        // State Dropdown (only show if country is selected)
        if (selectedCountry != null && statesByCountry[selectedCountry] != null)
          DropdownButtonFormField<String?>(
            value: selectedState,
            decoration: const InputDecoration(
              labelText: 'State/Province',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Any State/Province'),
              ),
              ...statesByCountry[selectedCountry]!.map((state) => DropdownMenuItem(
                value: state,
                child: Text(state),
              )),
            ],
            onChanged: (value) {
              setState(() {
                selectedState = value;
                selectedCity = null; // Reset city when state changes
              });
              _onSelectionChanged();
            },
          ),

        const SizedBox(height: 16),

        // City Dropdown (only show if state is selected)
        if (selectedState != null && citiesByState[selectedState] != null)
          DropdownButtonFormField<String?>(
            value: selectedCity,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Any City'),
              ),
              ...citiesByState[selectedState]!.map((city) => DropdownMenuItem(
                value: city,
                child: Text(city),
              )),
            ],
            onChanged: (value) {
              setState(() {
                selectedCity = value;
              });
              _onSelectionChanged();
            },
          ),
      ],
    );
  }
}