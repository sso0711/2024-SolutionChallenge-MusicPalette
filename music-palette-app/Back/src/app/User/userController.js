const {logger} = require("../../../config/winston");
const userProvider = require("./userProvider");
const userService = require("./userService");
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
        process.exit(0); // normal exit
      })
      .catch((error) => {
        console.error('Error cleaning up Firebase Admin SDK:', error);
        process.exit(1); // abnormal exit
      });
  }
}
process.on('SIGINT', cleanupAndExit);
process.on('exit', cleanupAndExit);

async function validateFirebaseIdToken(idToken){
  try {
    const userRecord = await admin.auth().getUser(idToken);
    // get user information for the corresponding UID
    // console.log('Valid UID:', userRecord.uid);
    return userRecord.uid; 

  } catch (error) {
    // UID doesn't exist in firbase or fail to verification
    console.error('Invalid UID:', error);
    throw error;
    // 
  }
}


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
  * API Name : Initialize - Store Music info API
  * [POST] /initialize-store
  */
 exports.postInitializeStore = async function(req, res){
    const responseStore = await userService.postInitializeStore();
    return res.send(responseStore);
 };

 /**
  * API No. 3
  * API Name : Initialize - Get made image from ML Server API
  * [POST] /initialize-made
  */
 exports.postInitializeMade = async function(req, res){
  const response = await userService.postInitializeMade();
  return res.send(response);
}

 /**
  * API No. 4
  * API Name : Get musics list API
  * [GET] /musics
  */
 exports.getMusicList = async function(req, res){
  console.log('get request came');
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
      // check vaildity of idToken
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
    // check vaildity of idToken
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
    // check vaildity of idToken
    const userId = await validateFirebaseIdToken(idToken);

    const musicId = req.params.music_id;

    const userLikes = await userService.deleteUserLike(userId, musicId);
    return res.send(userLikes);
 }

 /**
  * API for vibration test ! success
  * [POST]
  */
 exports.postVibration = async function(req, res){
    // test update 할 music의 music_id 
    const response = await userService.postVibration();
    return res.send(response);
 }

 /**
  * API for duration test ! success
  * [POST]
  */
 exports.postDuration = async function(req, res){
  const response = await userService.postDuration();
  return res.send(response);
 }

 /**
  * API for upload mp3 test
  * [POST]
  */
 exports.postUploadMp3 = async function(req, res){
  if(!req.file){
    return res.send(errResponse(baseResponse.FILE_NOT_UPLOADED));
  }
  console.log('upload came');

  const tempFileName = req.uuid + '.mp3';

  const response = await userService.postUploadMp3(tempFileName);
  return res.send(response);

 }
