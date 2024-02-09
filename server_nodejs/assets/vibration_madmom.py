import madmom
import sys
import json

audio_file = sys.argv[1]

# DBN 비트 추적 프로세서 생성
proc1 = madmom.features.beats.DBNBeatTrackingProcessor(fps=100)
act = madmom.features.beats.RNNBeatProcessor()(audio_file)
beats = proc1(act)

# RNNBarProcessor로 downbeat 확률 계산
proc2 = madmom.features.downbeats.RNNBarProcessor()
downbeat_prob = proc2((audio_file, beats))
rounded = []

for i in range(len(downbeat_prob) - 1):
    rounded += [["{:.2f}".format(num) for num in downbeat_prob[i]]]

# 결과를 stdout으로 출력
for i in range(len(rounded)):
    print(json.dumps(rounded[i]))

# 결과 값을 종료코드로 전달
sys.exit(0)
