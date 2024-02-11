const {logger} = require("../../../config/winston");
const userProvider = require("../../app/User/userProvider");
const userService = require("../../app/User/userService");
const baseResponse = require("../../../config/baseResponseStatus");
const {response, errResponse} = require("../../../config/response");

// initialize firebase admin SDK 
const admin = require("firebase-admin");
const serviceAccount = require("../../../config/music-palette-firebase-adminsdk-4u2ui-4db9a9b2ff.json");
const databaseURL = require("../../../config/database").getDatabaseURL();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: databaseURL
});

let cleanupAlreadyCalled = false;
function cleanupAndExit() {
  if(!cleanupAlreadyCalled){
    cleanupAlreadyCalled = true;
    console.log('Cleaning up Firebase Admin SDK...');
    
    // Delete Firebase Admin SDK
    admin.app().delete()
      .then(() => {
        console.log('Firebase Admin SDK cleanup successful');
        process.exit(0); // 정상 종료
      })
      .catch((error) => {
        console.error('Error cleaning up Firebase Admin SDK:', error);
        process.exit(1); // 오류로 종료
      });
  }
}
process.on('SIGINT', cleanupAndExit);
process.on('exit', cleanupAndExit);

async function validateFirebaseIdToken(idToken){
  try {
    const userRecord = await admin.auth().getUser(idToken);
    // 해당 UID의 사용자 정보를 가져옴
    console.log('Valid UID:', userRecord.uid);
    return userRecord.uid; 

  } catch (error) {
    // UID가 Firebase에 존재하지 않거나 검증에 실패한 경우 처리
    console.error('Invalid UID:', error);
    throw error; // 에러를 다시 throw하여 호출자에게 전파할 수 있음
  }
}

/**
 * API No. 0
 * API Name : 테스트 API
 * [GET] /app/test
 */
 exports.getTest = async function (req, res) {
    const db = admin.database();
    const ref = db.ref('Test');
    
    await ref.set({
        test: "Test successful"
    });

    return res.send(response(baseResponse.SUCCESS))
 };

 /**
  * API No. 1
  * API Name : Initialize - Parse lrc & coverimages from mp3 API
  * [POST] /initialize-parse
  */
 exports.postInitializeParse = async function(req, res){
    const response = await userService.postInitializeParse();
    return res.send(response);
 };

 /**
  * API No. 2
  * API Name : Initialize - Get made image from ML Server API
  * [POST] /initialize-made
  */
 exports.postInitializeMade = async function(req, res){
    const response = await userService.postInitializeMade();
    return res.send(response);
 }

 /**
  * API No. 3
  * API Name : Initialize - Store Music info API
  * [POST] /initialize-store
  */
 exports.postInitializeStore = async function(req, res){
    const responseStore = await userService.postInitializeStore();
    return res.send(responseStore);
 };

 /**
  * API No. 4
  * API Name : Get musics list API
  * [GET] /musics
  */
 exports.getMusicList = async function(req, res){
    const musicList = await userProvider.getMusicList();
    return res.send(musicList);
 };

 /**
  * API No. 5
  * API Name : Get a music info API
  * [GET] /musics/:music_id
  */
 exports.getMusicInfo = async function(req, res){
    const musicId = req.params.music_id;

    const musicInfo = await userProvider.getMusicInfo(musicId);
    return res.send(musicInfo);
 };

 /**
  * API No. 6
  * API Name : Get user likes API
  * [GET] /user/like
  */
 exports.getUserLikes = async function(req, res){
  try{
      const idToken = req.header('Authorization');
      // idToken 유효 확인
      const userId = await validateFirebaseIdToken(idToken);

      const userLikes = await userProvider.getUserLikes(userId);
      return res.send(userLikes);

  }catch(error){
      logger.error(`App - userController getUserLikes error\n: ${error.message}`);
      return res.send(errResponse(baseResponse.DB_ERROR));
  }
 }

 /**
  * API No. 7
  * API Name : Add user like API
  * [POST] /user/like/:music_id
  */
 exports.postUserLike = async function(req, res){
    const idToken = req.header('Authorization');
    // idToken 유효 확인
    const userId = await validateFirebaseIdToken(idToken);

    const musicId = req.params.music_id;

    const userLikes = await userService.postUserLike(userId, musicId);
    return res.send(userLikes);
 }

 /**
  * API No. 8
  * API Name : Delete user like API
  * [POST] /user/like/:music_id
  */
 exports.deleteUserLike = async function(req, res){
    const idToken = req.header('Authorization');
    // idToken 유효 확인
    const userId = await validateFirebaseIdToken(idToken);

    const musicId = req.params.music_id;

    const userLikes = await userService.deleteUserLike(userId, musicId);
    return res.send(userLikes);
 }