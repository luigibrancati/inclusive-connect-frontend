import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/common_models.dart';
import 'dart:math';

class InviteCodeService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  InviteCodeService();

  Future<InviteCode> createInviteCode(
    int organizationId, {
    int? maxUses,
    DateTime? expiresAt,
  }) async {
    try {
      final codeString = _generateRandomCode();
      final now = DateTime.now().toIso8601String();

      final newCode = InviteCode(
        code: codeString,
        organizationId: organizationId,
        createdAt: now,
        expiresAt: expiresAt?.toIso8601String(),
        maxUses: maxUses,
        isValid: true,
      );

      await _database.collection('inviteCodes').add(newCode.toJson());

      return newCode;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InviteCode>> getInviteCodes(int organizationId) async {
    try {
      final query = await _database
          .collection('inviteCodes')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      return query.docs.map((doc) => InviteCode.fromJson(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> revokeInviteCode(String code) async {
    try {
      final query = await _database
          .collection('inviteCodes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invite code not found');
      }

      final doc = query.docs.first;
      await doc.reference.update({'isValid': false});
    } catch (e) {
      rethrow;
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
