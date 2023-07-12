
//               Copyright Ahmet Sait 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

module twtv.commands;

import std.stdio;
import std.array;
import std.format;
import std.json;

import arsd.http2;

void enforceTwitchApi(HttpResponse response)
{
	if (!response.wasSuccessful)
	{
		if (response.content.length > 0)
		{
			string errorMsg;
			try
				errorMsg = parseJSON(response.contentText)["message"].str;
			catch (Exception)
				return;
			throw new Exception(format("%s %s: %s", response.code, response.codeText, errorMsg));
		}
		throw new Exception(format("%s %s", response.code, response.codeText));
	}
	else
	{
		string[] errors;
		try
		{
			JSONValue json = parseJSON(response.contentText);
			foreach (size_t key, JSONValue value; json[0]["errors"])
				errors ~= value["message"].str;
		}
		catch (Exception)
			return;
		throw new Exception(join(errors, ", "));
	}
}

immutable string url = "https://gql.twitch.tv/gql";
//immutable string url = "http://127.0.0.1:8080";

string getUserId(HttpClient client, string[] headers, string name)
{
	immutable string payload = `[
		{
			"operationName": "GetUserID",
			"variables": {
				"login": "%s",
				"lookupType": "ACTIVE"
			},
			"extensions": {
				"persistedQuery": {
					"sha256Hash": "bf6c594605caa0c63522f690156aa04bd434870bf963deb76668c381d16fcaa5",
					"version": 1
				}
			}
		}
	]`;
	
	HttpRequest req = client.request(
		Uri(url),
		HttpVerb.POST,
		cast(ubyte[])format(payload, name),
		"text/plain;charset=UTF-8",
	);
	req.requestParameters.headers = headers;
	
	HttpResponse res = req.waitForCompletion();
	enforceTwitchApi(res);
	
	return parseJSON(res.contentText)[0]["data"]["user"]["id"].str;
}

/+
Example Request:
[
	{
		"extensions": {
			"persistedQuery": {
				"sha256Hash": "bf6c594605caa0c63522f690156aa04bd434870bf963deb76668c381d16fcaa5",
				"version": 1
			}
		},
		"operationName": "GetUserID",
		"variables": {
			"login": "yazmyn",
			"lookupType": "ACTIVE"
		}
	}
]
Example Response:
[
	{
		"data": {
			"user": {
				"id": "493114638",
				"__typename": "User"
			}
		},
		"extensions": {
			"durationMilliseconds": 22,
			"operationName": "GetUserID",
			"requestID": "01H4ZZND29CBKWFWZ5V1DT5BH3"
		}
	}
]
+/

bool followUser(HttpClient client, string[] headers, string userId, bool notifications = true)
{
	immutable string payload = `[
		{
			"operationName": "FollowButton_FollowUser",
			"variables": {
				"input": {
					"disableNotifications": %s,
					"targetID": "%s"
				}
			},
			"extensions": {
				"persistedQuery": {
					"sha256Hash": "800e7346bdf7e5278a3c1d3f21b2b56e2639928f86815677a7126b093b2fdd08",
					"version": 1
				}
			}
		}
	]`;
	
	HttpRequest req = client.request(
		Uri(url),
		HttpVerb.POST,
		cast(ubyte[])format(payload, !notifications, userId),
		"text/plain;charset=UTF-8",
	);
	req.requestParameters.headers = headers;
	
	HttpResponse res = req.waitForCompletion();
	enforceTwitchApi(res);
	
	return res.wasSuccessful;
}

/+
Example Request:
[
	{
		"extensions": {
			"persistedQuery": {
				"sha256Hash": "800e7346bdf7e5278a3c1d3f21b2b56e2639928f86815677a7126b093b2fdd08",
				"version": 1
			}
		},
		"operationName": "FollowButton_FollowUser",
		"variables": {
			"input": {
				"disableNotifications": false,
				"targetID": "493114638"
			}
		}
	}
]
Example Response:
[
	{
		"data": {
			"followUser": {
				"follow": {
					"disableNotifications": false,
					"user": {
						"id": "493114638",
						"displayName": "yazmyn",
						"login": "yazmyn",
						"self": {
							"canFollow": true,
							"follower": {
								"disableNotifications": false,
								"followedAt": "2023-07-10T14:51:06Z",
								"__typename": "FollowerEdge"
							},
							"__typename": "UserSelfConnection"
						},
						"__typename": "User"
					},
					"__typename": "Follow"
				},
				"error": null,
				"__typename": "FollowUserPayload"
			}
		},
		"extensions": {
			"durationMilliseconds": 49,
			"operationName": "FollowButton_FollowUser",
			"requestID": "01H504HSNJYBDSDWT4FN3QYBA1"
		}
	}
]
+/

