import std.socket;
import std.random : uniform;
import std.datetime : dur;
import std.bitmanip : bigEndianToNative, nativeToBigEndian;
import std.exception : enforce;

struct MumbleQuery {
  immutable ubyte[4] serverVersion;
  immutable uint users, slots, bandwidth;

  static MumbleQuery query(Address address) @safe {
    auto socket = new UdpSocket(address.addressFamily);
    auto id = uniform!ulong;
    socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"seconds"(1));
    auto tx = socket.sendTo(nativeToBigEndian!uint(0) ~ nativeToBigEndian(id), address);
    enforce(tx == 12, "failed to send query request");

    ubyte[24] response;
    auto rx = socket.receiveFrom(response, address);
    enforce(rx == response.length, "failed to read query response");
    socket.close();

    enforce(id == bigEndianToNative!ulong(response[4..12]), "packet id mismatch");
    auto users = bigEndianToNative!uint(response[12..16]);
    auto slots = bigEndianToNative!uint(response[16..20]);
    auto bandwidth = bigEndianToNative!uint(response[20..24]);

    return MumbleQuery(response[0..4], users, slots, bandwidth);
  }
}
