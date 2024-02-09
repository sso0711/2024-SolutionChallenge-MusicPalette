const {logger} = require("../../../config/winston");
const {pool} = require("../../../config/database");
const secret_config = require("../../../config/secret");
const userProvider = require("./userProvider");
const userDao = require("./userDao");
const baseResponse = require("../../../config/baseResponseStatus");
const {response} = require("../../../config/response");
const {errResponse} = require("../../../config/response");

const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const {connect} = require("http2");
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

exports.postInitializeParse = async function(){
  try{
    await processLrcCover();
    return response(baseResponse.SUCCESS);
  }catch(error){
    logger.error(`App - userService postInitializeParse error\n: ${error.message}`);
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


// const mm = require('music-metadata');
// const path = require('path');

// const mp3FilePath = 'path/to/your/file.mp3';

// async function getMp3Metadata(filePath) {
//   try {
//     const metadata = await mm.parseFile(filePath, { duration: true });
    
//     // Common metadata (artist, title, album, etc.)
//     const commonMetadata = metadata.common;
//     console.log('Artist:', commonMetadata.artist);
//     console.log('Title:', commonMetadata.title);
//     console.log('Album:', commonMetadata.album);

//     // Additional metadata (e.g., duration)
//     console.log('Duration:', metadata.format.duration); // Duration in seconds
//   } catch (error) {
//     console.error('Error reading metadata:', error.message);
//   }
// }

// getMp3Metadata(mp3FilePath);

