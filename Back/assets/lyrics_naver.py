import os
import requests 
from bs4 import BeautifulSoup

def get_lyrics_naver(artist, title, split_title):
    artist_and_title = artist + ' ' + split_title
    # print(artist_and_title)

    txt_path = './assets/uploads/lyrics/' + title + '.txt'

    # 네이버에서 해당 제목 & 가수의 가사를 검색하기 위한 URL 생성
    search_query = f"{artist_and_title} 가사"
    search_url = f"https://search.naver.com/search.naver?query={search_query}"
    
    # User-Agent 설정
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"}

    # 검색 결과 요청
    res = requests.get(search_url, headers=headers)
    res.raise_for_status()


    # 검색 결과 페이지의 HTML을 파싱
    soup = BeautifulSoup(res.text, "lxml")


    # 가사가 있는 요소 찾기
    lyrics_link = soup.select_one(".intro_box p.text")

    lyrics_texts = 0


    # 크롬 개발자 도구에서 Elements 돌면서 찾을 수 있다 tag
    # 네이버에 가사 검색했을 때 나올 수 있는 Form이 두가지 있는데 그 중 두번째에서 검색
    if lyrics_link is None:
        lyrics_link = soup.select_one(".lyrics_txt")
        if lyrics_link is None:
            # 찾을 수 없다는 뜻. 정식 음원이 x
            return -1
        lyrics_texts = [element.get_text() for element in lyrics_link]
    
    else:
        p_text = lyrics_link.decode_contents().replace('<br/> ', '\n')
        lyrics_texts = p_text.split('\n')

    with open(txt_path, 'w', encoding='utf-8') as file:
        for line in lyrics_texts:
            file.write(line + '\n')
    
    return title + '.txt'

