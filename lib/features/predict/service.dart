import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import 'models.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final predictServiceProvider = Provider<PredictService>((ref) {
  return PredictService(ref.read(apiClientProvider));
});

class PredictService {
  final ApiClient _api;
  PredictService(this._api);

  Future<Map<String, dynamic>> schema() => _api.getJson('/v1/schema');

  Future<PredictResponse> predict(PredictRequest req) async {
    final data = await _api.postJson('/v1/predict', req.toJson());
    return PredictResponse.fromJson(data);
  }
}
