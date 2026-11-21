import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Services/socket_service.dart';
import 'chat_models.dart';

/// Each signed-in user's private AI assistant. The conversation is stored per user
/// in Firestore (users/{uid}/aiMessages) by the server and syncs live across devices.
class AiAssistantScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AiAssistantScreen({super.key, this.onBack});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _socket = SocketService.instance;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<AiMessage> _messages = [];
  final Set<String> _ids = {};
  final List<StreamSubscription> _subs = [];

  bool _loading = true;
  bool _thinking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _subs.add(_socket.aiMessages.listen(_add));
    _subs.add(_socket.aiTyping.listen((t) => setState(() => _thinking = t)));
    _subs.add(_socket.aiCleared.listen((_) => setState(() {
          _messages.clear();
          _ids.clear();
        })));
    _subs.add(_socket.aiErrors.listen((e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI error: $e')));
    }));
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final history = await _socket.aiHistory();
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        _ids
          ..clear()
          ..addAll(history.map((m) => m.id));
      });
      _scrollToBottom();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _add(AiMessage m) {
    if (!mounted || _ids.contains(m.id)) return;
    setState(() {
      _ids.add(m.id);
      _messages.add(m);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _thinking) return;
    _controller.clear();
    setState(() => _thinking = true);
    try {
      _add(await _socket.askAi(text));
    } catch (e) {
      if (mounted) {
        _controller.text = text;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text('This deletes your AI chat history on all your devices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _socket.clearAi();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: const Color(0xFF120136),
        leading: widget.onBack == null ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        actions: [
          IconButton(tooltip: 'Clear conversation', icon: const Icon(Icons.delete_sweep), onPressed: _clear),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16043F), Color(0xFF0C0101)],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildList()),
            if (_thinking)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Assistant is thinking…', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                ]),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about your coursework…',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.black38,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _thinking ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ]),
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Your personal AI assistant.\nAsk a question to get started.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[_messages.length - 1 - i];
        return Align(
          alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: m.content));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: m.isUser ? Colors.deepPurple[700] : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!m.isUser) ...[
                      const Icon(Icons.smart_toy, size: 18, color: Colors.tealAccent),
                      const SizedBox(width: 8),
                    ],
                    Flexible(child: SelectableText(m.content, style: const TextStyle(color: Colors.white, fontSize: 15))),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
