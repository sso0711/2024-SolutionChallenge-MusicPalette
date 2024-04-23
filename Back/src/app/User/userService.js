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
        const lines = stdout.trim().split('\n');

        // 마지막 줄 처리 (average - for duration)
        const averageData = lines.pop();
        let average;
        try {
          average = JSON.parse(averageData);
        } catch (parseError) {
          console.error('Parsing error for average:', parseError);
          return reject(new Error('Failed to parse average from Python script'));
        }

        try {
          lines.map(line => {
            const [time, strength] = JSON.parse(line);
            vibrations.push({"time": time, "strength": strength});
          });
          // 모든 데이터와 average를 반환
          resolve({vibrations, average});
        } catch (parseError) {
          console.error('Parsing error for vibrations:', parseError);
          reject(new Error('Failed to parse vibration data from Python script'));
        }

        // Parsing output value (multiple lines) of python scrypt into JSON format 
        // stdout.trim().split('\n').map(line => {
        //   const [time, strength] = JSON.parse(line);
        //   vibrations.push({"time": time, "strength": strength});
        // });
        // resolve(JSON.stringify(vibrations, null, 2));
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

// remove file
async function removeFile(filePath){
  // 파일 존재 여부 확인
  if (fs.existsSync(filePath)) {
    fs.unlink(filePath, (err) => {
        if (err) {
            console.error('File deletion error:', err);
            return;
        }
        console.log('File deleted successfully');
    });
  } else {
    console.log('File does not exist, cannot delete');
  }
}

// move file directory
async function moveFile(filePath, newPath){
  fs.rename(filePath, newPath, (err) => {
    if (err) {
        console.error('Error moving file:', err);
        return;
    }
    console.log('File moved successfully!');
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

exports.postUploadMp3 = async function(tempFile){
  try{
    const db = admin.database();
    
    const uploadMusicDirectory = './assets/uploads/musics';
    const uploadMp3FilePath = path.join(uploadMusicDirectory, tempFile);
  
    let realLyricFile = await processLrcCover(tempFile);
    realLyricFile = realLyricFile.substring(1, realLyricFile.length-1);
  
    // lrc나 lyrics 찾기 못했을 때 에러 반환
    if( realLyricFile == "\"-1\""){
      // mp3 파일 삭제
      removeFile(uploadMp3FilePath); 
      return errResponse(baseResponse.MP3_LYRIC_ERROR);
    }
  
    const index = realLyricFile.lastIndexOf('.');
    const realTitle = realLyricFile.substring(0, index);
  
    // is lyric is lrc or txt
    const type = realLyricFile.substring(index + 1);
    
    console.log('lrc or lyric 긁어오기 성공', realTitle);
  
    // vibration & duration 구하기
    const vibrationAndDuration = await vibrationToJSONLibrosa(uploadMp3FilePath);
  
    const vibrations = JSON.stringify(vibrationAndDuration.vibrations, null, 2)
    const duration = vibrationAndDuration.average;
  
    console.log('vibrations and duration 변환 성공');
  
    // made image & description 구하기
  
    // 다 성공했을 경우 uploads에서 모든걸 삭제하고 전체 곡 있는 곳으로 옮기기
    // 옮겨야 할 장소
    // 1. musics
    const realMusicDirectory = './assets/musics';
    const realMusicFilePath = path.join(realMusicDirectory, realTitle + '.mp3');

    // 2. lyrics
    const realLyricsDirectory = './assets/lyrics';
    const realLyricsFilePath = path.join(realLyricsDirectory, realLyricFile);

    // 3. coverimage
    const realCoverimageDirectory = './assets/coverimages';
    const realCoverimageFilePath = path.join(realCoverimageDirectory, realTitle + '.jpg');

    // // 4. madeimage
    // const realMadeimageDirectory = './assets/madeimages';
    // const realMadeimageFilePath = path.join(realMadeimageDirectory, realTitle + '.jpg');

    // move directory - music, lyrics, coverimage, madeimage
    moveFile(uploadMp3FilePath, realMusicFilePath);
    moveFile(path.join('./assets/uploads/lyrics', realLyricFile), realLyricsFilePath);
    // coverimage 존재 여부 확인
    if (fs.existsSync(path.join('./assets/uploads/coverimages', realTitle+'.jpg'))) {
      moveFile(path.join('./assets/uploads/coverimages', realTitle+'.jpg'), realCoverimageFilePath);
    } else {
      console.log('Coverimage does not exist, so cannot move');
    }
    // moveFile(path.join('./assets/uploads/madeimages', realTitle+'.jpg'), realMadeimageFilePath);

    console.log('move 완료 !!!');

  
    // DB에 저장하기
  
    // disk 50GB 미만으로 남았을 땐 업로드 금지
  
  
    return response(baseResponse.SUCCESS);
  }catch(error){
    logger.error(`App - userService postUploadMp3 error\n: ${error.message}`);
    return errResponse(baseResponse.DB_ERROR);
  }
}