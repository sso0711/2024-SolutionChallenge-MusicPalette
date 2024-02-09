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
async function vibrationToJSON(){

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

exports.postInitializeStore = async function(){
    try{
        const mp3Directory = './assets/musics';
        const mp3Files = await fs.promises.readdir(mp3Directory);
        const mp3FilePath = mp3Files.map(file => path.join(mp3Directory, file));

        const lrcDirectory = './assets/lyrics';
        const lrcFiles = await fs.promises.readdir(lrcDirectory);
        const lrcFilePath = lrcFiles.map(file => path.join(lrcDirectory, file));

        const db = admin.database();

        for(let i = 0; i < mp3Files.length; i++){
            const metadata = await mm.parseFile(mp3FilePath[i], { duration: true });
    
            // Common metadata (artist, title, album, etc.)
            const commonMetadata = metadata.common;
            const lyrics = await lrcToJson(lrcFilePath[i]);
            const encodedTitle = encodeURIComponent(commonMetadata.title);

            const postInitializeStoreParams = [commonMetadata.title, encodedTitle, commonMetadata.artist, lyrics];

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

