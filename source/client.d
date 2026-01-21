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