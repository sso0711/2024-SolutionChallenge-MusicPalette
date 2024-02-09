const { response } = require("express");
const baseResponseStatus = require("../../../config/baseResponseStatus");

// set musicId increase by 1
async function increaseMusicId(db){
    let musicId = 0;
    await db.ref('last_music_id').transaction((currentCounter) => {
        if (currentCounter === null) {
          // music_id가 아직 없으면 1로 초기화
          musicId = 1;
          return 1;
        }
        // music_id가 이미 있으면 +1
        musicId = currentCounter + 1;
        return musicId;
    });
    console.log(musicId);
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
            "artist": data.artist
        });
    }
    
    return JSON.stringify(musicList, null, 4);
}

async function getMusicInfo(db, musicId){
    const ref = db.ref('Musics/' +(musicId +''));
    const data = (await ref.once('value')).val();

    const musicInfo = {
        "lyrics": JSON.parse(data.lyrics),
        "vibrations": JSON.parse(data.vibrations)
    };

    return JSON.stringify(musicInfo, null, 2);
}

async function getUserLikes(db, userId){
    const ref = db.ref('Users/'+ userId);
    const data = (await ref.once('value')).val();
    
    if(data == null){
        const musicNum = (await db.ref('last_music_id').once('value')).val();
        data = new Array(musicNum).fill(false);
        await ref.set({
            "likes": JSON.stringify(data)
        });
    }
    return data;
}

module.exports ={
    postInitializeMade,
    postInitializeStore,
    getMusicList,
    getMusicInfo,
    getUserLikes
};