require "crypto"; --openssl's digest calculation
--[[
TODO: допереписать комменты на английском и выложить для других :)
]]
function string.symbol(string,symbol) return string:sub(symbol,symbol) end
if not arg[1] or not arg[2] then print("Add password as 1 argument and salt as 2"); os.exit(1);end
key=arg[1];
psalt=arg[2];
local evp = crypto.evp;

algo = "sha512"; -- TODO: get from arg[3]
hashsize = 64;	 -- TODO: autodetect from arg[3]
ID = 6;		 -- TODO: sha512->6,256->5,<...>

--[[ parse rounds from salt, if it is present ]]
rounds,salt=nil;
rounds,salt=psalt:match("rounds=(%d+)[$](.*)");
if not salt and not rounds then
salt=psalt:sub(0,16);
rounds=5000; --[[ default value for both sha512 and sha256. TODO: other algos.]]
end;

--[[ starting digest A ]]
A = evp.new(algo);
A:update(key);
A:update(salt);

--[[ starting digest B ]]
B = evp.new(algo);
B:update(key);
B:update(salt);
B:update(key);
B_D = B:digest(nil,true);
Lk = key:len();

while Lk>hashsize do
	A:update(B_D)
	Lk = Lk-hashsize;
end;

A:update(B_D:sub(0,Lk));
Lk = key:len(); --reinit
Lk=tonumber(Lk);
while Lk>0 do
	if (Lk%2 ~= 0) then
		A:update(B_D)
	else
		A:update(key)
	end;
	Lk=math.floor(Lk/2);
end;

A_D = A:digest(nil,true);

DP = evp.new(algo);
Lk = key:len(); --[[ reinit again. TODO: потестить, не быстрее ли будет один раз инициализировать в начале, а потом присваивать новым вместо того, чтобы каждый раз заного считать длину? :)]]

for DLk = 1,Lk do
	DP:update(key);
end;

DP_D = DP:digest(nil,true);
P = "";

while Lk>=hashsize do
	P = P..DP_D;
	Lk = Lk-hashsize;
end;

P = P..DP_D:sub(0,Lk);
DS = evp.new(algo);
cnt=0;
for i = 1,16+A_D:byte() do
	DS:update(salt);
	cnt=i;
end;
DS_D = DS:digest(nil,true);

S = "";
Ls = salt:len();
while Ls>=hashsize do
	S = S..DS_D;
	Ls = Ls-hashsize;
end;
S = S..DS_D:sub(0,Ls);

-- 21. Loop.
C_D = A_D;
for loop = 0,rounds-1 do
	C = evp.new(algo);
	if loop%2 ~= 0 then
		C:update(P);
	else
		C:update(C_D);
	end
	if loop%3 ~= 0 then
		C:update(S);
	end
	if loop%7 ~= 0 then
		C:update(P);
	end
	if loop%2 ~= 0 then
		C:update(C_D);
	else
		C:update(P);
	end
	C_D = C:digest(nil,true);
end

out='';
--[[ В книжке числа от 0 до 63, ибо плюсы нумеруют биты именно так. Т.к. мы нумеруем с 1, то и здесь пишем 1-64. ]]
byteseq={
  {1,22,43,4},
  {23,44,2,4},
  {45,3,24,4},
  {4,25,46,4},
  {26,47,5,4},
  {48,6,27,4},
  {7,28,49,4},
  {29,50,8,4},
  {51,9,30,4},
  {10,31,52,4},
  {32,53,11,4},
  {54,12,33,4},
  {13,34,55,4},
  {35,56,14,4},
  {57,15,36,4},
  {16,37,58,4},
  {38,59,17,4},
  {60,18,39,4},
  {19,40,61,4},
  {41,62,20,4},
  {63,21,42,4},
  {0,0,64,2}
}

b64t={".","/",
"0","1","2","3","4","5","6","7","8","9",
"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
};

cp='';
for i in pairs(byteseq) do
	b2=C_D:symbol(byteseq[i][1]):byte() or 0;
	b1=C_D:symbol(byteseq[i][2]):byte() or 0;
	b0=C_D:symbol(byteseq[i][3]):byte() or 0;
	N=byteseq[i][4];
	w=((b2*65536)+(b1*256)+b0);
	while N>0 do
	N=N-1;
	cp=cp..b64t[w%64+1];
	w=math.floor(w/64);
	end
end
print("$"..ID.."$"..((rounds~=5000) and rounds.."$" or '')..salt.."$"..cp)