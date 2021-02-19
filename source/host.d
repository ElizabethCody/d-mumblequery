import std.conv : to;
import std.regex : regex, matchFirst;
import std.string : strip;

static immutable auto HOST_PORT_REGEX = regex(r"(\[[:a-fA-F0-9]+\]|(?:\d{1,3}\.){3}\d{1,3}|[-a-zA-Z0-9.]+)(?::(\d+))?");

struct Host {
  immutable string hostname;
  immutable ushort port;

  static Host parse(string str, ushort defaultPort) @safe {
    auto matches = matchFirst(str, HOST_PORT_REGEX);
    matches.popFront();

    return Host(matches.front.strip("[]"), matches.back.length >= 1 ? matches.back.to!ushort() : defaultPort);
  }
}
