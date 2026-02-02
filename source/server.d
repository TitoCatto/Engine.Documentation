import baseserver;
import std.stdio;
import std.concurrency;
import game;
import userinfo;
import user;

class Server : BaseServer
{
	Game game;
	UserInfo[] connected_users;
	User last_userid;
	
	this()
	{
		game = new Game();
	}
	
	override ubyte[] ProcessPacket(uint packettype, ubyte[] data, sockaddr fromi)
	{
		writeln(packettype);
		return [];
	}
	
	override void Tick(double delta)
	{
		game.Tick(delta);
		super.Tick(delta);
	}
}


shared(bool) Server_run;

void Server_Loop()
{
	Server sv = new Server();
	sv.Listen(21370); // TODO : Unhardcode port
	while(Server_run)
	{
		sv.Tick(0.016);
	}
	sv.CloseSocket();
	Server_run = false;
}

// called in main
public void Server_Init()
{
	Server_run = true;
	spawn(&Server_Loop);
}

public void Server_End()
{
	Server_run = false;
}