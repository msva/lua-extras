#!/usr/bin/env lua

function tobin(s,p)
	local s = tonumber(s);
	if not s then return nil; end;
	prefix = p and "0b" or '';
	local out = '';

	while s >= 1 do
		if (s%2 ~= 0) then
			out = "1"..out;
		else
			out = "0"..out;
		end;
		s = math.floor(s/2);
	end;
	return out;
end;

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function torbin(s,p)
	local s = tonumber(s);
	if not s then return nil; end;
	prefix = p and "0b" or '';
	local out = '';

	while s >= 1 do
		if (s%2 ~= 0) then
			out = out.."1"
		else
			out = out.."0";
		end;
		s = math.floor(s/2);
	end;
	return out;
end;

function tohex(s,p)
	local s = tonumber(s);
	if not s then return nil; end;
	prefix = p and "0x" or '';
	local out = '';
	local hex = {
	[10] = "A";
	[11] = "B";
	[12] = "C";
	[13] = "D";
	[14] = "E";
	[15] = "F";
	};

	while s >= 1 do
		N=(s%16);
		if N>9 then
			out = hex[N]..out;
		elseif (N<=9) then
			out = N..out;
		end;
		s = math.floor(s/16);
	end;
	return prefix..out;
end;

function string.symbol(string,symbol)
	return string:sub(symbol,symbol);
end;

function string.print(string)
	print(string);
end;
