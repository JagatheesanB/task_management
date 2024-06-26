// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// import '../../domain/models/chat.dart';
// import '../providers/auth_provider.dart';
// import '../providers/chat_provider.dart';

// class ChatScreen extends ConsumerStatefulWidget {
//   final int userId;
//   final String userName;
//   final int receiverId;

//   const ChatScreen({
//     Key? key,
//     required this.userId,
//     required this.userName,
//     required this.receiverId,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends ConsumerState<ChatScreen> {
//   late TextEditingController _controller;
//   late ChatNotifier _chatNotifier;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//     _chatNotifier = ref.read(chatProvider.notifier);
//     _chatNotifier.getChatMessagesForUser(widget.userId, widget.receiverId);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final userId = ref.read(currentUserProvider) as int;
//     final messageContent = _controller.text;
//     if (messageContent.isNotEmpty) {
//       _chatNotifier.addChatMessage(
//         messageContent,
//         userId,
//         widget.receiverId,
//       );
//       _controller.clear();
//     }
//   }

// void _showUpdateDialog(ChatMessage message) {
//   final TextEditingController updateController =
//       TextEditingController(text: message.message);

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.edit, color: Colors.blue),
//             SizedBox(width: 8),
//             Text('Update Message'),
//           ],
//         ),
//         content: TextField(
//           controller: updateController,
//           decoration: InputDecoration(
//             hintText: 'Type new message',
//             hintStyle: TextStyle(color: Colors.grey[600]),
//             enabledBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: Colors.black, width: 1.0),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: Colors.black, width: 2.0),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//           ),
//         ),
//         actions: [
//           Row(
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(Icons.cancel, color: Colors.red),
//                     SizedBox(width: 4),
//                     Text('Cancel'),
//                   ],
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   if (updateController.text.isNotEmpty) {
//                     _chatNotifier.updateChatMessage(
//                         message.id, updateController.text);
//                   }
//                   Navigator.of(context).pop();
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(Icons.check, color: Colors.green),
//                     SizedBox(width: 4),
//                     Text('Update'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

// void _showDeleteDialog(ChatMessage message) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.delete, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Delete Message'),
//           ],
//         ),
//         content: const Text(
//           'Are you sure you want to delete this message?',
//           style: TextStyle(color: Colors.black87),
//         ),
//         actions: [
//           Row(
//             children: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(Icons.cancel, color: Colors.grey),
//                     SizedBox(width: 4),
//                     Text('Cancel'),
//                   ],
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   _chatNotifier.deleteChatMessage(message.id);
//                   Navigator.of(context).pop();
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(Icons.check, color: Colors.red),
//                     SizedBox(width: 4),
//                     Text('Delete'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }

//   // @override
//   // Widget build(BuildContext context) {
//   //   String userName = widget.userName.split('@').first.toUpperCase();
//   //   userName = userName.replaceAll(RegExp(r'[0-9]'), '');
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: Text(
//   //         userName,
//   //         style: const TextStyle(
//   //             fontFamily: 'poppins', fontSize: 18, fontWeight: FontWeight.bold),
//   //       ).animate().fade(duration: 1000.ms).scale(),
//   //     ),
//   //     body: Column(
//   //       children: <Widget>[
//   //         Expanded(
//   //           child: Consumer(
//   //             builder: (context, ref, child) {
//   //               final chatNotifier = ref.watch(chatProvider);
//   //               return ListView.builder(
//   //                 itemCount: chatNotifier.length,
//   //                 itemBuilder: (context, index) {
//   //                   final message = chatNotifier[index];
//   //                   final isSentMessage = message.userId == widget.userId;
//   //                   final isReceivedMessage =
//   //                       message.receiverId == widget.userId;
//   //                   if (isSentMessage || isReceivedMessage) {
//   //                     return Stack(
//   //                       children: [
//   //                         Align(
//   //                           alignment: isSentMessage
//   //                               ? Alignment.centerRight
//   //                               : Alignment.centerLeft,
//   //                           child: Container(
//   //                             width: 180,
//   //                             height: 60,
//   //                             margin: const EdgeInsets.symmetric(
//   //                                 vertical: 12, horizontal: 15),
//   //                             padding: const EdgeInsets.all(8),
//   //                             decoration: BoxDecoration(
//   //                               color: isSentMessage
//   //                                   ? Colors.purple.shade200
//   //                                   : Colors.grey[300],
//   //                               borderRadius: BorderRadius.circular(8),
//   //                             ),
//   //                             child: Column(
//   //                               crossAxisAlignment: isSentMessage
//   //                                   ? CrossAxisAlignment.end
//   //                                   : CrossAxisAlignment.start,
//   //                               children: [
//   //                                 Text(
//   //                                   message.message,
//   //                                   style: TextStyle(
//   //                                     color: isSentMessage
//   //                                         ? Colors.white
//   //                                         : Colors.black87,
//   //                                     fontWeight: isSentMessage
//   //                                         ? FontWeight.bold
//   //                                         : FontWeight.normal,
//   //                                   ),
//   //                                 ),
//   //                                 const SizedBox(height: 4),
//   //                                 Text(
//   //                                   DateFormat('dd MMM yyyy hh:mm a')
//   //                                       .format(message.timestamp),
//   //                                   style: const TextStyle(
//   //                                       fontSize: 14, color: Colors.black),
//   //                                 ),
//   //                               ],
//   //                             ),
//   //                           ),
//   //                         ),
//   //                         Positioned(
//   //                           top: -22,
//   //                           right: isSentMessage ? 9 : null,
//   //                           left: isReceivedMessage ? 9 : null,
//   //                           child: PopupMenuButton<String>(
//   //                             color: Colors.grey[850],
//   //                             icon: const Icon(
//   //                               Icons.more_horiz,
//   //                               color: Colors.black,
//   //                               size: 37,
//   //                             ),
//   //                             onSelected: (String value) {
//   //                               if (value == 'Update') {
//   //                                 _showUpdateDialog(message);
//   //                               } else if (value == 'Delete') {
//   //                                 _showDeleteDialog(message);
//   //                               }
//   //                             },
//   //                             itemBuilder: (BuildContext context) {
//   //                               return [
//   //                                 const PopupMenuItem<String>(
//   //                                   value: 'Update',
//   //                                   child: Row(
//   //                                     children: [
//   //                                       Icon(Icons.edit, color: Colors.blue),
//   //                                       SizedBox(width: 8),
//   //                                       Text(
//   //                                         'Update',
//   //                                         style: TextStyle(
//   //                                             fontFamily: 'poppins',
//   //                                             fontSize: 15,
//   //                                             color: Colors.white),
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                                 const PopupMenuItem<String>(
//   //                                   value: 'Delete',
//   //                                   child: Row(
//   //                                     children: [
//   //                                       Icon(Icons.delete, color: Colors.red),
//   //                                       SizedBox(width: 8),
//   //                                       Text(
//   //                                         'Delete',
//   //                                         style: TextStyle(
//   //                                             fontFamily: 'poppins',
//   //                                             fontSize: 15,
//   //                                             color: Colors.white),
//   //                                       ),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               ];
//   //                             },
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     );
//   //                   } else {
//   //                     return const SizedBox.shrink();
//   //                   }
//   //                 },
//   //               );
//   //             },
//   //           ),
//   //         ),
//   //         Padding(
//   //           padding: const EdgeInsets.all(8.0),
//   //           child: Row(
//   //             children: <Widget>[
//   //               Expanded(
//   //                 child: Focus(
//   //                   onFocusChange: (hasFocus) {
//   //                     setState(() {
//   //                       _isFocused = hasFocus;
//   //                     });
//   //                   },
//   //                   child: AnimatedContainer(
//   //                     duration: const Duration(milliseconds: 300),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.white,
//   //                       borderRadius: BorderRadius.circular(30.0),
//   //                       boxShadow: _isFocused
//   //                           ? [
//   //                               BoxShadow(
//   //                                 color: Colors.purple.withOpacity(0.5),
//   //                                 spreadRadius: 3,
//   //                                 blurRadius: 10,
//   //                               ),
//   //                             ]
//   //                           : [],
//   //                       border: Border.all(
//   //                         color: _isFocused
//   //                             ? Colors.purple.shade400
//   //                             : Colors.grey.shade300,
//   //                         width: 2.0,
//   //                       ),
//   //                     ),
//   //                     child: TextField(
//   //                       controller: _controller,
//   //                       decoration: const InputDecoration(
//   //                         hintText: 'Type a message...',
//   //                         contentPadding: EdgeInsets.symmetric(
//   //                           vertical: 10.0,
//   //                           horizontal: 20.0,
//   //                         ),
//   //                         border: InputBorder.none,
//   //                         hintStyle: TextStyle(
//   //                           color: Colors.black,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //               const SizedBox(width: 8.0),
//   //               Container(
//   //                 decoration: const BoxDecoration(
//   //                   color: Colors.purple,
//   //                   shape: BoxShape.circle,
//   //                 ),
//   //                 child: IconButton(
//   //                   icon: const Icon(Icons.send),
//   //                   color: Colors.white,
//   //                   onPressed: _sendMessage,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     String userName = widget.userName.split('@').first.toUpperCase();
//     userName = userName.replaceAll(RegExp(r'[0-9]'), '');
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           userName,
//           style: const TextStyle(
//             fontFamily: 'poppins',
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ).animate().fade(duration: 1000.ms).scale(),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Consumer(
//               builder: (context, ref, child) {
//                 final chatNotifier = ref.watch(chatProvider);
//                 return ListView.builder(
//                   itemCount: chatNotifier.length,
//                   itemBuilder: (context, index) {
//                     final message = chatNotifier[index];
//                     final isSentMessage = message.userId == widget.userId;
//                     final isReceivedMessage =
//                         message.receiverId == widget.userId;

//                     if (isSentMessage || isReceivedMessage) {
//                       return _buildMessageWidget(message, isSentMessage);
//                     } else {
//                       return const SizedBox.shrink();
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Focus(
//                     onFocusChange: (hasFocus) {
//                       setState(() {
//                         _isFocused = hasFocus;
//                       });
//                     },
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30.0),
//                         boxShadow: _isFocused
//                             ? [
//                                 BoxShadow(
//                                   color: Colors.purple.withOpacity(0.5),
//                                   spreadRadius: 3,
//                                   blurRadius: 10,
//                                 ),
//                               ]
//                             : [],
//                         border: Border.all(
//                           color: _isFocused
//                               ? Colors.purple.shade400
//                               : Colors.grey.shade300,
//                           width: 2.0,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: _controller,
//                         decoration: const InputDecoration(
//                           hintText: 'Type a message...',
//                           contentPadding: EdgeInsets.symmetric(
//                             vertical: 10.0,
//                             horizontal: 20.0,
//                           ),
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.purple,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageWidget(ChatMessage message, bool isSentMessage) {
//     return Stack(
//       children: [
//         Align(
//           alignment:
//               isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
//           child: Container(
//             width: 180,
//             height: 60,
//             margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isSentMessage ? Colors.purple.shade200 : Colors.grey[300],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               crossAxisAlignment: isSentMessage
//                   ? CrossAxisAlignment.end
//                   : CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message.message,
//                   style: TextStyle(
//                     color: isSentMessage ? Colors.white : Colors.black87,
//                     fontWeight:
//                         isSentMessage ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat('dd MMM yyyy hh:mm a').format(message.timestamp),
//                   style: const TextStyle(fontSize: 14, color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Positioned(
//           top: -22,
//           right: isSentMessage ? 9 : null,
//           left: isSentMessage ? null : 9,
//           child: PopupMenuButton<String>(
//             color: Colors.grey[850],
//             icon: const Icon(
//               Icons.more_horiz,
//               color: Colors.black,
//               size: 37,
//             ),
//             onSelected: (String value) {
//               if (value == 'Update') {
//                 _showUpdateDialog(message);
//               } else if (value == 'Delete') {
//                 _showDeleteDialog(message);
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 const PopupMenuItem<String>(
//                   value: 'Update',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Text(
//                         'Update',
//                         style: TextStyle(
//                           fontFamily: 'poppins',
//                           fontSize: 15,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'Delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text(
//                         'Delete',
//                         style: TextStyle(
//                           fontFamily: 'poppins',
//                           fontSize: 15,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ];
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/chat.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int userId;
  final String userName;
  final int receiverId;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.receiverId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late TextEditingController _controller;
  late ChatNotifier _chatNotifier;
  bool _isFocused = false;
  bool _isEmpty = true; // Track if the message input is empty

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _chatNotifier = ref.read(chatProvider.notifier);
    _chatNotifier.getChatMessagesForUser(widget.userId, widget.receiverId);
    _controller.addListener(_checkEmpty);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkEmpty() {
    setState(() {
      _isEmpty = _controller.text.isEmpty;
    });
  }

  void _sendMessage(String messageContent) {
    final userId = ref.read(currentUserProvider) as int;
    if (messageContent.isNotEmpty) {
      _chatNotifier.addChatMessage(
        messageContent,
        userId,
        widget.receiverId,
      );
      _controller.clear();
    }
  }

  void _showUpdateDialog(ChatMessage message) {
    final TextEditingController updateController =
        TextEditingController(text: message.message);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Update Message'),
            ],
          ),
          content: TextField(
            controller: updateController,
            decoration: InputDecoration(
              hintText: 'Type new message',
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Cancel'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (updateController.text.isNotEmpty) {
                      _chatNotifier.updateChatMessage(
                          message.id, updateController.text);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Update'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Message'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Cancel'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _chatNotifier.deleteChatMessage(message.id);
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.red),
                      SizedBox(width: 4),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userName.split('@').first.toUpperCase();
    userName = userName.replaceAll(RegExp(r'[0-9]'), '');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fade(duration: 1000.ms).scale(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final chatNotifier = ref.watch(chatProvider);
                if (chatNotifier.isEmpty) {
                  // Show "Say Hello" button if no messages
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: TextButton(
                      onPressed: _isEmpty
                          ? () {
                              _sendMessage('Say, Hello 👋');
                            }
                          : null,
                      child: const Text(
                        'Say, Hello 👋',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: chatNotifier.length,
                    itemBuilder: (context, index) {
                      final message = chatNotifier[index];
                      final isSentMessage = message.userId == widget.userId;
                      return _buildMessageWidget(message, isSentMessage);
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isFocused = hasFocus;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: _isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: _isFocused
                              ? Colors.purple.shade400
                              : Colors.grey.shade300,
                          width: 2.0,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          _checkEmpty();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      _sendMessage(
                          _controller.text); // Send the current message
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message, bool isSentMessage) {
    return Stack(
      children: [
        Align(
          alignment:
              isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 180,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSentMessage ? Colors.purple.shade200 : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: isSentMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isSentMessage ? Colors.white : Colors.black87,
                    fontWeight:
                        isSentMessage ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy hh:mm a').format(message.timestamp),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -22,
          right: isSentMessage ? 9 : null,
          left: isSentMessage ? null : 9,
          child: PopupMenuButton<String>(
            color: Colors.grey[850],
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: 37,
            ),
            onSelected: (String value) {
              if (value == 'Update') {
                _showUpdateDialog(message);
              } else if (value == 'Delete') {
                _showDeleteDialog(message);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Update',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ),
      ],
    );
  }
}
