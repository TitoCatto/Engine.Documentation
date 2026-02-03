import user;
import userdata;

public enum PACKET_FLAGS : uint {
	Error      = 0x80000000,
	Processing = 0x40000000,
	Registry   = 0x20000000,
	User       = 0x10000000
	// Encryption?
}

struct Packet(uint ID)
{ align(1):
	uint type = ID;
	// TODO : we prolly want entries for CRC, incrementing packet id (for out-of-order fixups and responses)
}

struct RegistryPacket(uint ID)
{ align(1):
	uint type = PACKET_FLAGS.Registry | ID;
	// TODO : ditto
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

