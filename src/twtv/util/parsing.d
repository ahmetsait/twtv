module twtv.util.parsing;

struct ParseResult
{
	bool success;
	
	string result;
	size_t length() { return result.length; }
	
	string[] children;
	
	string input;
	string remaining;
	
	this(string input, string result, string[] children)
	{
		this.input = input;
		this.result = result;
		this.remaining = input[result.length .. $];
		this.children = children;
		success = true;
	}
	
	this(string input, string result, scope string[] children...)
	{
		this(input, result, children.dup);
	}
	
	bool opCast(T : bool)() const
	{
		return success;
	}
}

ParseResult parseEOF(string input)
{
	if (input.length > 0)
		return ParseResult();
	else
		return ParseResult(input, input[$ .. $]);
}

ParseResult parseSpaces(string input)
{
	size_t i;
	
	for (i = 0; i < input.length; i++)
	{
		char c = input[i];
		if (c != ' ' && c != '\t')
			break;
	}
	
	return ParseResult(input, input[0 .. i]);
}

ParseResult parseLiteral(string input, string literal)
{
	if (input.length >= literal.length && input[0 .. literal.length] == literal)
		return ParseResult(input, input[0 .. literal.length]);
	
	return ParseResult();
}

ParseResult parseFieldName(string input)
{
	size_t i;
	
	for (i = 0; i < input.length; i++)
	{
		char c = input[i];
		if (!isFieldNameChar(c))
			break;
	}
	if (i == 0)
		return ParseResult();
	
	return ParseResult(input, input[0 .. i]);
}

bool isFieldNameChar(char c)
{
	import std.ascii;
	static immutable char[] valid = "!#$%&'*+-.^_`|~";
	static bool contains(T)(T[] array, char c)
	{
		// Avoid auto-decoding
		for (size_t i = 0; i < array.length; i++)
			if (array[i] == c)
				return true;
		return false;
	}
	return std.ascii.isAlphaNum(c) || contains(valid, c);
}

ParseResult parseHeaderField(string input)
{
	ParseResult fieldName = parseFieldName(input);
	if (!fieldName.success || input.length <= fieldName.length)
		return ParseResult();
	
	ParseResult colon = parseLiteral(fieldName.remaining, ":");
	if (!colon)
		return ParseResult();
	
	size_t i;
	for (i = 0; i < colon.remaining.length; i++)
	{
		if (colon.remaining[i] == '\r' || colon.remaining[i] == '\n')
			break;
	}
	return ParseResult(input, input[0 .. fieldName.length + colon.length + i], fieldName.result, colon.remaining[0 .. i]);
}
