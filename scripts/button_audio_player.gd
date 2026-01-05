class_name ButtonAudioPlayer extends AudioStreamPlayer

func play_normal():
	pitch_scale = 1
	play()
	
func play_wrong():
	pitch_scale = 0.3
	play()
