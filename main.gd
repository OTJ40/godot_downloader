extends Control

const godot_url = 'https://downloads.tuxfamily.org/godotengine/'
var current_os = OS.get_name()
var download_link = ''
var file_name = ''
var user_current_version = '0'
var current_dir = ''

func _ready() -> void:
	match current_os:
		'Windows':
			$OSButton.select(0)
			_disable_archi(false)
		'macOS':
			$OSButton.select(1)
			_disable_archi(true)
		'Linux':
			$OSButton.select(2)
			_disable_archi(false)
	
	var d = DirAccess.open(OS.get_user_data_dir())
	if not d.dir_exists(OS.get_user_data_dir() + '/downloads'):
		d.make_dir(OS.get_user_data_dir() + '/downloads')
	var dir_list = list_files_in_directory(OS.get_user_data_dir() + '/downloads', false)
	if dir_list.size() > 0:
		user_current_version = dir_list[-1]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	http_request.request(godot_url)
	
	$ProgressBar.value = 0
	await http_request.request_completed
	update_download_link()


func _process(_delta):
	var body_size = 0
	var current = 0
	if $HTTPRequest.get_body_size() != -1:
		body_size = $HTTPRequest.get_body_size()
		current = $HTTPRequest.get_downloaded_bytes()
		$ProgressBar.value = current * 100 / body_size


func _on_download_button_pressed() -> void:
	_update_file_name()
	
	var file_path = OS.get_user_data_dir() + "/downloads/" + file_name

	print("[+] Starting download")
	disable_menu()
	$DownloadButton.text = "Downloading..."
	$ProgressBar.show_percentage = true

	# Downloading file
	$HTTPRequest.set_download_file(file_path)
	$HTTPRequest.request(download_link)


func _http_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var text = innerHTML("tbody",body.get_string_from_utf8(), "error")
	var text_array = text.split('</tr>')
	var current_index = 0
	for idx in text_array.size()-1:
		var version = text_array[idx].lstrip('\n<tr><td class=\"n\"><a href=').split('/',true,1)[0]
		if user_current_version == version:
			current_index = idx
		if idx == text_array.size()-1-6:
			current_dir = version
	if current_index < text_array.size()-1-6:
		$DownloadButton.text = 'Download'
	else:
		disable_menu()
		$DownloadButton.text = 'Your Godot is Fresh'
		OS.shell_open(OS.get_user_data_dir() + '/downloads/' + current_dir)


func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	print("[+] Download completed ", result, ", ", response_code)
	if current_os == "Windows":
		# Open the dir
		OS.shell_open(OS.get_user_data_dir() + '/downloads/' + current_dir)
	elif current_os == "macOS":
		print('Todo on macOS')
	else:
		print('Todo on Linux')
	$DownloadButton.text = "Download completed"


func update_download_link():
	download_link = godot_url + current_dir + '/Godot_v' + current_dir
	if $OSButton.selected == 0:
		download_link += '-stable_win64.exe.zip'
		if $ArchiButton.selected == 1:
			download_link += '-stable_win32.exe.zip'
	elif $OSButton.selected == 1:
		download_link += '-stable_macos.universal.zip'
	else:
		download_link += '-stable_linux.x86_64.zip'
		if $ArchiButton.selected == 1:
			download_link += '-stable_linux.x86_32.zip'
	
	print('[+] Updating download link: ', download_link)


func list_files_in_directory(path: String, collect_all: bool):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != '':
			if dir.current_is_dir():
				files.append(file)
			else:
				if collect_all:
					files.append(file)
			file = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	dir.list_dir_end()
	
	return files


func innerHTML(tag, html, default=""):
	var regex = RegEx.new()
	regex.compile("<" + tag + ">(.|\n)*?</" + tag + ">")
	var result = regex.search(html)
	if result:
		return result.get_string().replace("<"+tag+">",'').replace("</"+tag+">",'')
	else:
		return default


func disable_menu():
	$DownloadButton.disabled = true
	$OSButton.disabled = true
	$ArchiButton.disabled = true


func _disable_archi(bull):
	$ArchiButton.disabled = bull
	$ArchiButton.select(0)


func _on_about_button_pressed() -> void:
	$AboutDialog.popup_centered()


func _on_os_button_item_selected(index: int) -> void:
	match index:
		0,2:
			_disable_archi(false)
		1:
			_disable_archi(true)
			
	update_download_link()


func _on_archi_button_item_selected(_index: int) -> void:
	update_download_link()


func _update_file_name():
	var dir = DirAccess.open('user://downloads')
	if not dir.dir_exists(current_dir):
		dir.make_dir(current_dir)
	file_name = download_link.replace(godot_url,'')
	print(file_name)


func _on_about_label_meta_clicked(meta) -> void:
	OS.shell_open(meta)

