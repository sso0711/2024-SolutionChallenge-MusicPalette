import librosa
import numpy as np
import sys
import json

audio_file = sys.argv[1]

# 음악 파일 로드
y, sr = librosa.load(audio_file)

# 비트 추출
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)

times = librosa.frames_to_time(beats, sr = sr)
# times = np.round(times, decimals = 2)

compare = len(times) - 1

# 평균 비트 간의 거리
average = (times[compare] - times[0]) / compare
average = int(average * 1000)

print(json.dumps(average))

sys.exit(0)