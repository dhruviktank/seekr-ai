import 'package:bloc/bloc.dart';
import 'package:seekr_ai/features/chat/data/api_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiService _apiService = ApiService();

  ChatCubit() : super(ChatInitial());

  void sendMessage(String message) async {
    emit(ChatLoading()); // Show a "summoning" indicator in UI
    try {
      final result = await _apiService.summonAI(message);
      // 'result' includes the AI reply and search citations from Task 5
      emit(ChatSuccess(
        reply: result['reply'], 
        sources: result['sources']
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}