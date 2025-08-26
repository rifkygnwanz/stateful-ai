import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isLoading;
  final String? imageUrl;
  final Uint8List? localImage;
  final bool animate;

  const ChatBubble(
    this.text, {
    super.key,
    this.isUser = false,
    this.isLoading = false,
    this.imageUrl,
    this.localImage,
    this.animate = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bubble = Padding(
      padding: EdgeInsets.fromLTRB(
        widget.isUser ? 64 : 16,
        8,
        widget.isUser ? 16 : 64,
        4,
      ),
      child: Column(
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  widget.isUser
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.imageUrl != null || widget.localImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          widget.localImage != null
                              ? Image.memory(
                                widget.localImage!,
                                width: 220,
                                fit: BoxFit.cover,
                              )
                              : Image.network(
                                widget.imageUrl!,
                                width: 220,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                widget.isLoading
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sedang mengetik...',
                          style: TextStyle(
                            color:
                                widget.isUser
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                    : widget.isUser
                    ? SelectableText(
                      widget.text,
                      style: TextStyle(color: colorScheme.onPrimary),
                    )
                    : MarkdownBody(
                      data: widget.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                        listBullet: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                        blockSpacing: 12,
                      ),
                      // ignore: deprecated_member_use
                      imageBuilder: (uri, title, alt) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(uri.toString()),
                        );
                      },
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href));
                        }
                      },
                    ),
              ],
            ),
          ),
          if (!widget.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: _handleCopy,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _copied ? Icons.check : Icons.copy,
                    key: ValueKey(_copied),
                    size: 16,
                    // ignore: deprecated_member_use
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return widget.animate
        ? TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: bubble,
        )
        : bubble;
  }
}