bool unfollowUser(HttpClient client, string[] headers, string userId)
{
	static immutable string payload = `[
		{
			"operationName": "FollowButton_UnfollowUser",
			"variables": {
				"input": {
					"targetID": "%s"
				}
			},
			"extensions": {
				"persistedQuery": {
					"sha256Hash": "f7dae976ebf41c755ae2d758546bfd176b4eeb856656098bb40e0a672ca0d880",
					"version": 1
				}
			}
		}
	]`;
	
	HttpRequest req = client.request(
		Uri(url),
		HttpVerb.POST,
		cast(ubyte[])format(payload, userId),
		"text/plain;charset=UTF-8",
	);
	req.requestParameters.headers = headers;
	
	HttpResponse res = req.waitForCompletion();
	enforceTwitchApi(res);
	
	return res.wasSuccessful;
}

/+
Example Request:
[
	{
		"extensions": {
			"persistedQuery": {
				"sha256Hash": "f7dae976ebf41c755ae2d758546bfd176b4eeb856656098bb40e0a672ca0d880",
				"version": 1
			}
		},
		"operationName": "FollowButton_UnfollowUser",
		"variables": {
			"input": {
				"targetID": "493114638"
			}
		}
	}
]
Example Response:
[
	{
		"data": {
			"unfollowUser": {
				"follow": {
					"disableNotifications": false,
					"user": {
						"id": "493114638",
						"displayName": "yazmyn",
						"login": "yazmyn",
						"self": {
							"canFollow": true,
							"follower": null,
							"__typename": "UserSelfConnection"
						},
						"__typename": "User"
					},
					"__typename": "Follow"
				},
				"__typename": "UnfollowUserPayload"
			}
		},
		"extensions": {
			"durationMilliseconds": 39,
			"operationName": "FollowButton_UnfollowUser",
			"requestID": "01H504MYTTHTH30B5KWBHDM6J3"
		}
	}
]
+/

struct User
{
	string id;
	string login;
}

enum Order
{
	ASC,
	DESC,
}

User[] getFollowedChannels(HttpClient client, string[] headers, Order order = Order.ASC)
{
	enum limit = 100;
	static immutable string payload = `[
		{
			"operationName": "ChannelFollows",
			"variables": {
				"limit": %d,
				"order": "%s"
			},
			"extensions": {
				"persistedQuery": {
					"version": 1,
					"sha256Hash": "eecf815273d3d949e5cf0085cc5084cd8a1b5b7b6f7990cf43cb0beadf546907"
				}
			}
		}
	]`;
	
	HttpRequest req = client.request(
		Uri(url),
		HttpVerb.POST,
		cast(ubyte[])format(payload, limit, order),
		"text/plain;charset=UTF-8",
	);
	req.requestParameters.headers = headers;
	
	HttpResponse res = req.waitForCompletion();
	enforceTwitchApi(res);
	
	User[] channels;
	string lastCursor;
	
	JSONValue content = parseJSON(res.contentText);
	size_t count = content[0]["data"]["user"]["follows"]["edges"].array.length;
	
	if (count > 0)
	{
		reserve(channels, count);
		
		foreach (size_t key, ref JSONValue value; content[0]["data"]["user"]["follows"]["edges"])
			channels ~= User(value["node"]["id"].str, value["node"]["login"].str);
		
		lastCursor = content[0]["data"]["user"]["follows"]["edges"].array[$ - 1]["cursor"].str;
	}
	
	static immutable string payloadWithCursor = `[
		{
			"operationName": "ChannelFollows",
			"variables": {
				"cursor": "%s",
				"limit": %d,
				"order": "%s"
			},
			"extensions": {
				"persistedQuery": {
					"version": 1,
					"sha256Hash": "eecf815273d3d949e5cf0085cc5084cd8a1b5b7b6f7990cf43cb0beadf546907"
				}
			}
		}
	]`;
	
	while (count == limit)
	{
		req = client.request(
			Uri(url),
			HttpVerb.POST,
			cast(ubyte[])format(payloadWithCursor, lastCursor, limit, order),
			"text/plain;charset=UTF-8",
		);
		req.requestParameters.headers = headers;
		
		res = req.waitForCompletion();
		enforceTwitchApi(res);
		
		content = parseJSON(res.contentText);
		count = content[0]["data"]["user"]["follows"]["edges"].array.length;
		
		reserve(channels, channels.capacity + count);
		
		foreach (size_t key, ref JSONValue value; content[0]["data"]["user"]["follows"]["edges"])
			channels ~= User(value["node"]["id"].str, value["node"]["login"].str);
		
		lastCursor = content[0]["data"]["user"]["follows"]["edges"].array[$ - 1]["cursor"].str;
	}
	
	return channels;
}

size_t unfollowAll(HttpClient client, string[] headers)
{
	User[] followedChannels = getFollowedChannels(client, headers);
	
	size_t progress;
	foreach (channel; followedChannels)
	{
		if (unfollowUser(client, headers, channel.id))
			progress++;
		else
			return progress;
	}
	
	return progress;
}
