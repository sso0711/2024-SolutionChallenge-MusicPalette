module.exports = function(app){
    const user = require('./userController');
    const express = require('express');
    const baseResponseStatus = require("../../../config/baseResponseStatus");
    const checkDiskSpace = require('check-disk-space').default;
    const path = require('path');
    const fs = require('fs');
    
    // use multer for getting mp3file
    const multer = require('multer');
    const { v4: uuidv4 } = require('uuid');
    app.use(express.urlencoded({ extended: true }));

    const storage = multer.diskStorage({
        destination: function (req, file, cb) {
          cb(null, './assets/uploads/musics/');  // 파일이 저장될 경로
        },
        filename: function (req, file, cb) {
          const uniqueName = uuidv4();
          cb(null, uniqueName + '.mp3');
          req.uuid = uniqueName;
        }
      });
      
    const upload = multer({ storage: storage });

    // 디스크 공간 확인 미들웨어 - 남은 공간 100GB 이상인지 check
    async function checkDiskSpaceMiddleware(req, res, next) {
      try {
          const diskSpace = await checkDiskSpace('/'); // '/' 디렉토리를 체크
          console.log(diskSpace);
          if (diskSpace.free > 100 * 1024 * 1024 * 1024) { // 100GB 이상 남았는지 확인
              next();
          } else {
              res.send(baseResponseStatus.DISK_SPACE_ERROR);
          }
      } catch (error) {
          res.send(baseResponseStatus.DISK_CHECK_ERROR);
      }
    }


     // provide coverimages
     app.use('/images/cover-image', (req, res, next) => {
      const rootDirectory = '/var/www/2024-SolutionChallenge-MusicPalette/Back';

      const imageDirectory = './assets/coverimages';
      const imagePath = path.join(imageDirectory, decodeURI(req.path.substr(1)));

      const defaultImagePath = path.join(imageDirectory ,'default.jpg');
  
      // 파일 존재 여부 확인
      fs.access(imagePath, fs.constants.F_OK, (err) => {
          if (err) {
              // 파일이 존재 x면 기본 이미지를 전송
              res.sendFile(defaultImagePath, { root: rootDirectory });
          } else {
              // 파일이 존재하면 해당 파일 전송
              res.sendFile(imagePath, { root: rootDirectory });
          }
        });
      });

     // provide madeimages
    //  app.use('/images/made-image', express.static('./assets/madeimages'));
     app.use('/images/made-image', (req, res, next) => {
      const rootDirectory = '/var/www/2024-SolutionChallenge-MusicPalette/Back';

      const imageDirectory = './assets/madeimages';
      const imagePath = path.join(imageDirectory, decodeURI(req.path.substr(1)));


      const defaultDirectory = './assets/coverimages';
      const defaultImagePath = path.join(defaultDirectory ,'default.jpg');
  
      // 파일 존재 여부 확인
      fs.access(imagePath, fs.constants.F_OK, (err) => {
          if (err) {
              // 파일이 존재 x면 기본 이미지를 전송
              res.sendFile(defaultImagePath, { root: rootDirectory });
          } else {
              // 파일이 존재하면 해당 파일 전송
              res.sendFile(imagePath, { root: rootDirectory });
          }
        });
      });

     // provide mp3 files
     app.use('/musics/mp3-file', express.static('./assets/musics'));

     // provide temp mp3 files
     app.use('/musics-temp/mp3-file', express.static('./assets/uploads/musics'));

     // 1. initialize - lrc & coverimages API
     app.post('/initialize-parse', user.postInitializeParse);

     // 2. initialize - store musics info in db API 
     app.post('/initialize-store', user.postInitializeStore);

     // 3. initialize - get madeimages from ML Server API
     app.post('/initialize-made', user.postInitializeMade);

     // 4. get all musics list API
     app.get('/musics', user.getMusicList);

     // 5. get a music info API
     app.get('/musics/:music_id', user.getMusicInfo);

     // 6. get user likes API
     app.get('/user/like', user.getUserLikes);

     // 7. add user like API
     app.post('/user/like/:music_id', user.postUserLike);

     // 8. delete user like API
     app.delete('/user/like/:music_id', user.deleteUserLike);

     // vibration test
     app.post('/vibration-test', user.postVibration);

     // duration
     app.post('/duration-test', user.postDuration);

     // upload mp3 test
     app.post('/musics/upload-mp3', checkDiskSpaceMiddleware, upload.single('mp3file'), user.postUploadMp3);

     // test
     app.post('/test', user.test);

     // testtest
     app.post('/testtest/:music_id', user.testtest);

};
