import user;
import userdata;
import sex;
import world;

public enum PACKET_FLAGS : uint {
	Error      = 0x80000000,
	Processing = 0x40000000,
	Registry   = 0x20000000,
	User       = 0x10000000
	// Encryption?
}

struct Packet(uint ID)
{ align(1):
	static const uint Type = ID;
	uint type = ID;
	// TODO : we prolly want entries for CRC, incrementing packet id (for out-of-order fixups and responses)
}

struct RegistryPacket(uint ID)
{ align(1):
	static const uint Type = PACKET_FLAGS.Registry | ID;
	uint type = ID;
	// TODO : ditto
}

mixin template PackAsType(T, alias packet)
{
	T pack = *cast(T*)(packet.ptr);
}

//! server packets

// dab me up
struct Packet0Handshake
{ align(1):
	Packet!(0) p;
}

// sent 25 seconds after last packet, if isnt set for 30 secs you get kicke
struct Packet1Heartbeat
{ align(1):
	Packet!(1) p;
}

// after handshake client gets his User
struct Packet2SetUserId
{ align(1):
	Packet!(2) p;
	
	User id;
}

struct Packet3Userdata
{ align(1):
	Packet!(3) p;
	
	enum UserdataOp : byte
	{
		Create,
		Modify,
		SetName,
		Remove
	};
	
	UserdataOp type;
	
	union
	{
		struct CreateArg
		{
			string name;
		};
		CreateArg create;
		
		struct ModifyArg
		{
			UserdataRef id;
			uint pos;
			ushort length;
			ubyte[] data;
		};
		ModifyArg modify;
		
		struct SetNameArg
		{
			UserdataRef id;
			string name;
		};
		SetNameArg setname;
		
		UserdataRef remove;
	}
	
	void[] Serialize()
	{
		void[] ret;
		p.Serialize(ret);
		type.Serialize(ret);
		switch(type)
		{
			case UserdataOp.Create:
				create.name.Serialize(ret);
				break;
			case UserdataOp.Modify:
				modify.id.Serialize(ret);
				modify.pos.Serialize(ret);
				modify.length.Serialize(ret);
				modify.data.Serialize(ret);
				break;
			case UserdataOp.SetName:
				setname.id.Serialize(ret);
				setname.name.Serialize(ret);
				break;
			case UserdataOp.Remove:
				remove.Serialize(ret);
				break;
			default: assert(0);
		}
		return ret;
	}
}

struct Packet4CreateWorld
{ align(1):
	Packet!(4) p;
	
	WorldInfo info;
}

//! end server packets
//! registry packets

struct PacketR0Get
{ align(1):
	RegistryPacket!(0) p;
}

struct PacketR1Status
{ align(1):
	RegistryPacket!(1) p;
}

//! end registry packets

