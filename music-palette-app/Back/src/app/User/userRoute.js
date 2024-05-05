module.exports = function(app){
    const user = require('./userController');
    const express = require('express');
    
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



     // provide coverimages
     app.use('/images/cover-image', express.static('./assets/coverimages'));

     // provide madeimages
     app.use('/images/made-image', express.static('./assets/madeimages'));

     // provide mp3 files
     app.use('/musics/mp3-file', express.static('./assets/musics'));

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
     app.post('/musics/upload-mp3', upload.single('mp3file'), user.postUploadMp3);

};
