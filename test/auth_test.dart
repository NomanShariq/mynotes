import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();

      test(
        'Should not be Initialize at begin!',
        () {
          expect(provider.isInitialize, false);
        },
      );

      test(
        'Should not Logout if not initialize!',
        () => {
          expect(
            provider.logOut(),
            throwsA(
              const TypeMatcher<NotInitializeException>(),
            ),
          ),
        },
      );

      test('should able to be initialize ', () async {
        await provider.initialize();
        expect(provider.isInitialize, true);
      });

      test('user should be null after initialize', () {
        expect(provider.currentUser, null);
      });

      test('should be initialize less than 2 seconds', () async {
        await provider.initialize();
        expect(provider.isInitialize, true);
      },
          timeout: const Timeout(
            Duration(seconds: 2),
          ));

      test('create user should be delegated', () async {
        final badUserEmail =
            provider.createUser(email: 'foo@gmail.com', password: 'foobar');

        expect(badUserEmail, const TypeMatcher<UserNotFoundException>());

        final badPasswordUser = provider.createUser(
            email: 'someone@gmail.com', password: 'mypassword');

        expect(badPasswordUser, const TypeMatcher<WrongPasswordException>());

        final user = await provider.createUser(
          email: 'foo',
          password: 'bar',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, true);
      });

      test('Logged in user should able to verified', () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      });

      test('user should logged and login again', () {
        provider.logOut();
        provider.logIn(
          email: 'email',
          password: 'password',
        );
        final user = provider.currentUser;
        expect(user, isNotNull);
      });
    },
  );
}

class NotInitializeException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialize = false;
  bool get isInitialize => _isInitialize;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialize) throw NotInitializeException();
    await Future.delayed(
      const Duration(seconds: 2),
    );
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );
    _isInitialize = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialize) throw NotInitializeException();
    if (email == 'foobarbaz@gmail.com') throw UserNotFoundException();
    if (password == 'foobarbaz') throw WrongPasswordException();
    const user = AuthUser(isEmailVerified: false);
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialize) throw NotInitializeException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialize) throw NotInitializeException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
