import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// The initial state when the user enters the chat.
class ChatInitial extends ChatState {}

/// State emitted while the FastAPI server is processing the "summoning".
class ChatLoading extends ChatState {}

/// State emitted when the AI successfully returns a response.
class ChatSuccess extends ChatState {
  final String reply;

  // This list holds the search citations (title, link, snippet) from Task 5
  final List<dynamic> sources;

  const ChatSuccess({required this.reply, required this.sources});

  @override
  List<Object?> get props => [reply, sources];
}

/// State emitted if the server returns an error or the connection fails.
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
