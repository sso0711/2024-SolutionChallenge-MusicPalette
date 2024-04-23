const {logger} = require("../../../config/winston");
const userDao = require("./userDao");
const baseResponse = require("../../../config/baseResponseStatus");
const {response} = require("../../../config/response");
const {errResponse} = require("../../../config/response");

const admin = require("firebase-admin");

const fs = require('fs');
const mm = require('music-metadata');
const axios = require('axios');
const path = require('path');
const { exec } = require('child_process');

// Service: Create, Update, Delete business logic 

// change lrc to json
async function lrcToJson(lrcFilePath) {
    const lrcContent = fs.readFileSync(lrcFilePath, 'utf-8');
    const lines = lrcContent.split('\n');
  
    const lyrics = [];
  
    for (const line of lines) {
      const match = line.match(/\[([0-9:.]+)\](.*)/);
  
      if (match) {
        const time = match[1];
        const text = match[2].trim();
  
        lyrics.push({"time": time, "lyric": text});
      }
    }
    return JSON.stringify(lyrics, null, 2);
}

// change lrc to string
async function lrcToString(lrcFilePath){
  const lrcContent = fs.readFileSync(lrcFilePath, 'utf-8');
  const lines = lrcContent.split('\n');
  let lyrics = '';

  for (const line of lines) {
    const match = line.match(/\[([0-9:.]+)\](.*)/);

    if (match) {
      const text = match[2].trim();
      lyrics += text;
    }
  }
  return lyrics;

}

// vibration to json
async function vibrationToJSON(mp3FilePath){
  return new Promise((resolve, reject) => {
    const pythonScript = './assets/vibration_madmom.py';
    
    const vibrations = [];

    // madmom module & scipy module setting _ for nodejs에서 모듈 파악
    process.env.PYTHONPATH = './assets/madmom:/home/thdudp7007/.local/lib/python3.8/site-packages';

    exec(`python3 ${pythonScript} "${mp3FilePath}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Execution Error:', error);
        reject(stderr || 'Execution failed');
      } else {
        // Parsing output value (multiple lines) of python scrypt into JSON format 
        stdout.trim().split('\n').map(line => {
          const [time, strength] = JSON.parse(line);
          vibrations.push({"time": time, "strength": strength});
        });
        resolve(JSON.stringify(vibrations, null, 2));
      }
    });
  });
}

// for test vibration
async function vibrationToJSONLibrosa(mp3FilePath){
  return new Promise((resolve, reject) => {
    const pythonScript = './assets/vibration_librosa.py';
    
    const vibrations = [];

    // madmom module & scipy module setting _ for nodejs에서 모듈 파악
    process.env.PYTHONPATH = './assets/madmom:/home/thdudp7007/.local/lib/python3.8/site-packages';

    exec(`python3 ${pythonScript} "${mp3FilePath}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Execution Error:', error);
        reject(stderr || 'Execution failed');
      } else {
        // Parsing output value (multiple lines) of python scrypt into JSON format 
        stdout.trim().split('\n').map(line => {
          const [time, strength] = JSON.parse(line);
          vibrations.push({"time": time, "strength": strength});
        });
        resolve(JSON.stringify(vibrations, null, 2));
      }
    });
  });
}

