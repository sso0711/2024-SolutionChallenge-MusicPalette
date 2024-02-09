const jwtMiddleware = require("../../../config/jwtMiddleware");
const userProvider = require("../../app/User/userProvider");
const userService = require("../../app/User/userService");
const baseResponse = require("../../../config/baseResponseStatus");
const {response, errResponse} = require("../../../config/response");

const regexEmail = require("regex-email");
const {emit} = require("nodemon");

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
  * API No. 3
  * API Name : Initialize - Store Music info API
  * [POST] /initialize-store
  */
 exports.postInitializeStore = async function(req, res){
    const responseStore = await userService.postInitializeStore();
    return res.send(responseStore);
 }

 /**
  * API No. 4
  * API Name : Get musics list API
  * [GET] /musics
  */
 exports.getMusicList = async function(req, res){
    const musicList = await userProvider.getMusicList();
    return res.send(musicList);
 }