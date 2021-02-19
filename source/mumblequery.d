import std.socket;
import std.random : uniform;
import std.datetime : dur;
import std.bitmanip : bigEndianToNative, nativeToBigEndian;

struct MumbleQuery {
  immutable ubyte[4] serverVersion;
  immutable uint users, slots, bandwidth;

  static MumbleQuery query(Address address) @safe {
    auto socket = new UdpSocket(address.addressFamily);
    auto id = uniform!ulong;
    socket.setOption(SocketOptionLevel.SOCKET, SocketOption.RCVTIMEO, dur!"seconds"(15));
    socket.sendTo(nativeToBigEndian!uint(0) ~ nativeToBigEndian(id), address);

    ubyte[24] response;
    socket.receiveFrom(response, address);
    socket.close();

    assert(id == bigEndianToNative!ulong(response[4..12]), "packet id mismatch");
    auto users = bigEndianToNative!uint(response[12..16]);
    auto slots = bigEndianToNative!uint(response[16..20]);
    auto bandwidth = bigEndianToNative!uint(response[20..24]);

    return MumbleQuery(response[0..4], users, slots, bandwidth);
  }
}
