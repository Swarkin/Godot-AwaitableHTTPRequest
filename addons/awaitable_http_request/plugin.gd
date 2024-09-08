@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("AwaitableHTTPRequest", "HTTPRequest", preload("awaitable_http_request.gd"), preload("icon.png"))
	add_custom_type("HTTPResult", "RefCounted", preload("http_result.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("AwaitableHTTPRequest")
	remove_custom_type("HTTPResult")
