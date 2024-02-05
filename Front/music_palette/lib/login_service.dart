import 'package:google_sign_in/google_sign_in.dart';

class MusicUser {
  late GoogleSignInAccount googleUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  late String userImage;
  late String userName;
  late String userEmail;
  late String userId;
  bool isLogin = false;

  void updateuser({required GoogleSignInAccount googleaccount}) {
    userImage = googleaccount.photoUrl!;
    userName = googleaccount.displayName!;
    userEmail = googleaccount.email;
    userId = googleaccount.id;
    isLogin = true;
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleuser = await GoogleSignIn().signIn();
    if (googleuser != null) {
      updateuser(googleaccount: googleuser);
    }
  }
}
