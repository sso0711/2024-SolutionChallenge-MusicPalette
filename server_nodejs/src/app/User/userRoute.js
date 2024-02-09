module.exports = function(app){
    const user = require('./userController');
    const jwtMiddleware = require('../../../config/jwtMiddleware');
    const express = require('express');
    app.use(express.urlencoded({ extended: true }));

    // 0. 테스트 API
     app.get('/app/test', user.getTest);

     // provide coverimages
     app.use('/images/cover-image', express.static('./assets/coverimages'));

     // provide madeimages
     app.use('/images/made-image', express.static('./assets/madeimages'));

     // provide mp3 files
     app.use('/musics/mp3-file', express.static('./assets/musics'));

     // 1. initialize - lrc & coverimages API
     app.post('/initialize-parse', user.postInitializeParse);

     // 2. initialize - get madeimages from ML Server API
     app.post('/initialize-made', user.postInitializeMade);

     // 3. initialize - store musics info in db API 
     app.post('/initialize-store', user.postInitializeStore);

     // 4. get all musics list API
     app.get('/musics', user.getMusicList);

     // 5. get a music info API
     app.get('/musics/:music_id', user.getMusicInfo);

};
