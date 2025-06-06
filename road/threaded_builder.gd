extends Node

var thread: Thread

func _ready():
	thread = Thread.new()
	# Our method needs an argument, so we pass it using bind().
	thread.start(_thread_work)


func _thread_work():
	# Cannot use preload here
	var road = load("res://road/road.tscn").instantiate()
	road.build()
	# call_deferred() tells the main thread to call a method during idle time.
	# Our method operates on nodes currently in the tree, so it isn't safe to
	# call directly from another thread.
	_thread_done.call_deferred()
	return road


func _thread_done():
	# Wait for the thread to complete, and get the returned value.
	var road = thread.wait_to_finish()
	var start_time = Time.get_ticks_msec()
	get_parent().add_child(road)
	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Time taken to add: %d milliseconds" % elapsed_time)
	queue_free()
	# We're done with the thread now, so we can free it.
	thread = null # Threads are reference counted, so this is how we free them.


func _exit_tree():
	# You should always wait for a thread to finish before letting it get freed!
	# It might not clean up correctly if you don't.
	if is_instance_valid(thread) and thread.is_started():
		thread.wait_to_finish()
		thread = null
