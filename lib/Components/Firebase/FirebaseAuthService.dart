import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  String? name, imageUrl, userEmail, uid;

  signInWithGoogle()async{
    try{
      // final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      // if(googleSignInAccount != null){
      //   final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      //   final AuthCredential authCredential = GoogleAuthProvider.credential(
      //     accessToken: googleSignInAuthentication.accessToken,
      //     idToken: googleSignInAuthentication.idToken,
      //   );
      //   await _auth.signInWithCredential(authCredential);
      // }
      // Initialize Firebase
      await Firebase.initializeApp();
      User? user;
      FirebaseAuth auth = FirebaseAuth.instance;
      // The `GoogleAuthProvider` can only be 
      // used while running on the web
      GoogleAuthProvider authProvider = GoogleAuthProvider();
    
      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    
      if (user != null) {
        uid = user.uid;
        name = user.displayName;
        userEmail = user.email;
        imageUrl = user.photoURL;
    
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setBool('auth', true);
        print("name: $name");
        print("userEmail: $userEmail");
        print("imageUrl: $imageUrl");
      }
      return user;
    } on FirebaseAuthException catch(e){
      print(e);
    }
  }
  signOut() async{
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}