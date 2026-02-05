// SErialized X data
import std.bitmanip;
import std.system;

void Serialize(T)(T v,ref void[] output)
{
	output ~= [v];
}

T Deserialize(T)(ref void[] input)
{
	return input.read!(T, Endian.littleEndian);
}

void Serialize(T : T[])(T[] v, ref void[] output)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}

T[] Deserialize(T : T[])(ref void[] input)
{
	ulong arraylength = Deserialize!ulong(input);
	T[] ret = new T[](arraylength);
	foreach(ref T v; ret)
	{
		v = input.read!(T, Endian.littleEndian);
	}
	return ret;
}

void Serialize(T : string)(string v,ref void[] output)
{
	output ~= [cast(ulong)v.length];
	output ~= cast(ubyte[])v;
}

string Deserialize(T : string)(ref void[] input)
{
	return cast(string)Deserialize!ubyte(input);
}