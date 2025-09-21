import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController(
    text: 'Delhi',
  );
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;

  // Replace with your own OpenWeatherMap API key
  static const String _apiKey = 'fedcb5c0f7aa4497f5cc12b695359a13';

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null;
    });

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          _weatherData = {
            'city': data['name'],
            'country': data['sys']?['country'],
            'temp': data['main']?['temp'],
            'feels_like': data['main']?['feels_like'],
            'humidity': data['main']?['humidity'],
            'description':
                (data['weather'] != null && data['weather'].isNotEmpty)
                ? data['weather'][0]['description']
                : null,
            'wind_speed': data['wind']?['speed'],
          };
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage =
              'Invalid API key. Double-check your OpenWeatherMap key or wait for activation.';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'City not found. Try another city name.';
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch weather. HTTP ${response.statusCode}.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResultCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(
        child: Text(
          'Search for a city to see the weather.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      );
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${_weatherData!['city'] ?? ''}, ${_weatherData!['country'] ?? ''}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat, color: Colors.orangeAccent),
                const SizedBox(width: 6),
                Text(
                  '${_weatherData!['temp']} °C',
                  style: const TextStyle(fontSize: 26),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_weatherData!['feels_like'] != null)
              Center(
                child: Text(
                  'Feels like: ${_weatherData!['feels_like']} °C',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 8),
            if (_weatherData!['description'] != null)
              Center(
                child: Text(
                  '${_weatherData!['description']}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_weatherData!['humidity'] != null)
                  Column(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blueAccent),
                      Text('Humidity: ${_weatherData!['humidity']}%'),
                    ],
                  ),
                if (_weatherData!['wind_speed'] != null)
                  Column(
                    children: [
                      const Icon(Icons.air, color: Colors.greenAccent),
                      Text('Wind: ${_weatherData!['wind_speed']} m/s'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        labelText: 'City name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) => fetchWeather(value.trim()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => fetchWeather(_cityController.text.trim()),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: _buildResultCard())),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => fetchWeather(_cityController.text.trim()),
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
