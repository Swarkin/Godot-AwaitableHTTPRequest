class_name AwaitableHTTPRequest
extends HTTPRequest
## [img width=64]res://addons/awaitable_http_request/icon.png[/img]   [url=https://github.com/Swarkin/Godot-AwaitableHTTPRequest]AwaitableHTTPRequest[/url] 2.2.0 by Swarkin & [url=https://github.com/Swarkin/Godot-AwaitableHTTPRequest/graphs/contributors]contributors[/url].
# View the formatted documentation in Godot by pressing F1 and typing "AwaitableHTTPRequest"!

signal request_finished     ## Emits once the current request finishes, right after [member is_requesting] is set to false.
var is_requesting := false  ## Whether the node is busy performing a request. This variable is read-only.

## Performs an awaitable HTTP request.[br]
## Take a look at the [code]examples.tscn[/code] scene in the addon directory for inspiration![br]
## [br]
## [b]Note:[/b] Header names will be in lowercase, as some web servers prefer this approach and them being case-insensitive as per specification. Therefore, it is good practice to not rely on capitalization.
## [br]
## Here is an example with minimal error-handling:
## [codeblock]
## extends AwaitableHTTPRequest
##
## func _ready() -> void:
##     var resp := await async_request("https://api.github.com/users/swarkin")
##     if resp.success() and resp.status_ok():
##         print(resp.status)                   # 200
##         print(resp.headers["content-type"])  # application/json
##
##         var json := resp.body_as_json()
##         print(json["login"])                 # Swarkin
## [/codeblock]
func async_request(url: String, custom_headers := PackedStringArray(), method := HTTPClient.Method.METHOD_GET, request_data := "") -> HTTPResult:
	if is_requesting:
		push_warning("AwaitableHTTPRequest is busy performing a request.")
		return HTTPResult._from_error(Error.ERR_BUSY)

	is_requesting = true

	var err := request(url, custom_headers, method, request_data)
	if err:
		return HTTPResult._from_error(err)

	@warning_ignore("unsafe_cast")
	var result := await request_completed as Array
	is_requesting = false
	request_finished.emit()

	return HTTPResult._from_array(result)
