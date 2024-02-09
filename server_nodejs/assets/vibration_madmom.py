import madmom

audio_file = './musics/Love Shot.mp3'

# DBN 비트 추적 프로세서 생성
proc1 = madmom.features.beats.DBNBeatTrackingProcessor(fps=100)
# tempo_estimator = madmom.features.tempo.TempoEstimationProcessor(fps=100)
# proc1 = madmom.features.beats.BeatTrackingProcessor(fps=100)


# RNN 비트 프로세서를 사용하여 활성화 함수 생성
act = madmom.features.beats.RNNBeatProcessor()(audio_file)

beats = proc1(act)

# # 비트 추적
# beats = madmom.features.beats.BeatTrackingProcessor(fps=100)(act)

# beat_times = np.array(beats)

# # # 초로 변환 및 지수 표기법 제거
# beat_times_seconds = ["{:.2f}".format(time) for time in beat_times]


# # 결과 출력
# print(beat_times_seconds)

# [beat 시간, downbeat ( 강박 ) 확률]
proc2 = madmom.features.downbeats.RNNBarProcessor()
downbeat_prob = proc2((audio_file, beats))
rounded = []

for i in range(len(downbeat_prob) - 1) :
    rounded += [["{:.2f}".format(num) for num in downbeat_prob[i]]]

for i in range(len(rounded)) :
    print(rounded[i], end="")
    print(',')
