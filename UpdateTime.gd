extends Panel

export (Texture) var start_button_icon
export (Texture) var pause_button_icon
export (Texture) var resume_button_icon

var is_timed_out = false
var input_mode = false
var initial_hours = 0
var initial_minutes = 25
var initial_seconds = 0
var remaining_hours
var remaining_minutes
var remaining_seconds 
var currently_displaying_time = [[initial_hours / 10, initial_hours % 10], [initial_minutes / 10, initial_minutes % 10], [initial_seconds / 10, initial_seconds % 10]] 

signal timeout

func _ready():
	set_remaining_to_initial()
	format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)

func _process(delta):
	if input_mode:
		if Input.is_action_just_pressed("num0"):
			push_array_items_left(0)
		if Input.is_action_just_pressed("num1"):
			push_array_items_left(1)
		if Input.is_action_just_pressed("num2"):
			push_array_items_left(2)
		if Input.is_action_just_pressed("num3"):
			push_array_items_left(3)
		if Input.is_action_just_pressed("num4"):
			push_array_items_left(4)
		if Input.is_action_just_pressed("num5"):
			push_array_items_left(5)
		if Input.is_action_just_pressed("num6"):
			push_array_items_left(6)
		if Input.is_action_just_pressed("num7"):
			push_array_items_left(7)
		if Input.is_action_just_pressed("num8"):
			push_array_items_left(8)
		if Input.is_action_just_pressed("num9"):
			push_array_items_left(9)

func _input(event):
	if is_timed_out:
		return
		
	if Input.is_action_just_pressed("nums"):
		if !input_mode and ($SecondTimer.paused or $SecondTimer.is_stopped()):
			switch_to_input_mode()
	
	if Input.is_action_just_pressed("cancel_input"):
		switch_to_normal_mode(false)

#	if input_mode:
#		if Input.is_action_just_pressed("start_timer"):
#			switch_to_normal_mode(true)

func _on_SecondTimer_timeout():
	remaining_seconds -= 1
	
	if remaining_seconds == 0:
		if remaining_minutes == 0:
			if remaining_hours == 0:
				format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)
				emit_signal("timeout")
				$SecondTimer.stop()
				return
			else:
				format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)
				remaining_minutes = 59
				remaining_hours -= 1
		else:
			format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)
			remaining_minutes -= 1
		
		remaining_seconds = 60
		
	elif remaining_seconds == -1:
		if remaining_minutes == 0:
			if remaining_hours != 0:
				remaining_hours -= 1
				remaining_minutes = 59
		else:
			remaining_minutes -= 1
			
		remaining_seconds = 59
		
		format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)
	else:
		format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)

func _on_StartButton_pressed():
	print("LOL")
	if is_timed_out:
		return
		
	$Click.play()
	if input_mode:
		switch_to_normal_mode(true)
	
	if initial_hours == 0 and initial_minutes == 0 and initial_seconds == 0:
		return
	
	if $SecondTimer.is_stopped():
		$SecondTimer.start()
		$SecondTimer.paused = false
		#$StartButton.text = "Pause"
		$StartButton.icon = pause_button_icon
		
	else:
		$SecondTimer.paused = !$SecondTimer.paused
		if $SecondTimer.paused:
			#$StartButton.text = "Resume"
			$StartButton.icon = resume_button_icon
		else:
			#$StartButton.text = "Pause"
			$StartButton.icon = pause_button_icon

func _on_ResetButton_pressed():
	is_timed_out = false
	$TimeOutSound.stop()
	
	if input_mode:
		input_mode = false
		
	$Click.play()
	$SecondTimer.stop()
	#$StartButton.text = "Start"
	$StartButton.icon = start_button_icon
	
	remaining_hours = initial_hours
	remaining_minutes = initial_minutes
	remaining_seconds = initial_seconds
	
	format_and_set_time(initial_hours, initial_minutes, initial_seconds)

func _on_Background_timeout():
	is_timed_out = true
	$TimeOutSound.play()

func format_and_set_time(var hours, var minutes, var seconds):
	var hour_string = str(hours) + ":"
	var minute_string = str(minutes) + ":"
	var second_string = str(seconds)
	
	if initial_hours == 0:
		hour_string = ""
		if initial_minutes == 0:
			minute_string = ""
		else:
			if seconds < 10:
				second_string = "0" + second_string
			
			if remaining_minutes < 10:
				if initial_minutes >= 10:
					minute_string = "0" + minute_string
	else:
		if hours < 10:
			if initial_hours >= 10:
				hour_string = "0" + hour_string
				
		if minutes < 10:
			minute_string = "0" + minute_string
		
		if seconds < 10:
			second_string = "0" + second_string
			
	$Label.text = hour_string + minute_string + second_string
	
func set_label_to_input_array(var input_times_array):
	$Label.text = str(input_times_array[0][0]) + str(input_times_array[0][1]) + ":" + str(input_times_array[1][0]) + str(input_times_array[1][1]) + ":" + str(input_times_array[2][0]) + str(input_times_array[2][1]) 
	
func switch_to_input_mode():
	input_mode = true
	currently_displaying_time = [[remaining_hours / 10, remaining_hours % 10], [remaining_minutes / 10, remaining_minutes % 10], [remaining_seconds / 10, remaining_seconds % 10]]
	set_label_to_input_array(currently_displaying_time)

func switch_to_normal_mode(var accept_time):
	input_mode = false
	if accept_time:
		initial_hours = currently_displaying_time[0][0] * 10 + currently_displaying_time[0][1]
		initial_minutes = currently_displaying_time[1][0] * 10 + currently_displaying_time[1][1]
		initial_seconds = currently_displaying_time[2][0] * 10 + currently_displaying_time[2][1]
		set_remaining_to_initial()
		format_and_set_time(initial_hours, initial_minutes, initial_seconds)
	else:
		format_and_set_time(remaining_hours, remaining_minutes, remaining_seconds)
	
func push_array_items_left(var append_item):
	currently_displaying_time[0][0] = currently_displaying_time[0][1]
	currently_displaying_time[0][1] = currently_displaying_time[1][0]
	currently_displaying_time[1][0] = currently_displaying_time[1][1]
	currently_displaying_time[1][1] = currently_displaying_time[2][0]
	currently_displaying_time[2][0] = currently_displaying_time[2][1]
	currently_displaying_time[2][1] = append_item

	set_label_to_input_array(currently_displaying_time)
	
func set_remaining_to_initial():
	remaining_hours = initial_hours
	remaining_minutes = initial_minutes
	remaining_seconds = initial_seconds
