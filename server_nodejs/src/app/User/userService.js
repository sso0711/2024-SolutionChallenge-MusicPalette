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

// Service: Create, Update, Delete 비즈니스 로직 처리

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

// vibration to json
async function vibrationToJSON(mp3FilePath){
  return new Promise((resolve, reject) => {
    const pythonScript = './assets/vibration_madmom.py';
    
    const vibrations = [];

    // madmom module & scipy module 환경설정 _ 설정 안하면 nodejs에서 모듈 파악 불가
    process.env.PYTHONPATH = './assets/madmom:/home/thdudp7007/.local/lib/python3.8/site-packages';

    exec(`python3 ${pythonScript} "${mp3FilePath}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Execution Error:', error);
        reject(stderr || 'Execution failed');
      } else {
        // 파이썬 스크립트에서 여러 줄로 출력한 값을 JSON 형태로 파싱
        stdout.trim().split('\n').map(line => {
          const [time, strength] = JSON.parse(line);
          vibrations.push({"time": time, "strength": strength});
        });
        resolve(JSON.stringify(vibrations, null, 2));
      }
    });
  });
}

// process get lrc & coverimages
async function processLrcCover(){
    return new Promise((resolve, reject) => {
        const pythonScript = './assets/lrc_parsing_mp3.py';

        // madmom module & scipy module 환경설정 _ 설정 안하면 nodejs에서 모듈 파악 불가
        process.env.PYTHONPATH = '/home/thdudp7007/.local/lib/python3.8/site-packages:./assets/add_album_cover.py';
    
        exec(`python3 ${pythonScript}`, (error, stdout, stderr) => {
          if (error) {
            console.error('Execution Error:', error);
            reject(stderr || 'Execution failed');
          } else {
            resolve(stdout);
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
    const apiUrl = 'https://ml-server.com/api/endpoint';

    const mp3Files = await fs.promises.readdir('./assets/musics');
    const encodedTitle = mp3Files.map(file => {
      const lastIndex = file.lastIndexOf('.');
      return encodeURI(file.substring(0, lastIndex));
    });

    for(let i = 0; i < mp3Files.length; i++){
      const requestData = {
        link: 'http://music-palette.shop/musics/mp3-file/' + encodedTitle[i] +'.mp3'
      }

      axios.post(apiUrl, requestData)
      .then(async response => {
        // 서버 응답의 JSON 데이터에서 필요한 정보를 추출
        const imageLink = response.data.link;
        const imageExplain = response.data.explain;

        await downloadAndSaveImage(imageLink, './assets/madeimages');
        await userDao.postInitializeMade(db, (i+1), imageExplain);
      })
      .catch(error => {
        // 오류 처리
        console.error('Error:', error.message || error);
      });

      return response(baseResponse.SUCCESS);

    }


  }catch(error){
    logger.error(`App - userService postInitializeMade error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}

exports.postInitializeStore = async function(){
    try{
        const mp3Directory = './assets/musics';
        const mp3Files = await fs.promises.readdir(mp3Directory);
        const mp3FilePath = mp3Files.map(file => path.join(mp3Directory, file));

        const lrcDirectory = './assets/lyrics';
        const lrcFiles = await fs.promises.readdir(lrcDirectory);
        const lrcFilePath = lrcFiles.map(file => path.join(lrcDirectory, file));

        // 파일 목록을 클라이언트에게 전송
        const encodedTitle = mp3Files.map(file => {
          const lastIndex = file.lastIndexOf('.');
          return encodeURI(file.substring(0, lastIndex));
        });

        const db = admin.database();

        for(let i = 0; i < mp3Files.length; i++){
            const metadata = await mm.parseFile(mp3FilePath[i], { duration: true });

            const vibrations = await vibrationToJSON(mp3FilePath[i]);
    
            // Common metadata (artist, title, album, etc.)
            const commonMetadata = metadata.common;
            const lyrics = await lrcToJson(lrcFilePath[i]);

            const postInitializeStoreParams = [commonMetadata.title, encodedTitle[i], commonMetadata.artist, lyrics, vibrations];

            await userDao.postInitializeStore(db, postInitializeStoreParams);
        }
        return response(baseResponse.SUCCESS);
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
