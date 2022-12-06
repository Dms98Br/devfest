import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(
      title: "App Clima",
      debugShowCheckedModeBanner: false,
      home: Home(),
    ));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var temp;
  var descricao;
  var agora;
  var umidade;
  var velocidadedovento;
  String? apiKey = 'b2aac28faf159bdb767a6f2207460af7';
  String? openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

  Future getWeather(String lat, String log) async {
    var url = Uri.parse(
        '$openWeatherMapURL?lat=-22.223351&lon=-49.908340&lang=pt_br&appid=$apiKey&units=metric');
    http.Response response = await http.get(url);
    var resultado = jsonDecode(response.body);

    setState(() {
      temp = resultado['main']['temp'];
      descricao = resultado['weather'][0]['description'];
      agora = resultado['weather'][0]['main'];
      umidade = resultado['main']['humidity'];
      velocidadedovento = resultado['wind']['speed'];
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final location = await Geolocator.getCurrentPosition();
    getWeather(location.latitude.toString(), location.longitude.toString());
    return location;
  }

  @override
  void initState() {
    super.initState();
    try {
      _determinePosition();
    } catch (e) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton:
      //     Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      //   FloatingActionButton(
      //     child: Icon(Icons.my_location),
      //     onPressed: () => _determinePosition(),
      //     heroTag: null,
      //   )
      // ]),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Em Marília",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  temp != null ? "$temp\u00b0" : "Loading",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    descricao != null ? descricao.toString() : "Loading",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.temperatureHalf),
                  title: const Text('Temperatura'),
                  trailing: Text(temp != null ? "$temp\u00b0" : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.cloud),
                  title: const Text('Clima'),
                  trailing: Text(
                    descricao != null ? descricao.toString() : "Loading",
                  ),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.sun),
                  title: const Text('Umidade'),
                  trailing:
                      Text(umidade != null ? umidade.toString() : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.wind),
                  title: const Text('Velocidade do vento'),
                  trailing: Text(velocidadedovento != null
                      ? velocidadedovento.toString()
                      : "Loading"),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }
}
