const { response } = require("express");
const baseResponseStatus = require("../../../config/baseResponseStatus");

// set musicId increase by 1
async function increaseMusicId(db){
    let musicId = 0;
    await db.ref('last_music_id').transaction((currentCounter) => {
        if (currentCounter === null) {
          musicId = 1; // if music_id doesn't exist, initialize to 1
          return 1;
        }
        // if music_id already exists, music_id + 1
        musicId = currentCounter + 1;
        return musicId;
    });
    return musicId;
}

async function postInitializeMade(db, musicId, imageExplain){
    const ref = db.ref('Musics/' + musicId);
    await ref.update(
        {
            "image_explain": imageExplain
        }
    );
}

async function checkDBMusicExist(db){
    const isDBMusicExistref = db.ref('Musics');
    let isDBMusicExist = (await isDBMusicExistref.once('value')).val();

    return isDBMusicExist;
}

async function postInitializeStore(db, postInitializeStoreParams){
    const musicId = await increaseMusicId(db) + '';
    const ref = db.ref('Musics/' + musicId);
    
    await ref.set(
        {
            title: postInitializeStoreParams[0],
            encoded_title: postInitializeStoreParams[1],
            artist: postInitializeStoreParams[2],
            lyrics: postInitializeStoreParams[3],
            vibrations: postInitializeStoreParams[4]
        }
    );

}

async function getMusicList(db){
    const musicNum = (await db.ref('last_music_id').once('value')).val();
    console.log(musicNum);
    const musicList = [];

    for(let i = 1; i<= musicNum; i++){
        const snapshot = await db.ref('Musics/'+ (i + '')).once('value');
        const data = snapshot.val();

        musicList.push({
            "song_id": i,
            "title": data.title,
            "encoded_title": data.encoded_title,
            "artist": data.artist,
            "image_explain": data.image_explain
        });
    }
    
    return JSON.stringify(musicList, null, 4);
}

async function getMusicInfo(db, musicId){
    const ref = db.ref('Musics/' +(musicId +''));
    const data = (await ref.once('value')).val();

    const musicInfo = {
        "lyrics": JSON.parse(data.lyrics),
        "vibrations": JSON.parse(data.vibrations),
        "duration": JSON.parse(data.duration)
    };

    return JSON.stringify(musicInfo, null, 2);
}

async function getUserLikes(db, userId){
    const ref = db.ref('Users/'+ userId);
    let data = (await ref.once('value')).val();
    
    if(data == null){
        const musicNum = (await db.ref('last_music_id').once('value')).val();
        data = new Array(musicNum + 1).fill(false);
        await ref.set({
            "likes": JSON.stringify(data)
        });
    }else{
        // If not JSON.parse, data breaks
        data = JSON.parse(data.likes);
    }
    return {
        // JSON.stringfy to make data JSON
        "likes": JSON.stringify(data)
    }
}

async function postUserLike(db, userId, musicId){
    const ref = db.ref('Users/' + userId);
    const data = (await ref.once('value')).val();

    const likes = JSON.parse(data.likes);

    if(!likes[musicId]){
        likes[musicId] = true;
        await ref.set({
            "likes": JSON.stringify(likes)
        });
    }
    return {
        "likes": JSON.stringify(likes)
    }
}

async function deleteUserLike(db, userId, musicId){
    const ref = db.ref('Users/' + userId);
    const data = (await ref.once('value')).val();

    const likes = JSON.parse(data.likes);

    if(likes[musicId]){
        likes[musicId] = false;
        await ref.set({
            "likes": JSON.stringify(likes)
        });
    }
    return {
        "likes": JSON.stringify(likes)
    }
}

// for vibration test
async function postVibration(db, musicId, vibrations){
    const ref = db.ref('Musics/' + musicId);

    await ref.update(
        {
            vibrations: vibrations,
        }
    );
}

// for duration test
async function postDuration(db, musicId, duration){
    const ref = db.ref('Musics/'+ musicId);


    await ref.update(
        {
            duration: duration,
        }
    );
}

module.exports ={
    postInitializeMade,
    postInitializeStore,
    getMusicList,
    getMusicInfo,
    getUserLikes,
    postUserLike,
    checkDBMusicExist,
    deleteUserLike,
    postVibration,
    postDuration
};