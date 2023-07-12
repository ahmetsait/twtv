
//               Copyright Ahmet Sait 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

module twtv.app;

import core.volatile;

import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.format;
import std.getopt;
import std.stdio;
import std.string;

import arsd.http2;

immutable string versionString = "Twtv v0.1.0";

immutable string helpString = import("help.txt");

int main(string[] args)
{
	bool showVersion;
	bool showHelp;
	
	string headersFilePath = "headers.txt";
	string userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0";
	//string userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36";
	//string userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15";
	bool verboseOutput;
	
	version(Posix)
	{
		import core.sys.posix.signal;
		// Prevent crash when servers close the connection early
		signal(SIGPIPE, SIG_IGN); // Ignore SIGPIPE
	}
	
	static int usageError(string msg)
	{
		import twtv.util.dot;
		stderr.writeln(ensureDot(msg));
		stderr.writeln("Try 'twtv --help' for more information.");
		return 1;
	}
	
	static int usageErrorf(Args...)(string fmt, Args args)
	{
		return usageError(format(fmt, args));
	}
	
	try
	{
		getopt(args,
			std.getopt.config.caseSensitive,
			std.getopt.config.passThrough,
			"headers|h", &headersFilePath,
			"user-agent", &userAgent,
			"verbose|v", &verboseOutput,
			"version", &showVersion,
			"help|?", &showHelp,
		);
	}
	catch (Exception ex)
	{
		return usageError(ex.msg);
	}
	
	if (showHelp)
	{
		write(helpString);
		return 0;
	}
	
	if (showVersion)
	{
		writeln(versionString);
		return 0;
	}
	
	HttpClient client = new HttpClient();
	client.userAgent = userAgent;
	
	static immutable string[] requiredHeaders = [
		"Authorization",
		"Client-Id",
		"Client-Integrity",
		"X-Device-Id",
	];
	
	string[] headers;
	reserve(headers, requiredHeaders.length);
	
	try
	{
		bool[requiredHeaders.length] headersFoundMap;
		
		File headersFile = File(headersFilePath);
		
		foreach (line; headersFile.byLineCopy)
		{
			import twtv.util.parsing;
			
			ParseResult header = parseHeaderField(line);
			if (header)
			{
				string headerName = header.children[0];
				ptrdiff_t index = countUntil!((a,b) => icmp(a,b) == 0)(requiredHeaders, headerName);
				if (index >= 0)
				{
					if (index == 0) // Authorization
						client.authorization = header.children[1];
					else
						headers ~= header.result;
					headersFoundMap[index] = true;
				}
			}
		}
		if (any!(x => x == false)(headersFoundMap[]))
		{
			stderr.writeln("Header file has missing fields:");
			foreach (i, fieldName; requiredHeaders)
				if (!headersFoundMap[i])
					stderr.writefln("    %s", fieldName);
			return 1;
		}
	}
	catch (Exception ex)
	{
		stderr.writefln("Failed to read header file '%s': %s", headersFilePath, ex);
		return 1;
	}
	
	string command;
	
	if (args.length < 2 || args[0][0] == '-')
	{
		return usageError("Command required.");
	}
	
	command = args[1];
	args = args[2 .. $];
	
	{
		import twtv.commands;
		
		switch (command)
		{
			case "get-user-id":
				if (args.length == 0)
					return usageError("Missing channel name argument.");
				else if (args.length == 1)
					writeln(getUserId(client, headers, args[0]));
				else
					return usageError("Too many arguments.");
				break;
			
			case "follow":
				bool success;
				
				if (args.length == 0)
					return usageError("Missing channel id argument.");
				else if (args.length == 1)
					success = followUser(client, headers, args[0]);
				else if (args.length == 2)
					success = followUser(client, headers, args[0], args[1].to!bool);
				else
					return usageError("Too many arguments.");
				
				if (!success)
					stderr.writefln("Failed to follow user: %s", args[0]);
				return success ? 0 : 1;
			
			case "unfollow":
				bool success;
				
				if (args.length == 0)
					return usageError("Missing channel id argument.");
				else if (args.length == 1)
					success = unfollowUser(client, headers, args[0]);
				else
					return usageError("Too many arguments.");
				
				if (!success)
					stderr.writefln("Failed to unfollow user: %s", args[0]);
				return success ? 0 : 1;
			
			case "get-followed-channels":
				User[] channels;
				
				if (args.length == 0)
					channels = getFollowedChannels(client, headers);
				else
					return usageError("Too many arguments.");
				
				foreach (channel; channels)
					writefln("%s\t%s", channel.id, channel.login);
				break;
			
			case "unfollow-all":
				size_t result;
				if (args.length == 0)
					result = unfollowAll(client, headers);
				else
					return usageError("Too many arguments.");
				
				if (verboseOutput)
					stderr.writefln("%d channels unfollowed.", result);
				break;
			
			default:
				return usageErrorf("Unrecognized command: '%s'.", command);
		}
	}
	
	return 0;
}
