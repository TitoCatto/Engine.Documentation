import entity;
import script;
import storage;
import user;
import userdata;

enum WorldState
{
	CONNECT,
	DOWNLOADING,
	LOADED,
	SIMULATING,
	FOCUSED
}

struct WorldStorage
{
	Storage[User] storage;
	
	pragma(inline) Userdata DerefUserdata(UserdataRef r)
	{
		return storage[r.owner][r.id];
	}
	
	alias this = storage;
}

class World
{
	WorldState state;

	Entity[ulong] ents;
	Script[ulong] scripts;
	ulong[] scheduled_scripts;
	
	WorldStorage storage;
	
	void Tick(double delta)
	{
		foreach(script_id; scheduled_scripts)
		{
			scripts[script_id].Tick(delta);
		}
		
		scheduled_scripts.length = 0;
	}
	
	void Net()
	{
		
	}
	
	void Serialize(ref void[] outbuffer)
	{
	
	}
}

class WorldManager
{
	World[] worlds;
	World focused_world;
	
	this()
	{
		
	}
	
	void Tick(double delta)
	{
		foreach(world; worlds)
		{
			if(world.state >= WorldState.SIMULATING)
			{
				world.Tick(delta);
			}
			world.Net();
		}
	}
	
	void SerializeWorlds(ref void[] outbuffer)
	{
		foreach(world; worlds)
		{
			if(world.state >= WorldState.LOADED)
			{
				world.Serialize(outbuffer);
			}
		}
	}
}

class Game
{
	WorldManager wm;
	
	this()
	{
		this.wm = new WorldManager();
	}
	
	void Tick(double delta)
	{
		this.wm.Tick(delta);
	}
	
	void SerializeEverything(ref void[] outbuffer)
	{
		this.wm.SerializeWorlds(outbuffer);
	}
}