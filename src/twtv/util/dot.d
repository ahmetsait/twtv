
//               Copyright Ahmet Sait 2023.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

module twtv.util.dot;

string ensureDot(string str)
{
	if (str.length > 0 && str[$ - 1] == '.')
		return str;
	else
		return str ~ '.';
}
