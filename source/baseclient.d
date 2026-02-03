import std.socket;
import std.stdio;

class BaseClient
{
		
	UdpSocket serversocket;
	void Connect(string ip, ushort port)
	{
		serversocket = new UdpSocket();
		serversocket.blocking = false;
		serversocket.connect(new InternetAddress(ip,port));
	}
	
	void HandlePacket(ubyte[] packet)
	{
		
	}
	
	void Tick()
	{
		ubyte[2048] packet;
		auto packetLength = serversocket.receive(packet[]);
		while(packetLength != Socket.ERROR && packetLength > 0)
		{
			writeln(packetLength);
			HandlePacket(packet[0..packetLength]);
			packetLength = serversocket.receive(packet[]);
		}
	}
	
	void CloseSocket()
	{
		serversocket.shutdown(SocketShutdown.BOTH);
		serversocket.close();
		serversocket = null;
	}
	
	void Send(PType)(PType pack)
	{
		serversocket.send([pack]);
	}
}