import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final dogImageProvider =
    FutureProvider.autoDispose.family<String, String>((ref, _) async {
  final response =
      await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['message'];
  } else {
    throw Exception('Error al cargar la imagen del perro');
  }
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Random perros')),
        body: Center(child: DogImage()),
      ),
    );
  }
}

class DogImage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogImageAsyncValue = ref.watch(dogImageProvider('random'));

    return dogImageAsyncValue.when(
      data: (url) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(url),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(dogImageProvider('random')),
            child: Text('Cargar otra imagen'),
          ),
        ],
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