async function getDuration(mp3FilePath){
  return new Promise((resolve, reject) => {
    const pythonScript = './assets/vibration_duration.py';
    
    process.env.PYTHONPATH = '/home/thdudp7007/.local/lib/python3.8/site-packages';

    exec(`python3 ${pythonScript} "${mp3FilePath}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Execution Error:', error);
        reject(stderr || 'Execution failed');
      } else {
        // Parsing output value (multiple lines) of python scrypt into JSON format 
        const duration = JSON.parse(stdout.trim());

        resolve(duration);
      }
    });
  });
}

// process get lrc & coverimages
async function processLrcCover(mp3File){
  return new Promise((resolve, reject) => {
        const pythonScript = './assets/lrc_parsing_mp3.py';

        // madmom module & scipy module setting _ 설정 안하면 nodejs에서 모듈 파악 불가
        process.env.PYTHONPATH = '/home/thdudp7007/.local/lib/python3.8/site-packages:./assets/add_album_cover.py:./assets/lyrics_naver.py';
    
        exec(`python3 ${pythonScript} ${mp3File}`, (error, stdout, stderr) => {
          if (error) {
            console.error('Execution Error:', error);
            reject(stderr || 'Execution failed');
          } else {
            resolve(stdout.trim());
          }
        });
    });
}

// image download from http and save
async function downloadAndSaveImage(imageUrl, savePath) {
  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });

    // save image
    fs.writeFileSync(savePath, response.data);

    console.log('Image downloaded and saved successfully.');
  } catch (error) {
    console.error('Error downloading or saving the image:', error.message || error);
  }
}

exports.postInitializeParse = async function(){
  try{
    await processLrcCover();
    return response(baseResponse.SUCCESS);
  }catch(error){
    logger.error(`App - userService postInitializeParse error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

exports.postInitializeMade = async function(){
  try{
    const db = admin.database();
    // ML Server endpoint
    const apiUrl = 'https://2b6a-116-44-106-196.ngrok-free.app';

    const mp3Files = await fs.promises.readdir('./assets/musics');
    for(let i = 0; i < mp3Files.length; i++){
      console.log(mp3Files[i]);
    }
    const encodedTitle = mp3Files.map(file => {
      const lastIndex = file.lastIndexOf('.');
      return encodeURI(file.substring(0, lastIndex));
    });

    // mp3Files.length
    for(let i = 0; i < mp3Files.length; i++){
      const requestData = {
        //encodedTitle[i]
        link: 'http://music-palette.shop/musics/mp3-file/' + encodedTitle[i] +'.mp3',
        lyrics: lrcToString('./assets/lyrics/' + decodeURI(encodedTitle[i])+'.lrc')
      }

      // console.log('http://music-palette.shop/musics/mp3-file/' +encodedTitle[i] +'.mp3');
      // console.log(lrcToString('./assets/lyrics/' + decodeURI(encodedTitle[i])+'.lrc'));
      axios.post(apiUrl, requestData)
      .then(async response => {
        // get information from JSON data 
        const imageLink = response.data.url;
        console.log(imageLink);
        console.log(decodeURI(encodedTitle[i]));
        const imageExplain = response.data.text;
        console.log(imageExplain);

        await downloadAndSaveImage(imageLink, './assets/madeimages/' + decodeURI(encodedTitle[i])+'.jpg');
        await userDao.postInitializeMade(db, (i+1), imageExplain);
      })
      .catch(error => {
        // Process Error
        console.error('Error:', error.message || error);
      });

    }
    return response(baseResponse.SUCCESS);


  }catch(error){
    logger.error(`App - userService postInitializeMade error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

exports.postInitializeStore = async function(){
    try{
        const db = admin.database();
        const isDBMusicExist = await userDao.checkDBMusicExist(db);

        // check db music is already initialized
        if(isDBMusicExist == null){
          const mp3Directory = './assets/musics';
          const mp3Files = await fs.promises.readdir(mp3Directory);
          const mp3FilePath = mp3Files.map(file => path.join(mp3Directory, file));
  
          const lrcDirectory = './assets/lyrics';
          const lrcFiles = await fs.promises.readdir(lrcDirectory);
          const lrcFilePath = lrcFiles.map(file => path.join(lrcDirectory, file));
  
          // send list of files to client
          const encodedTitle = mp3Files.map(file => {
            const lastIndex = file.lastIndexOf('.');
            return encodeURI(file.substring(0, lastIndex));
          });
  
  
          for(let i = 0; i < mp3Files.length; i++){
              const metadata = await mm.parseFile(mp3FilePath[i], { duration: true });
  
              console.log(i+1);
              const vibrations = await vibrationToJSON(mp3FilePath[i]);
      
              // Common metadata (artist, title, album, etc.)
              const commonMetadata = metadata.common;
              const lyrics = await lrcToJson(lrcFilePath[i]);
  
              const postInitializeStoreParams = [commonMetadata.title, encodedTitle[i], commonMetadata.artist, lyrics, vibrations];
  
              await userDao.postInitializeStore(db, postInitializeStoreParams);
              console.log('store end');
          }
          return response(baseResponse.SUCCESS);
        }
        else{
          return response(baseResponse.DB_ALREADY_INITIALIZED);
        }
    }catch(error){
      logger.error(`App - userService postInitializeServer error\n: ${error.message}`);
      return errResponse(baseResponse.DB_ERROR);
    }
}

exports.postUserLike = async function(userId, musicId){
  try{
    const db = admin.database();
    const userLikes = await userDao.postUserLike(db, userId, musicId);
    return userLikes;
  }catch(error){
    logger.error(`App - userService postUserLike error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

exports.deleteUserLike = async function(userId, musicId){
  try{
    const db = admin.database();
    const userLikes = await userDao.deleteUserLike(db, userId, musicId);
    return userLikes;
  }catch(error){
    logger.error(`App - userService deleteUserLike error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

// for test vibration
exports.postVibration = async function(){

  try{
    const db = admin.database();
    const mp3Directory = './assets/musics';
    const mp3Files = await fs.promises.readdir(mp3Directory);
    const mp3FilePath = mp3Files.map(file => path.join(mp3Directory, file));

    for(let i = 0; i < mp3Files.length; i++){

      const vibrations = await vibrationToJSONLibrosa(mp3FilePath[i]);

      const musicId = i+1;

      await userDao.postVibration(db, musicId, vibrations);
      console.log(musicId, ' end');
    }
    return response(baseResponse.SUCCESS);
  }catch(error){
    logger.error(`App - userService postVibration error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

// for duration test
exports.postDuration = async function(){
  try{
    const db = admin.database();

      const mp3Directory = './assets/musics';
      const mp3Files = await fs.promises.readdir(mp3Directory);
      const mp3FilePath = mp3Files.map(file => path.join(mp3Directory, file));

      for(let i = 0; i < mp3Files.length; i++){

          console.log(i+1);
          const duration = await getDuration(mp3FilePath[i]);

          const musicId = i+1;

          await userDao.postDuration(db, musicId,  duration);
          console.log('duration end');
      }
      return response(baseResponse.SUCCESS);
  }catch(error){
    logger.error(`App - userService postDuration error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

exports.postUploadMp3 = async function(tempFileName){

  const realFile = await processLrcCover(tempFileName);

  // lrc나 lyrics 찾기 못했을 때 에러 반환
  if( realFile == "\"-1\""){
    return errResponse(baseResponse.MP3_LYRIC_ERROR);
  }

  const index = realFile.lastIndexOf('.');

  const realFileName = realFile.substring(0, index);

  // is lyric is lrc or txt
  const type = realFile.substring(index + 1);

  console.log(realFileName, type);

  
  console.log('lrc or lyric 긁어오기 성공', realFileName);
  return response(baseResponse.SUCCESS);
}