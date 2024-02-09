const { response } = require("express");
const baseResponseStatus = require("../../../config/baseResponseStatus");

async function increaseMusicId(db){
    let musicId = 0;
    const result = await db.ref('last_music_id').transaction((currentCounter) => {
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

async function postInitializeStore(db, postInitializeStoreParams){
    const musicId = await increaseMusicId(db) + '';
    const ref = db.ref('TestMusic/' + musicId);

    await ref.set(
        {
            title: postInitializeStoreParams[0],
            encoded_title: postInitializeStoreParams[1],
            artist: postInitializeStoreParams[2],
            lyrics: postInitializeStoreParams[3]
        }
    );

}

module.exports ={
    postInitializeStore
};