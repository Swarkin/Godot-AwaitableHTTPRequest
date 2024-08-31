class_name AwaitableHTTPRequest
extends HTTPRequest
## Awaitable HTTP Request Node v1.6.0 by swark1n & [url=https://github.com/Swarkin/Godot-AwaitableHTTPRequest/graphs/contributors]contributors[/url].

signal request_finished		## Emits once the current request finishes, right after [member is_requesting] is set to false.
var is_requesting := false  ## Whether the node is busy performing a request.

## A dataclass returned by [method AwaitableHTTPRequest.async_request].
class HTTPResult extends RefCounted:
	var _error: Error				## Returns the [method HTTPRequest.request] error, [constant Error.OK] otherwise.
	var _result: HTTPRequest.Result	## Returns the [annotation HTTPRequest] error, [constant HTTPRequest.RESULT_SUCCESS] otherwise.
	var success: bool:				## Checks whether [member _error] and [member _result] aren't in an error state.[br][b]Note:[/b] This does not return false if [member status_code] is >= 400, see [code]https://developer.mozilla.org/en-US/docs/Web/HTTP/Status[/code].
		get: return true if (_error == OK and _result == HTTPRequest.RESULT_SUCCESS) else false

	var status_code: int			## The response status code.
	var headers: Dictionary			## The response headers.
	var body: String:				## The response body as a [String].
		get: return body_raw.get_string_from_utf8()
	var body_raw: PackedByteArray	## The response body as a [PackedByteArray].
	var json: Variant:				## Attempt to parse [member body] into a [Dictionary] or [Array], returns null on failure.
		get: return JSON.parse_string(body)

	## Constructs a new [AwaitableHTTPRequest.HTTPResult] from an [enum @GlobalScope.Error] code.
	static func _from_error(err: Error) -> HTTPResult:
		var h := HTTPResult.new()
		h._error = err
		return h

	## Constructs a new [AwaitableHTTPRequest.HTTPResult] from the return value of [signal HTTPRequest.request_completed].
	static func _from_array(a: Array) -> HTTPResult:
		var h := HTTPResult.new()
		@warning_ignore('unsafe_cast') h._result = a[0] as HTTPRequest.Result
		@warning_ignore('unsafe_cast') h.status_code = a[1] as int
		@warning_ignore('unsafe_cast') h.headers = _headers_to_dict(a[2] as PackedStringArray)
		@warning_ignore('unsafe_cast') h.body_raw = a[3] as PackedByteArray
		return h

	static func _headers_to_dict(headers_arr: PackedStringArray) -> Dictionary:
		var dict := {}
		for h: String in headers_arr:
			var split := h.split(':')
			dict[split[0]] = split[1].strip_edges()

		return dict


## Performs an awaitable HTTP request.
##[br]Usage:
##[codeblock]
##@export var http: AwaitableHTTPRequest
##
##func _ready() -> void:
##        http = AwaitableHTTPRequest.new()
##        add_child(http)
##    var r := await http.async_request('https://api.github.com/users/swarkin')
##
##    if r.success:
##        print(r.status_code)              # 200
##        print(r.headers['Content-Type'])  # application/json
##        print(r.json['bio'])              # fox.
##[/codeblock]
func async_request(url: String, custom_headers := PackedStringArray(), method := HTTPClient.Method.METHOD_GET, request_body := '') -> HTTPResult:
	is_requesting = true

	var e := request(url, custom_headers, method, request_body)
	if e:
		return HTTPResult._from_error(e)

	@warning_ignore('unsafe_cast')
	var result := await request_completed as Array

	is_requesting = false
	request_finished.emit()

	return HTTPResult._from_array(result)
