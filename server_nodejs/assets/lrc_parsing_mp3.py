import glob
import requests
from bs4 import BeautifulSoup
import os
import urllib
import json
from mutagen.easyid3 import EasyID3
from add_album_cover import get_album_covers

FILE_LIST = []
available_file = []
available_artist = []
available_first_artist = []
available_second_artist = []
available_album = []
available_title = []
track_artistid = []
track_albumid = []
track_trackid = []
TIME = []
LYRICS = []
mm = []
ss = []
xx = []
success = 0
fail = 0
lrc_directory = './assets/lyrics'
lrc_filename = ''
lrc_filepath = ''

music_directory = './assets/musics'
music_filepath = []

coverimage_directory = './assets/coverimages'

# 벅스 뮤직 lrc file 크롤러 사용
# 실행 방법 : terminal에 python3 lrc_parsing_mp3.py 실행


def track_clear():
    track_albumid.clear()
    track_artistid.clear()
    track_trackid.clear()


def time_clear():
    xx.clear()
    ss.clear()
    mm.clear()
    LYRICS.clear()
    TIME.clear()


def lrc_maker():
    global success
    global data
    global i
    global available_file
    global lrc_filepath
    
    TEXT = data['result']['lyrics']
    TEXT = TEXT.replace("＃", "\n")
    x = TEXT.count("|")
    with open(lrc_filepath, 'w', encoding='UTF8') as file:  # 덮어씌우기
        file.write(TEXT)
    del TEXT
    TEXT = []
    with open(lrc_filepath, 'r', encoding='UTF8') as file:  # 한줄씩 읽어오기
        for j in range(0, x):
            TEXT.append(file.readline().rstrip())
    for j in range(0, x):  # 시간과 가사 구분하기
        TIME.append(float(TEXT[j][:TEXT[j].rfind("|")]))
        LYRICS.append(TEXT[j][TEXT[j].rfind("|") + 1:])
    for j in range(0, x):
        xx.append(str(round(TIME[j] - int(TIME[j]), 2)))
        if int(TIME[j]) % 60 < 10:
            ss.append("0" + str(int(TIME[j]) % 60))
        else:
            ss.append(str(int(TIME[j]) % 60))
        if int(TIME[j]) // 60 < 10:
            mm.append("0" + str(int(TIME[j]) // 60))
        else:
            mm.append(str(int(TIME[j]) // 60))
    with open(lrc_filepath, 'w', encoding='UTF8') as file:  # 초기화
        file.write('')
    for j in range(0, x):
        with open(lrc_filepath, 'a', encoding='UTF8') as file:  # 최종
            if j != x:
                file.write("[" + mm[j] + ":" + ss[j] + xx[j][1:] + "]" + LYRICS[j] + "\n")
            else:
                file.write("[" + mm[j] + ":" + ss[j] + xx[j][1:] + "]" + LYRICS[j])
    time_clear()
    track_clear()
    del TEXT
    print("%s. %s의 lrc파일을 가져왔습니다." % (i, available_file[i]))
    success += 1
    return success


def lrc_delete():
    global fail
    global i
    global available_file
    global lrc_filepath
    fail += 1
    track_clear()
    os.remove(lrc_filepath)
    print("%s 은(는) 싱크가사를 지원하지 않습니다." % available_file[i])
    return fail

for file in glob.glob("./assets/musics/*.mp3"):  # mp3 파일 개수 파악
    file = file[file.rfind('/')+1:]
    FILE_LIST.append(file)

if len(FILE_LIST) != 0:  # mp3 곡이 있는지 확인하기
    for i in range(0, len(FILE_LIST)):
        music_filepath.append(os.path.join(music_directory, FILE_LIST[i]))
        print(EasyID3("%s" % music_filepath[i]))
        mp3_info = EasyID3("%s" % music_filepath[i])
        if 'album' in mp3_info.keys()  and 'artist' in mp3_info.keys()  and 'title' in mp3_info.keys() :  # 아티스트, 앨범, 타이틀 태그 있는지 확인
            available_file.append(FILE_LIST[i])
            available_album.append(mp3_info['album'][0])
            available_title.append(mp3_info['title'][0])
            available_artist.append(mp3_info['artist'][0])
            if "," in mp3_info['artist'][0]:
                available_first_artist.append(mp3_info['artist'][0][:mp3_info['artist'][0].find(",")])
                available_second_artist.append(mp3_info['artist'][0][mp3_info['artist'][0].rfind(",")+1:])
            else:
                available_first_artist.append(mp3_info['artist'][0])
                available_second_artist.append('')
        else:
            print("%s의 태그가 없습니다." % FILE_LIST[i])
            fail += 1

    for i in range(0, len(available_file)):
        lrc_filename = '%s.lrc' % available_file[i].replace(".mp3", "")
        lrc_filepath = os.path.join(lrc_directory, lrc_filename)
        
        if available_second_artist[i] == '':
            soup_artist = BeautifulSoup(requests.get('https://music.bugs.co.kr/search/artist?q=%s' % available_artist[i]).text, 'html.parser')
        else:
            soup_first_artist = BeautifulSoup(requests.get('https://music.bugs.co.kr/search/artist?q=%s' % available_first_artist[i]).text,'html.parser')
            soup_second_artist = BeautifulSoup(requests.get('https://music.bugs.co.kr/search/artist?q=%s' % available_second_artist[i]).text,'html.parser')
        soup_album = BeautifulSoup(requests.get('https://music.bugs.co.kr/search/album?q=%s %s' % (available_artist[i], available_album[i])).text,'html.parser')
        soup_track = BeautifulSoup(requests.get('https://music.bugs.co.kr/search/track?q=%s %s' % (available_artist[i], available_title[i])).text,'html.parser')

        if available_second_artist[i] == '':
            if soup_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):
                for id in soup_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):  # 아티스트 결과
                    artist_artistid = id['href'][32:-25]
            else:
                print("%s에 대한 검색 결과가 없습니다." % available_file[i])
                fail += 1
                continue
        else:
            if soup_first_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):
                for id in soup_first_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):  # 아티스트 결과
                    artist_first_artistid = id['href'][32:-25]
            else:
                print("%s에 대한 검색 결과가 없습니다." % available_file[i])
                fail += 1
                continue
            if soup_second_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):
                for id in soup_second_artist.select('#container > section > div > ul > li:nth-of-type(1) > figure > figcaption > a.artistTitle'):  # 아티스트 결과
                    artist_second_artistid = id['href'][32:-25]
            else:
                print("%s에 대한 검색 결과가 없습니다." % available_file[i])
                fail += 1
                continue

        if soup_album.select('#container > section > div > ul > li:nth-of-type(1) > figure'):
            for id in soup_album.select('#container > section > div > ul > li:nth-of-type(1) > figure'):  # 앨범검색 결과
                album_artistid = id['artistid']
                album_albumid = id['albumid']
        else:
            print("%s에 대한 검색 결과가 없습니다."%available_file[i])
            fail += 1
            continue

        for id in soup_track.find_all("tr"):
            if id.get('artistid'):
                track_artistid.append(id.get('artistid'))
            if id.get('albumid'):
                track_albumid.append(id.get('albumid'))
            if id.get('trackid'):
                track_trackid.append(id.get('trackid'))

        if available_second_artist[i] == '':
            if artist_artistid == album_artistid and artist_artistid in track_artistid:
                n = track_artistid.index(artist_artistid)
                urllib.request.urlretrieve('http://api.bugs.co.kr/3/tracks/%s/lyrics?&api_key=b2de0fbe3380408bace96a5d1a76f800' % track_trackid[n],lrc_filepath)
                with open(lrc_filepath, encoding='UTF8') as json_file:
                    data = json.load(json_file)
                if data['result'] is not None:  # 싱크 가사 있을 때,
                    if "|" in data['result']['lyrics']:  # time이 있을 때,
                        lrc_maker()
                        get_album_covers(music_filepath[i])
                    else:  # time이 없을 때,
                        lrc_delete()
                else:  # 싱크 가사 없을 때,
                    lrc_delete()
            else:
                print("%s에 대한 검색 결과가 없습니다." % available_file[i])
                fail += 1
                track_clear()
        else:
            if artist_first_artistid == album_artistid and artist_second_artistid in track_artistid:
                n = track_artistid.index(artist_second_artistid)
                urllib.request.urlretrieve('http://api.bugs.co.kr/3/tracks/%s/lyrics?&api_key=b2de0fbe3380408bace96a5d1a76f800' % track_trackid[n],lrc_filepath)
                with open(lrc_filepath, encoding='UTF8') as json_file:
                    data = json.load(json_file)
                if data['result'] is not None:  # 싱크 가사 있을 때,
                    if "|" in data['result']['lyrics']:  # time이 있을 때,
                        lrc_maker()
                        get_album_covers(music_filepath[i])
                    else:  # time이 없을 때,
                        lrc_delete()
                else:  # 싱크 가사 없을 때,
                    lrc_delete()
            elif artist_first_artistid == album_artistid and artist_first_artistid in track_artistid:
                n = track_artistid.index(artist_first_artistid)
                urllib.request.urlretrieve('http://api.bugs.co.kr/3/tracks/%s/lyrics?&api_key=b2de0fbe3380408bace96a5d1a76f800' % track_trackid[n],lrc_filepath)
                with open(lrc_filepath, encoding='UTF8') as json_file:
                    data = json.load(json_file)
                if data['result'] is not None:  # 싱크 가사 있을 때,
                    if "|" in data['result']['lyrics']:  # time이 있을 때,
                        lrc_maker()
                        get_album_covers(music_filepath[i])
                    else:  # time이 없을 때,
                        lrc_delete()
                else:  # 싱크 가사 없을 때,
                    lrc_delete()
            else:
                print("%s에 대한 검색 결과가 없습니다." % available_file[i])
                fail += 1
                track_clear()

    if i == len(available_file)-1:
        print("============완료============")
        print("가져온 lrc파일 수 : %s 개"% success)
        print("실패한 곡 수 : %s 개"% fail)
        print("============================")

else:  # flac파일이 없을 때
    print("==========ERROR===========")
    print("mp3 파일을 찾을 수 없습니다.")
    print("==========================")
