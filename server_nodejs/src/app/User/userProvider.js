const { pool } = require("../../../config/database");
const { logger } = require("../../../config/winston");

const userDao = require("./userDao");

const admin = require("firebase-admin");

exports.getMusicList = async function(){
    const db = admin.database();
    const musicList = await userDao.getMusicList(db);

    return musicList;
}