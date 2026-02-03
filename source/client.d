import std.concurrency;
import baseclient;
import packet;
import game;
import core.thread.osthread;
import std.datetime;
import std.bitmanip : read;
import std.stdio;

class Client : BaseClient
{
	Game game;
	SysTime nextPing;

	override void Connect(string ip, ushort port)
	{
		super.Connect(ip, port);
		Send(Packet0Handshake());
	}

	override void HandlePacket(ubyte[] packet)
	{
		const uint pType = *cast(const uint*)packet.ptr;
		const ulong pLength = packet.length;
		// first 4 bytes is type
		writeln("Client:");
		writefln("pType: 0x%X", pType);
		writefln("pLength: 0x%d", pLength);
		switch(pType)
		{	
			case Packet2SetUserId.p.Type:
				mixin PackAsType!(Packet2SetUserId,packet);
				writeln("Server connection established successfully. Userid: ", pack.id);
				break;

			default:
				writeln("Unknown packet type: ", pType, " packet: ", packet);
				break;
		}
	}

	override void Tick()
	{
		super.Tick();
		if(Clock.currTime() > nextPing)
		{
			this.Send(1);
		}
	}

	void Send(PType)(PType pack)
	{
		super.Send(pack);
		nextPing = Clock.currTime() + 25.seconds;
	}
}

shared(bool) Client_run;

void Client_Loop()
{
	Client cl = new Client();
	Thread.sleep( dur!("msecs")( 50 ) );
	cl.Connect("127.0.0.1",21370); // TODO : Unhardcode port
	while(Client_run)
	{
		cl.Tick();

	}
	cl.CloseSocket();
	Client_run = false;
}

// called in main
public void Client_Init()
{
	Client_run = true;
	spawn(&Client_Loop);
}

public void Client_End()
{
	Client_run = false;
}