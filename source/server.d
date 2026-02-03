import baseserver;
import std.stdio;
import std.concurrency;
import game;
import userinfo;
import user;
import std.datetime;
import packet;

class Server : BaseServer
{
	Game game;
	UserInfo[sockaddr] connected_users;
	User last_userid;
	
	this()
	{
		game = new Game();
	}
	
	override void[] ProcessPacket(uint packettype, ubyte[] data, sockaddr fromi)
	{	
		writeln("Server:");
		writeln(packettype);
		void[] retVal;
		UserInfo* fromuser;
		User userid;
		if(fromi in connected_users)
		{
			fromuser = &connected_users[fromi];
			userid = fromuser.id;
		}
		
		switch(packettype)
		{	
			case Packet0Handshake.p.Type:
				writefln("Registering new user with id %d", last_userid);
				const UserInfo newUser = {fromi, cast(User)last_userid++, Clock.currTime()};
				connected_users[fromi] = newUser;
				fromuser = &connected_users[fromi];
				retVal = [Packet2SetUserId(id:newUser.id)];
				break;

			case Packet1Heartbeat.p.Type:
				writeln("Packet1Heartbeat from userid: ", userid);
				retVal = [];
				break;
			
			case Packet3Userdata.p.Type:
				writeln("Packet3Userdata from userid: ", userid);
				
				retVal = [];
				break;
			
			default:
				writeln("admin pomocy siur szczypie");
				retVal = [];
				break;
		}
		fromuser.lastPacketTime = Clock.currTime();
		return retVal;
	}
	
	override void Tick(double delta)
	{
		foreach(user; connected_users)
		{
			if(Clock.currTime() > user.lastPacketTime + 30.seconds)
			{
				writeln("spierdalaj głupi chuju ", user.id);
				connected_users.remove(user.addr);
			}
		}

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