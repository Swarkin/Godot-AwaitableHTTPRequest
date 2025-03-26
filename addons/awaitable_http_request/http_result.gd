class_name HTTPResult
extends RefCounted
## A dataclass returned by [method AwaitableHTTPRequest.async_request].

var _error: Error				## Contains the [method HTTPRequest.request] error, [constant Error.OK] otherwise. See also [method success].[br](For advanced use-cases)
var _result: HTTPRequest.Result	## Contains the [annotation HTTPRequest] error, [constant HTTPRequest.RESULT_SUCCESS] otherwise. See also [method success].[br](For advanced use-cases)
var status: int					## The response status code.
var headers: Dictionary			## The response headers.
var bytes: PackedByteArray		## The response body as a [PackedByteArray].[br][b]Note:[/b] Any [Array] is always passed by reference.

## Checks whether the HTTP request succeeded, meaning [member _error] and [member _result] aren't in an error state.[br]
## [b]Note:[/b] This does not check the response [member status] code.
func success() -> bool:
	return _error == OK and _result == HTTPRequest.RESULT_SUCCESS

## Checks whether the [member status] is between 200 and 299 (inclusive), see [url]https://developer.mozilla.org/en-US/docs/Web/HTTP/Status[/url].
func status_ok() -> bool:
	return status >= 200 and status < 300

## Checks whether the [member status] is between 400 and 599 (inclusive), see [url]https://developer.mozilla.org/en-US/docs/Web/HTTP/Status[/url].
func status_err() -> bool:
	return status >= 400 and status < 600

## The response body as a [String].[br]
## For other formatting (ascii, utf16, ...) or special use-cases (file I/O, ...), it is possible to access the raw body's [member bytes].[br]
## You should cache this return value instead of calling the funciton multiple times.
func body_as_string() -> String:
	return bytes.get_string_from_utf8()

## Attempt to parse the response [member bytes] into a [Dictionary] or [Array], returns null on failure.[br][br]
## It is possible to cast the return type to a [Dictionary] with "[code]as Dictionary[/code]" to receive autocomplete and other benefits when the parsing was successful.[br]
## If you want error handling for the JSON deserialization, make an instance of [JSON] and call [method JSON.parse] on it, passing in the return value of [method HTTPResult.body_as_string]. This allows the usage of [method JSON.get_error_message] and [method JSON.get_error_line] to get potential error information.[br][br]
## [b]Note:[/b] Godot always converts JSON numbers to [float]s!
func body_as_json() -> Variant:
	return JSON.parse_string(body_as_string())

# Constructs a new [HTTPResult] from an [enum @GlobalScope.Error] code. (Used internally, hidden from API list)
static func _from_error(err: Error) -> HTTPResult:
	var h := HTTPResult.new()
	h._error = err
	return h

# Constructs a new [HTTPResult] from the return value of [signal HTTPRequest.request_completed]. (Used internally, hidden from API list)
@warning_ignore("unsafe_cast")
static func _from_array(a: Array) -> HTTPResult:
	var h := HTTPResult.new()
	h._result = a[0] as HTTPRequest.Result
	h.status = a[1] as int
	h.headers = _headers_to_dict(a[2] as PackedStringArray)
	h.bytes = a[3] as PackedByteArray
	return h

# Converts a [PackedStringArray] of headers into a [Dictionary]. The header names will be in lowercase, as some web servers prefer this approach and them being case-insensitive as per specification. Therefore, it is good practice to not rely on capitalization. (Used internally, hidden from API list)
static func _headers_to_dict(headers_arr: PackedStringArray) -> Dictionary:
	var dict := {}
	for h in headers_arr:
		var split := h.split(":", true, 1)
		dict[split[0].to_lower()] = split[1].strip_edges()

	return dict
