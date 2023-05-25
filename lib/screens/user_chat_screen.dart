// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChatArguments {
  final String userId;
  final UserType userType;
  final String displayName;
  final String farmerId;

  UserChatArguments({
    required this.userId,
    required this.userType,
    required this.displayName,
    required this.farmerId,
  });
}

enum UserType {
  customers,
  farmer,
  organization,
}

class UserChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  final String userId;
  final UserType userType;
  final String farmerId;
  final String displayName;

  const UserChatScreen({
    required this.userId,
    required this.userType,
    required this.farmerId,
    required this.displayName,
  });

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Stream<QuerySnapshot> _chatStream;

  @override
  void initState() {
    super.initState();

    _chatStream = _firestore
        .collection('chats')
        .doc('customers')
        .collection('messages')
        .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('farmerId',
            isEqualTo:
                widget.farmerId) // Include messages from the specific farmer
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String getChatCollection() {
    return widget.userType == UserType.customers ? 'farmers' : 'customers';
  }

  void _sendMessage() async {
    final String messageText = _messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .get();

    if (messageText.isNotEmpty && userData.data() != null) {
      await _firestore
          .collection('chats')
          .doc('customers')
          .collection('messages')
          .add({
        'customerId': user.uid,
        'displayName': userData.data()!['displayName'],
        'text': messageText,
        'createdAt': DateTime.now(),
        'farmerId': widget.farmerId,
        'role': userData.data()!['role'], // Set the recipient as the farmerId
      });

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.displayName.isNotEmpty ? widget.displayName : 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text('Error occurred'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                final messages = snapshot.data!.docs;

                return ListView.separated(
                  reverse: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final messageText = message['text'] ?? '';
                    final displayName = message['displayName'] ?? '';
                    // ignore: unused_local_variable
                    final role = message['role'] ?? '';

                    final timestamp = message['createdAt'] as Timestamp;
                    final dateTime = timestamp.toDate();
                    final timeString = DateFormat.jm().format(dateTime);

                    final isSentByUser =
                        message['displayName'] == widget.displayName;

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.grey[300]
                              : theme.colorScheme.secondary.withAlpha(200),
                          borderRadius: BorderRadius.only(
                            topLeft: !isSentByUser
                                ? const Radius.circular(12)
                                : Radius.zero,
                            topRight: isSentByUser
                                ? const Radius.circular(12)
                                : Radius.zero,
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxWidth: 200),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSentByUser)
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              messageText,
                              style: TextStyle(
                                height: 1.3,
                                color: isSentByUser
                                    ? Colors.black87
                                    : theme.colorScheme.onSecondary,
                              ),
                              softWrap: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeString,
                              style: TextStyle(
                                color:
                                    isSentByUser ? Colors.black : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}