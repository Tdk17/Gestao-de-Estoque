import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart' as mqtt;

class IoTService {
  final mqtt.MqttServerClient _client =
      mqtt.MqttServerClient('broker.hivemq.com', '');

  void initialize() {
    _client.logging(on: true);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;

    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    _client.connectionMessage = connMess;

    _client.connect();
  }

  void _onConnected() {
    print('Connected');
    _client.subscribe('sensor/temperature', mqtt.MqttQos.atLeastOnce);
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
