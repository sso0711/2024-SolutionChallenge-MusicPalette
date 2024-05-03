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
    
    console.log(musicList);
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

async function postUploadMp3(db, postUploadMp3Params){
    const musicId = await increaseMusicId(db) + '';
    const ref = db.ref('Musics/' + musicId);
    
    await ref.set(
        {
            title: postUploadMp3Params[0],
            encoded_title: postUploadMp3Params[1],
            artist: postUploadMp3Params[2],
            lyrics: postUploadMp3Params[3],
            vibrations: postUploadMp3Params[4],
            duration: postUploadMp3Params[5]
        }
    );

}

// 곡 추가 되었을 때, User의 전체 likes 업데이트
// lock 필요. 누가 userLikes 전체 업데이트 중에 user 좋아요 list 읽어가기 하면 안된다
async function updateUserLikes(db) {
    const snapshot = await db.ref('Users').once('value');
    const updates = [];
    snapshot.forEach((childSnapshot) => {
        const userLikesRef = db.ref('Users/' + childSnapshot.key + '/likes');
        const promise = userLikesRef.transaction(current => {
            console.log(current);
            if (current === null) {
                return JSON.stringify([false]); // Initialize if not exists
            } else {
                const likes = JSON.parse(current);
                likes.push(false);
                return JSON.stringify(likes);
            }
        });
        updates.push(promise);
    });

    await Promise.all(updates).then(() => {
        console.log("All updates completed.");
    }).catch(error => {
        console.error("Error updating likes for users:", error);
    });
}

// for test
async function test(db){
    const musicIdRef = db.ref('last_music_id');
    musicIdRef.set(20)
  .then(() => {
    console.log('last_music_id updated to 20 successfully!');
  })
  .catch((error) => {
    console.error('Failed to update last_music_id:', error);
  });
}

// for image explain test
async function testtest(db, musicId){
    const ref = db.ref('Musics/'+ musicId);


    await ref.update(
        {
            image_explain: 'test',
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
    postDuration,
    postUploadMp3,
    updateUserLikes,
    test,
    testtest
};