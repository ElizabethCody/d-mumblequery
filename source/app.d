import std.stdio;
import std.socket;
import std.conv : to;
import std.regex : regex, matchFirst;
import std.string : strip;
import mumblequery;

void main(string[] args) @safe {
  if(args.length == 1) {
    writefln("Usage: %s [<host[:port]>...]", args[0]);
  } else {
    auto hostex = regex(r"(\[[:a-fA-F0-9]+\]|(?:\d{1,3}\.){3}\d{1,3}|[-a-zA-Z0-9.]+)(?::(\d+))?");

outer:
    foreach(arg; args[1..$]) {
      auto matches = matchFirst(arg, hostex);
      matches.popFront();

      auto host = matches.front.strip("[]");
      ushort port = matches.back.length >= 1 ? matches.back.to!ushort() : 64738;

      try {
        auto addresses = host.getAddress(port);

        foreach(address; addresses) {
          try {
            if(address.addressFamily == AddressFamily.INET || address.addressFamily == AddressFamily.INET6) {
              auto reply = MumbleQuery.query(address);

              writefln("Server: %s (%s)", arg, address.toString());
              writefln("Version: %d.%d.%d", reply.serverVersion[1], reply.serverVersion[2], reply.serverVersion[3]);
              writefln("Users: %d/%d", reply.users, reply.slots);
              writefln("Bandwidth: %d b/s", reply.bandwidth);
              writeln();

              continue outer;
            }
          } catch(Exception ignored) { }
        }

        writefln("Couldn't find Mumble server at %s.", arg);
      } catch(SocketException exception) {
        writefln("Failed to lookup hostname %s: %s.", arg, exception.msg);
      }

      writeln();
    }
  }
}
