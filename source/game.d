import bag;
import script;
import files;

enum WorldState
{
	CONNECT,
	DOWNLOADING,
	LOADED,
	SIMULATING,
	FOCUSED
}

class World
{
	WorldState state;

	Bag[ulong] bags;
	Script[ulong] scripts;
	ulong[] scheduled_scripts;
	
	Storage storage;
	
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