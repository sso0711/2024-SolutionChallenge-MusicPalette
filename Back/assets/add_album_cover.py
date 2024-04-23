import os
import eyed3

coverimage_directory = './assets/uploads/coverimages'

# mp3 file에서 APIC 태그 이용해 album cover 사진 가져오는 코드
def get_album_covers(filepath, filename):
    global coverimage_directory
    try:
        audiofile = eyed3.load(filepath)
        if audiofile.tag and audiofile.tag.images :
            image_frame = audiofile.tag.images[0]
            image_data = image_frame.image_data
            filename = filename + '.jpg'
            coverimage_filepath = os.path.join(coverimage_directory, filename)
            with open(coverimage_filepath, 'wb') as f:
                f.write(image_data)

            return("앨범 커버를 성공적으로 저장했습니다.")

        else:
            return("앨범 커버를 찾을 수 없습니다.")

    except Exception as e:
        return(f"오류 발생: {e}")