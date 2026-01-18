import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"text": text, "isAi": false});
      });
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Seekr AI', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatSuccess) {
            setState(() {
              _messages.add({
                "text": state.reply,
                "isAi": true,
                "sources": state.sources,
              });
            });
            _scrollToBottom();
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildChatBubble(
                      message: msg['text'],
                      isAi: msg['isAi'],
                      sources: msg['sources'],
                    );
                  },
                ),
              ),
              if (state is ChatLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(color: Color(0xFF8B19E6)),
                ),
              _buildInputSection(state is ChatLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputSection(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2D1B4D).withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isLoading ? 'AI is thinking...' : 'Summon knowledge...',
                hintStyle: const TextStyle(color: Colors.white38),
                fillColor: const Color(0xFF1A0B2E),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: isLoading ? null : _handleSend,
            icon: const CircleAvatar(
              backgroundColor: Color(0xFF8B19E6),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String message, required bool isAi, List<dynamic>? sources}) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAi ? const Color(0xFF8B19E6) : const Color(0xFF2D1B4D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: Colors.white)),
            if (sources != null && sources.isNotEmpty) ...[
              const Divider(color: Colors.white24),
              const Text("Sources from the Void:", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              ...sources.map((s) => TextButton(
                onPressed: () => launchUrl(Uri.parse(s['link'])),
                child: Text(s['title'], style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, decoration: TextDecoration.underline)),
              )),
            ]
          ],
        ),
      ),
    );
  }
}