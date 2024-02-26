# Music Palette
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/17644f0d-488a-4604-a863-19bb43746800" width="300" height="300">

Music Palette - GDSC Solution Challenge 2024


## Table of Contents
- [Member](#member)
- [About Our Solution](#about-our-solution)
- [Target SDGs](#target-sdgs)
- [Technical Components](#technical-components)
- [Google Form Survey](#google-form-survey)
- [App Demo](#app-demo)
    - [Main Page](#main-page)
    - [Vibrations and Image created based on lyrics and melody](#vibrations-and-image-created-based-on-lyrics-and-melody)
    - [Real-time lyrics](#real-time-lyrics)
    - [My Favorites](#my-favorites)
    - [View All Songs](#view-all-songs)
- [Download APK](#download-apk)

## Member
|WOOSEO JUNG|YEONJIN JOO|SOYOUNG PARK|DOHYEOK KWON|
|:---:|:---:|:---:|:--:|
|- Frontend|- Backend|- Backend|- AI|

## About Our Solution
Music Palette offers a multisensory experience by providing music not only audibly but also visually and tactilely, especially for those who have hearing impairments. It generates vibrations in sync with the music beats, displays images created based on lyrics and melody, and also provides features like real-time lyrics and playlist creation.

## Target SDGs
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/eb7770ce-d508-4288-97fd-a1427245ac65" width="150" height="150">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/039c7e91-8981-451a-ad15-6e25d85bab15" width="150" height="150">


## Technical Components
**✔️Frond-end**<br>
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=black">

**✔️SERVER**<br>
<img src="https://img.shields.io/badge/Google Cloud-4285F4?style=for-the-badge&logo=Google Cloud&logoColor=green">

**✔️Back-end**<br>
<img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=Express&logoColor=white"><img src="https://img.shields.io/badge/JSS-F7DF1E?style=for-the-badge&logo=JSS&logoColor=black"><img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=Node.js&logoColor=white"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"><img src="https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=NGINX&logoColor=white">

**✔️ML/DL**<br>
<img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=Node.js&logoColor=white"><img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=Flask&logoColor=white"><img src="https://img.shields.io/badge/Google Gemini-8E75B2?style=for-the-badge&logo=Google Gemini&logoColor=black">

## Google Form Survey
Before initiating the development of Music Palette, we conducted a Google Form survey targeting individuals with hearing impairments. Based on the information gathered from the survey and various online sources related to individuals with hearing impairments, we identified the needs of the deaf community. With this understanding, we finalized and developed the core features of the Music Palette app.
### 1. How do you typically experience music?
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/17047cbe-390a-4a0a-acfd-ef7e5eeba4a6" width="800" height="350">

<p>$\bf{\color{#0000FF}Blue}$ : I have residual hearing, allowing me to listen to music.</p>
<p>$\bf{\color{#FF0000}Red}$ : I use hearing aids, in-ear devices, etc., to enjoy music.</p>
<p>$\bf{\color{#FFC300}Yellow}$ : I experience music through visual and tactile sensations, such as attending live performances of artists through sign language interpretation.</p>
<p>$\bf{\color{#008000}Green}$ : I don't engage much in enjoying music.</p>

### 1-1. If you selected "I don't really engage in or enjoy music" in the previous question, what is the reason for that?
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/ce049884-1141-4722-8c48-bd0b8e0716b8" width="800" height="350">

<p>$\bf{\color{#0000FF}Blue}$ : I desire to enjoy music, but the means to appreciate it are not widespread.</p>
<p>$\bf{\color{#FF0000}Red}$ : I want to listen to music, but I find that the current methods do not convey music vividly, or I don't feel a strong interest in them.</p>
<p>$\bf{\color{#FFC300}Yellow}$ : I have little interest in the genre of music.</p>

Many individuals with hearing impairment voted for Blue despite not choosing "I don't really engage in or enjoy music" in the previous question. This vote reflects the desire of people with hearing impairment for music appreciation. It also indicates that there is a lack of widespread means to facilitate their access to and enjoyment of music.

### 2. Have you ever experienced enjoying music through vibrations?
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/1bfcfee1-1fe3-4e33-9fd8-0af39ea6b09e" width="800" height="350">

<p>$\bf{\color{#0000FF}Blue}$ : Yes</p>
<p>$\bf{\color{#FF0000}Red}$ : No</p>

8 out of 12 have experienced enjoying music through vibrations which supports the idea that experience music through vibrations is common for individuals with hearing impairment.

### 3. Could you gather sufficient information about the music from the existing album cover? If not, what was the reason?
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/dbc48c3e-f2d3-449f-9fd8-3dc348168e1e" width="800" height="350">

<p>$\bf{\color{#0000FF}Blue}$ : because the album cover was too abstract</p>
<p>$\bf{\color{#FF0000}Red}$ : because it featured an unrelated picture of the artist</p>
<p>$\bf{\color{#FFC300}Yellow}$ : can get sufficient information</p>

9 out of 12 voted that they cannot gather sufficient information about the music from the existing album cover which emphasizes the need for an image that effectively conveys music information.

### 4. If you were to represent music through a picture, what information would you prefer to be most prominently conveyed? (Multiple choices allowed)
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/5c047bad-535c-46b5-a14a-10af53ab67ca" width="800" height="350">

- The atmosphere of the music
- The story of the lyrics
- The emotion of the music

### 5. Please choose the features you consider essential from the following options. (Multiple selections allowed)
---
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/6c0fe4a9-2f43-4d85-b444-69d87b63703b" width="800" height="350">

- Friend adding & music sharing feature
- Image download generated based on the melody and lyrics of the music
- Playlist ( My Favorites )  
- Vibration generation based on the beat of the music
- Real-time amplitude graph of the music

1st place, with 8 votes, goes to 'Image download generated based on the melody and lyrics of the music.' 2nd place, with 7 votes, is 'Vibration generation based on the beat of the music.' And 3rd place, with 6 votes, is the 'Playlist ( My Favorites )' feature. We developed all these 3 features in Music Palette.




## App Demo
### Main Page
---
<div align="center">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/569812e7-ca52-4069-9237-41af90ecc87e" width="350" height="650">
</div>

When user first install Music Palette and log in, user can see 10 recommended songs.

### Vibrations and Image created based on lyrics and melody
---
<div align="center">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/a0f9b40c-15bb-4829-9f67-807a9f733235" width="350" height="650">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/378a9d12-203b-4dd4-ba0d-6f9dd06d1f79" width="350" height="650">
</div>

If user chooses and plays music, user can feel vibrations synced with music beat. Also, user can see image created based on lyrics and melody. If user touches the image, user can see image explanations which help user gain deeper insights into the generated images, ultimately aiding in a better understanding of the music. User can download generated image by clicking 'Download Generated Image' ('생성된 이미지 다운로드 받기' in Korean).

### Real-time lyrics
---
<div align="center">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/0bfae1ca-5966-4e1d-b93f-2d0a82d95adb" width="350" height="650">
</div>

User can see real-time lyrics, the lyrics sync with the audio in real time. The currently playing lyric is displayed prominently in large, bold text. We used crawling to get lrc files, which contain the lyrics and timing information for the songs associated with the file.


### My Favorites
---
<div align="center">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/56e1594f-32e3-4b63-bc13-873362f9cf31" width="350" height="650">
</div>

User can easily add their favorite songs by clicking heart and view them in 'My Favorites' ('내가 찜한 노래' in Korean).

### View All Songs
---
<div align="center">
<img src ="https://github.com/sso0711/2024-SolutionChallenge-MusicPalette/assets/102257328/e1ba4548-7ce3-4053-902b-7cb257c3d88b" width="350" height="650">
</div>

User can see all music by clicking 'All Music' ('전체 노래' in Korean).


## Download APK
https://drive.google.com/file/d/16Qyiy5hoPo5wqd8UtW4INysbUPoHWXzO/view?usp=share_link

Please click link to download apk file.

