const { pool } = require("../../../config/database");
const { logger } = require("../../../config/winston");

const userDao = require("./userDao");

const admin = require("firebase-admin");

exports.getMusicList = async function(){
    try{
        const db = admin.database();
        const musicList = await userDao.getMusicList(db);

        return musicList;
    }catch(error){
        logger.error(`App - userProvider getMusicList error\n: ${error.message}`);
        return errResponse(baseResponse.DB_ERROR);
    }
}

exports.getMusicInfo = async function(musicId){
    try{
        const db = admin.database();
        const musicInfo = await userDao.getMusicInfo(db, musicId);
    
        return musicInfo;
    }catch(error){
        logger.error(`App - userProvider getMusicInfo error\n: ${error.message}`);
        return errResponse(baseResponse.DB_ERROR);
    }
}