public import std.socket;

class BaseServer
{

	UdpSocket listener;
	void Listen(ushort port)
	{
		if(listener !is null)
		{
			CloseSocket();
		}
		listener = new UdpSocket();
		listener.blocking = false;
		listener.bind(new InternetAddress(port));
	}
	
	ubyte[] ProcessPacket(uint packettype, ubyte[] data, sockaddr fromi)
	{
		return [];
	}

	void Tick(double delta)
	{
		if(listener is null)
		{
			return;
		}
		
		try
		{
			Address from;
			ubyte[2048] packet;
			auto packetLength = listener.receiveFrom(packet[], from);
			while(packetLength != Socket.ERROR)
			{
				sockaddr fromi = *from.name();
				uint packettype = *cast(uint*)packet.ptr;
				
				ubyte[] tosend = ProcessPacket(packettype,(packet.ptr)[0..packetLength],fromi);
				if(tosend.length > 0)
				{
					listener.sendTo(tosend,from);
				}
				packetLength = listener.receiveFrom(packet[], from);
			}
		}
		catch(Exception e)
		{
		
		}
	}
	
	void CloseSocket()
	{
		listener.shutdown(SocketShutdown.BOTH);
		listener.close();
		listener = null;
	}
	
	void SendToAll(PacketT)(PacketT pack)
	{
		foreach(addr; clients)
		{
			listener.sendTo([pack],new InternetAddress(cast(sockaddr_in)addr));
		}
	}
}