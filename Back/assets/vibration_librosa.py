import librosa
import numpy as np
import sys
import json
import madmom

audio_file = sys.argv[1]

# audio_file = './assets/musics/Animals.mp3'

# 음악 파일 로드
y, sr = librosa.load(audio_file)

# 비트 추출
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)

times = librosa.frames_to_time(beats, sr = sr)

# RNNBarProcessor로 downbeat 확률 계산
proc = madmom.features.downbeats.RNNBarProcessor()
downbeat_prob = proc((audio_file, times))
rounded = []

for i in range(len(downbeat_prob) - 1):
    rounded += [["{:.2f}".format(num) for num in downbeat_prob[i]]]

# print(rounded)


# # 결과를 stdout으로 출력
for i in range(len(rounded)):
    print(json.dumps(rounded[i]))

# # 결과 값을 종료코드로 전달
sys.exit(0)

