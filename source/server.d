import baseserver;
import std.stdio;
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
		return [];
	}
	
	override void Tick(double delta)
	{
		game.Tick(delta);
		super.Tick(delta);
	}
}