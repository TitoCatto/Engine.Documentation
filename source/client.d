import std.concurrency;
import baseclient;
import packet;
import game;

class Client : BaseClient
{
	Game game;

	override void Connect(string ip, ushort port)
	{
		super.Connect(ip, port);
		Send(Packet0Handshake());
	}
}

shared(bool) Client_run;

void Client_Loop()
{
	Client cl = new Client();
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