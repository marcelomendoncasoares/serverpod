import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

sealed class EmailAccountPassword {
  static EmailAccountPasswordHash fromPasswordHash(
    final String passwordHash,
  ) {
    return EmailAccountPasswordHash(passwordHash);
  }

  static EmailAccountPasswordString fromString(final String password) {
    return EmailAccountPasswordString(password);
  }
}

final class EmailAccountPasswordHash extends EmailAccountPassword {
  final String passwordHash;

  EmailAccountPasswordHash(this.passwordHash);
}

final class EmailAccountPasswordString extends EmailAccountPassword {
  final String password;

  EmailAccountPasswordString(this.password);
}

final class EmailIdpTestFixture {
  late final EmailIdp emailIdp;
  late final TokenManager tokenManager;
  final UserProfiles userProfiles = const UserProfiles();
  final AuthUsers authUsers = const AuthUsers();

  EmailIdpTestFixture({
    final EmailIdpConfig config = const EmailIdpConfig(
      secretHashPepper: 'pepper',
    ),
    TokenManager? tokenManager,
  }) {
    tokenManager ??= AuthServices(
      authUsers: authUsers,
      userProfiles: userProfiles,
      primaryTokenManagerBuilder: ServerSideSessionsConfig(
        sessionKeyHashPepper: 'test-pepper',
      ),
      identityProviderBuilders: [],
    ).tokenManager;

    // Analyzer incorrectly suggests this should be initialized in the
    // constructor.
    // ignore: prefer_initializing_formals
    this.tokenManager = tokenManager;
    emailIdp = EmailIdp(config, tokenManager: tokenManager);
  }

  Future<EmailAccount> createEmailAccount(
    final Session session, {
    required final UuidValue authUserId,
    required final String email,
    final EmailAccountPassword? password,
  }) async {
    final passwordHash = switch (password) {
      final EmailAccountPasswordHash password => password.passwordHash,
      final EmailAccountPasswordString password =>
        await passwordHashUtil.createHashFromString(secret: password.password),
      null => '',
    };

    return await EmailAccount.db.insertRow(
      session,
      EmailAccount(
        authUserId: authUserId,
        email: email.toLowerCase().trim(),
        passwordHash: passwordHash,
      ),
    );
  }

  Future<void> changeAccountPassword(
    final Session session, {
    required final EmailAccount emailAccount,
    required final String password,
  }) async {
    final verificationCode = const Uuid().v4().toString();
    final tempFixture = EmailIdpTestFixture(
      config: EmailIdpConfig(
        secretHashPepper: 'pepper',
        passwordResetVerificationCodeGenerator: () => verificationCode,
        passwordValidationFunction: (final password) => true,
        passwordHistory: const PasswordHistory(
          count: 15,
          retentionPeriod: Duration(days: 365),
        ),
      ),
    );
    final passwordResetRequestId = await session.db.transaction(
      (final transaction) => passwordResetUtil.startPasswordReset(
        session,
        email: emailAccount.email,
        transaction: transaction,
      ),
    );

    final completePasswordResetToken = await session.db.transaction(
      (final transaction) => passwordResetUtil.verifyPasswordResetCode(
        session,
        passwordResetRequestId: passwordResetRequestId,
        verificationCode: verificationCode,
        transaction: transaction,
      ),
    );

    await session.db.transaction(
      (final transaction) => passwordResetUtil.completePasswordReset(
        session,
        completePasswordResetToken: completePasswordResetToken,
        newPassword: password,
        transaction: transaction,
      ),
    );
  }

  Future<void> tearDown(final Session session) async {
    await session.db.transaction((final transaction) async {
      await Future.wait([
        EmailAccount.db.deleteWhere(
          session,
          where: (final _) => Constant.bool(true),
          transaction: transaction,
        ),
        EmailAccountPasswordResetRequest.db.deleteWhere(
          session,
          where: (final _) => Constant.bool(true),
          transaction: transaction,
        ),
        EmailAccountRequest.db.deleteWhere(
          session,
          where: (final _) => Constant.bool(true),
          transaction: transaction,
        ),
        RateLimitedRequestAttempt.db.deleteWhere(
          session,
          where: (final t) => t.domain.equals('email'),
          transaction: transaction,
        ),
        SecretChallenge.db.deleteWhere(
          session,
          where: (final _) => Constant.bool(true),
          transaction: transaction,
        ),
        AuthUser.db.deleteWhere(
          session,
          where: (final _) => Constant.bool(true),
          transaction: transaction,
        ),
      ]);
    });
  }

  Argon2HashUtil get passwordHashUtil => emailIdp.utils.hashUtil;
  EmailIdpAuthenticationUtil get authenticationUtil =>
      emailIdp.utils.authentication;
  EmailIdpPasswordResetUtil get passwordResetUtil =>
      emailIdp.utils.passwordReset;
  EmailIdpAccountCreationUtil get accountCreationUtil =>
      emailIdp.utils.accountCreation;
  EmailIdpConfig get config => emailIdp.config;
}
