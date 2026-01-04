/*
	脚本名称: pq的地图建造工具【重生版】脚本
	脚本语言: Squirrel(松鼠语言)
	创建日期: 2023年6月中旬
	脚本作者: pq
	作者邮箱: 553387747@qq.com
	脚本简介: 该脚本用于侠盗猎车手之罪恶都市联机, 游戏内地图制作, 可编辑保存地图, 以及导出功能和代码转换功能, 导出的地图支持单机和联机, 并且工具本身就是联机的服务器。
	脚本版权: 版权归原作者pq所有, 转载本脚本仅用于学习, 研究, 交流为目的, 欢迎非商业性转载。
*/

//============================== M A P  E D I T O R  S C R I P T ==============================


//============================== C L A S S ==============================

class PlayerClass {
	obj = null;
	objarr = null;
	objarrlen = 20;
	objarrsee = true;
	fly = true;
	keytimer = null;
	keyup = false;
	keydown = false;
	keyleft = false;
	keyright = false;
	keypageup = false;
	keypagedown = false;
	keyshift = false;
	keyalt = false;
	keyctrl = false;
	keyw = false;
	keyc = false;
	keyx = false;
	keylb = false;
	speed = 1;
	speedarr = 0;
	mode = "Move";
	editmode = "Relative Player";
	rtxmode = false;
	istype = false;
	firstspawn = false;
	rtxpos = Vector(0, 0, 0);
	rtxobjid = null;
	hide = false;
	tp = null;
	diepos = null;
	cadd = false;
	keyttimer = null;
	frozen = false;
	guntp = false;
}

enum StreamType {
	ObjInfo = 0x01
	SendFly = 0x02
	SendSpeed = 0x03
	SendInfo = 0x04
	SendMap = 0x05
	ObjArrSpr = 0x06
	SendObjArrLen = 0x07
	SendHide = 0x08
	SendCAdd = 0x09
	GunTPMode = 0x10
}

enum ArgType {
	BOOL = 1
	INTEGER = 2
	FLOAT = 3
	STRING = 4
}

//============================== S E R V E R  E V E N T S ==============================

function onServerStart() {
	print("----------------------------------------------");
	print("| " + GetServerName() + "");
	if (GetPassword() != "") print("| 密码: " + GetPassword() + "");
	print("----------------------------------------------");
	print("脚本加载完成!");
}

function onServerStop() {}

function onScriptLoad() {
	db <- ConnectSQL("database.db");
	QuerySQL(db, "CREATE TABLE IF NOT EXISTS Maps(Name TEXT,ObjCount TEXT)");
	QuerySQL(db, "CREATE TABLE IF NOT EXISTS LastPos(Name TEXT,LastPos TEXT)");


	srand(time());
	state <- array(GetMaxPlayers(), null);
	AddClass(1, RGB(255, 255, 255), 0, Vector(-59.5646, 86.5718, 17.6282), 1.90207, 32, 9999, 0, 0, 0, 0);

	Key_Enter <- BindKey(true, 0x0D, 0, 0);
	Key_BackSpace <- BindKey(true, 0x08, 0, 0);
	Key_Shift <- BindKey(true, 0x10, 0, 0);
	Key_Ctrl <- BindKey(true, 0x11, 0, 0);
	Key_Alt <- BindKey(true, 0x12, 0, 0);
	Key_PageUp <- BindKey(true, 0x21, 0, 0);
	Key_PageDown <- BindKey(true, 0x22, 0, 0);
	Key_Left <- BindKey(true, 0x25, 0, 0);
	Key_Up <- BindKey(true, 0x26, 0, 0);
	Key_Right <- BindKey(true, 0x27, 0, 0);
	Key_Down <- BindKey(true, 0x28, 0, 0);
	Key_Delete <- BindKey(true, 0x2E, 0, 0);
	Key_1 <- BindKey(true, 0x31, 0, 0);
	Key_2 <- BindKey(true, 0x32, 0, 0);
	Key_3 <- BindKey(true, 0x33, 0, 0);
	Key_4 <- BindKey(true, 0x34, 0, 0);
	Key_C <- BindKey(true, 0x43, 0, 0);
	Key_E <- BindKey(true, 0x45, 0, 0);
	Key_W <- BindKey(true, 0x57, 0, 0);
	Key_X <- BindKey(true, 0x58, 0, 0);
	Key_R <- BindKey(true, 0x52, 0, 0);
	Key_T <- BindKey(true, 0x54, 0, 0);
	Key_RButton <- BindKey(true, 0x02, 0, 0);
	Key_LButton <- BindKey(true, 0x01, 0, 0);

	SetGravity(0.008);
	SetGamespeed(1);
	SetFallTimer(500);
	SetWaterLevel(6);
	SetMaxHeight(20000);
	SetVehiclesForcedRespawnHeight(20000);
	SetWorldBounds(5000, -5000, 5000, -5000);
	SetFriendlyFire(false);
	SetDeathMessages(true);
	SetSyncFrameLimiter(false);
	SetFrameLimiter(false);
	SetShootInAir(false);
	SetJoinMessages(true);
	SetShowNametags(true);
	SetStuntBike(true);
	SetWallglitch(false);
	SetBackfaceCullingDisabled(true);
	SetHeliBladeDamageDisabled(true);
	SetKillDelay(3000);
	SetServerName("[0.4] 地图建造工具 v1.7");
	SetGameModeName("创造模式");

	ObjMarker <- {};
	WorldMap <- null;
	AutoSave <- 0;
	AutoSaveOn <- true;
	AutoSaveTime <- 600;
	SpeedArr <- [];
	NewTimer("onScriptProcess", 1000, 0);
	Author <- "Unknown";
	LBTimer <- null;
	ConvertHigh <- 0;
	ConvertClear <- "true";
	ConvertSaveKb <- 360;
	ConvertXmlFix <- 1;
	AutoAlignment <- "false";
	MapHideCount <- 0;
	MapHideID <- {};
	MapHidePos <- {};
	ConvertHideID <- {};
	ConvertHidePos <- {};
	ConvertHideAngle <- {};
	ConvertHideAlpha <- {};

	CreateVehicle(191, 1, Vector(-56.5527, 80.926, 17.0514), 5.18298, 2, 2);

	local text = ReadTextFromFile("export/ipl convert/convert.cfg");
	local arr = split(text, "\n");
	if (arr && arr.len() >= 1) {
		local arr2 = split(arr[0], " ");
		if (arr2.len() >= 2) ConvertHigh = arr2[1].tointeger();
	}
	if (arr.len() >= 2) {
		local arr2 = split(arr[1], " ");
		if (arr2.len() >= 2) ConvertClear = arr2[1];
	}
	if (arr.len() >= 3) {
		local arr2 = split(arr[2], " ");
		if (arr2.len() >= 2) ConvertSaveKb = arr2[1].tointeger();
	}
	if (arr.len() >= 4) {
		local arr2 = split(arr[3], " ");
		if (arr2.len() >= 2)
			if (arr2[1] == "true") ConvertXmlFix = -1;
	}

	local convert = true;
	local myfile = file("export/ipl convert/ipl.txt", "rb");
	if (myfile.len() > 0) {
		if (myfile.len() / 1000 <= ConvertSaveKb) print("检测到IPL转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 正在读取代码中...");
		else {
			convert = false;
			print("检测到IPL转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 由于文件的大小超过设置的安全范围 (" + ConvertSaveKb + "kb), 因此不会启动转换.");
		}
	}

	if (convert == true) {
		local text = ReadTextFromFile("export/ipl convert/ipl.txt");
		local arr = split(text, "\n");
		if (arr.len() >= 1) {
			print("成功读取文件内 " + arr.len() + " 行代码, 正在转换中...");

			local doarr = [336, 339, 340, 341, 348, 351, 352, 354, 355, 357, 358, 359, 360, 361, 384, 386, 387, 388, 389, 390, 391, 392, 393, 394, 396, 397, 400, 401, 402, 403, 404, 414, 417, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 924, 925, 2204, 2208, 2211, 2223, 2229, 2076, 2077, 2121, 2122, 2123, 2124, 2125, 4197, 4198, 4199, 4298, 4299, 4202, 2939, 3038, 3037, 1108, 1163, 1164, 2540, 2492, 4028, 4029, 4023, 4026, 4070, 4073, 4074, 477, 467, 3494, 3495, 3496, 3497, 3498, 3499, 3500, 3501, 3502, 3503, 3504, 3505, 3506, 3507, 3517, 3493, 3508, 3616, 3624, 3779, 3554, 1921, 478, 446, 447, 445, 474, 469, 459, 448, 449, 444, 440, 441, 442, 443, 1252, 1253, 1254, 1454, 1236, 1258, 3039, 3040, 3042, 3041, 3043, 3044, 3045, 3046, 3047, 3048, 1994, 1998, 1997, 1999];
			//local doarr=[924,925,2204,2208,2211,2223,2229,2076,2077,2121,2122,2123,2124,2125,4197,4198,4199,4298,4299,4202,2939,3038,3037,1108,1163,1164,2540,2492,4028,4029,4023,4026,4070,4073,4074,477,467,3494,3495,3496,3497,3498,3499,3500,3501,3502,3503,3504,3505,3506,3507,3517,3493,3508,3616,3624,3779,3554,1921,478,446,447,445,474,469,459,448,449,444,440,441,442,443,1252,1253,1254,1454,1236,1258,3039,3040,3042,3041,3043,3044,3045,3046,3047,3048,1994,1998,1997,1999];

			doarr.append(1426);
			doarr.append(1427);
			doarr.append(1391);
			doarr.append(1269);
			doarr.append(1268);
			doarr.append(2070);
			doarr.append(2069);
			doarr.append(2071);
			doarr.append(2066);
			doarr.append(2067);
			doarr.append(2065);
			doarr.append(2071);
			doarr.append(1794);
			doarr.append(1793);
			doarr.append(1859);
			doarr.append(3522);
			doarr.append(3523);
			doarr.append(3524);
			for (local i = 0; i < arr.len(); i++) {
				local arr2 = split(arr[i], ",");
				if (arr2 && arr2.len() >= 12) {
					local f = false;
					local a = arr2[0].tostring();

					for (local ii = 0; ii < doarr.len(); ii++) {
						if (a.tointeger() == doarr[ii]) {
							f = true;
							break;
						}
					}

					if (f == true) {
						//local o=CreateObject(arr2[0].tointeger(),1,Vector(arr2[3].tofloat(),arr2[4].tofloat(),arr2[5].tofloat()+ConvertHigh),255);
						//o.RotateTo(Quaternion(arr2[9].tofloat(),arr2[10].tofloat(),arr2[11].tofloat(),arr2[12].tofloat()),0);
						TXTAddLine("Hide.nut", "HideMapObject(" + arr2[0].tointeger() + "," + FixFloat(arr2[3]) + "," + FixFloat(arr2[4]) + "," + FixFloat(arr2[5]) + ");");

						//TXTAddLine("hide.nut","<rule model=\""+arr2[0].tointeger()+"\">");
						//TXTAddLine("hide.nut","     <position x=\""+FixFloat(arr2[3])+"\" y=\""+FixFloat(arr2[4])+"\" z=\""+FixFloat(arr2[5])+"\" />");
						//TXTAddLine("hide.nut","</rule>");
					}
				}
			}
			ConvertMap("ipl");
		}
	}

	local convert = true;
	local myfile = file("export/ipl convert/xml.txt", "rb");
	if (myfile.len() > 0) {
		if (myfile.len() / 1000 <= ConvertSaveKb) print("检测到XML转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 正在读取代码中...");
		else {
			convert = false;
			print("检测到XML转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 由于文件的大小超过设置的安全范围 (" + ConvertSaveKb + "kb), 因此不会启动转换.");
		}
	}

	if (convert == true) {
		local text = ReadTextFromFile("export/ipl convert/xml.txt");
		local arr = split(text, "\n");
		if (arr.len() >= 1) {
			print("成功读取文件内 " + arr.len() + " 行代码, 正在转换中...");

			local marr = [], posarr = [], rotarr = [];
			for (local i = 0; i < arr.len(); i++) {
				local model = GetTextBetween(arr[i], "model=", " name");
				if (model != null) {
					model = model.slice(1, model.len() - 1);
					marr.append(model.tointeger());
				}

				local x = GetTextBetween(arr[i], "x=", " y"), y = GetTextBetween(arr[i], "y=", " z"), z = GetTextBetween(arr[i], "z=", " "), w = GetTextBetween(arr[i], "angle=", " ");
				if (x != null && y != null && z != null) {
					x = x.slice(1, x.len() - 1);
					y = y.slice(1, y.len() - 1);
					z = z.slice(1, z.len() - 1);
					posarr.append(Vector(x.tofloat(), y.tofloat(), z.tofloat()));

					if (w != null) {
						w = w.slice(1, w.len() - 1);
						posarr.remove(posarr.len() - 1);
						rotarr.append(Quaternion(x.tofloat(), y.tofloat(), z.tofloat(), w.tofloat() * ConvertXmlFix));
					}
				}
			}

			for (local i = 0; i < marr.len(); i++) {
				local pos = posarr[i];
				local o = CreateObject(marr[i].tointeger(), 1, Vector(pos.x, pos.y, pos.z + ConvertHigh), 255);
				o.RotateTo(rotarr[i], 0);
			}
			ConvertMap("xml");
		}
	}

	local text = ReadTextFromFile("server.cfg");
	local arr = split(text, "\n");
	if (arr.len() >= 3) {
		local arr2 = split(arr[3], " ");
		for (local i = 1; i < arr2.len() - 1; i++) SpeedArr.append(arr2[i].tofloat());
	}
	if (arr.len() >= 4) {
		local arr2 = split(arr[4], " ");
		if (arr2.len() >= 2) Author = arr2[1];
	}
	if (arr.len() >= 5) {
		local arr2 = split(arr[5], " ");
		if (arr2.len() >= 2)
			if (AutoSaveTime >= 300) AutoSaveTime = arr2[1].tointeger();
	}
	if (arr.len() >= 6) {
		local arr2 = split(arr[6], " ");
		if (arr2.len() >= 2) {
			if (arr2[1] != "null") {
				LoadMap(arr2[1]);
				if (WorldMap != null) print("成功加载初始地图 " + WorldMap + " 上的" + GetObjectCount() + "个建筑.");
				else print("地图 " + arr2[1] + " 未能成功加载.");
			}
		}
	}
	if (arr.len() >= 7) {
		local arr2 = split(arr[7], " ");
		if (arr2.len() >= 2) AutoAlignment = arr2[1];
	}
}

function onScriptUnload() {}

function onScriptProcess() {
	if (AutoSaveOn == true) {
		if (WorldMap != null) {
			AutoSave += 1;
			if (AutoSave == AutoSaveTime - 60) Message("[#00FF00](Auto-Save) [#FFFFFF]" + WorldMap + " will saved in " + (AutoSaveTime - AutoSave) + " seconds.");
			if (AutoSave == AutoSaveTime - 20) Message("[#00FF00](Auto-Save) [#FFFFFF]" + WorldMap + " will saved in " + (AutoSaveTime - AutoSave) + " seconds.");
			if (AutoSave == AutoSaveTime - 10) Message("[#00FF00](Auto-Save) [#FFFFFF]" + WorldMap + " will saved in " + (AutoSaveTime - AutoSave) + " seconds.");
			if (AutoSave == AutoSaveTime - 5) Message("[#00FF00](Auto-Save) [#FFFFFF]" + WorldMap + " will saved in " + (AutoSaveTime - AutoSave) + " seconds.");
			if (AutoSave >= AutoSaveTime) {
				AutoSave = 0;
				SaveMap();
				BackUpMap();
			}
		} else if (AutoSave != 0) AutoSave = 0;
	}
}

function onTimeChange(LastHour, LastMinute, NewHour, NewMinute) {}

function FixFloat(a) {
	if (a.tostring().find(".") == null) {
		a = "" + a + ".0";
	}
	return a;
}

//============================== P L A Y E R  E V E N T S ==============================

function onPlayerJoin(player) {
	state[player.ID] = PlayerClass(player.Name);
	state[player.ID].speed = SpeedArr[state[player.ID].speedarr];
	MessagePlayer("[#FFFF00]Welcome to pq's Map Editor Reborn!", player);

	if (WorldMap != null) MessagePlayer("[#00FF00]The current edit map is [#FFFFFF]'" + WorldMap + "'", player);
	print("玩家 [" + player.Name + "] 于 " + GetTime() + " 加入了服务器!");
}

function onPlayerPart(player, reason) {
	if (state[player.ID].keyttimer != null) {
		state[player.ID].keyttimer.Delete();
		state[player.ID].keyttimer = null;
	}

	state[player.ID] = null;

	local lastpos = "" + player.Pos.x + "," + player.Pos.y + "," + player.Pos.z + "," + player.Angle + "";
	QuerySQL(db, "INSERT INTO LastPos(Name,LastPos)VALUES('" + player.Name + "','" + lastpos + "')");
	print("玩家 [" + player.Name + "] 的位置信息保存成功!");
}

function onPlayerRequestClass(player, classID, team, skin) {
	if (state[player.ID].firstspawn == false) {
		SendDataToClient(player, StreamType.SendSpeed, state[player.ID].speed.tofloat());
		SendDataToClient(player, StreamType.SendObjArrLen, state[player.ID].objarrlen);

		if (WorldMap != null) UpdateMapInfo(player.ID);
	}
	player.Spawn();
	return 1;
}

function onPlayerRequestSpawn(player) {
	return 1;
}

function onPlayerSpawn(player) {
	if (state[player.ID].firstspawn == false) {
		state[player.ID].firstspawn = true;

		local q = QuerySQL(db, "SELECT * FROM LastPos WHERE Name='" + player.Name + "'");
		if (q) {
			local data = GetSQLColumnData(q, 1);
			local arr = split(data, ",");
			if (arr) {
				player.Pos = Vector(arr[0].tofloat(), arr[1].tofloat(), arr[2].tofloat());
				player.Angle = arr[3].tofloat();
			}
			QuerySQL(db, "DELETE FROM LastPos WHERE Name='" + player.Name + "'");
			print("成功将玩家 [" + player.Name + "] 恢复到他上次离开的位置!");
		}
	}

	if (state[player.ID].diepos != null) player.Pos = state[player.ID].diepos;
}

function onPlayerDeath(player, reason) {
	state[player.ID].diepos = player.Pos;
}

function onPlayerKill(player, killer, reason, bodypart) {
	onPlayerDeath(killer, reason);
}

function onPlayerTeamKill(player, killer, reason, bodypart) {
	onPlayerKill(player, killer, reason, bodypart);
}

function onPlayerChat(player, text) {
	local find = false;
	if (Author != "Unknow") {
		if (player.Name == Author) {
			find = true;
			Message("[#FFFF00][Author] " + GetPlayerColor(player.ID) + player.Name + "[#FFFFFF]: " + text);
			TXTAddLine("聊天日志.txt", "[" + GetTime() + "] [作者] " + player.Name + ": " + text);
		}
	}
	if (find == false) {
		Message("" + GetPlayerColor(player.ID) + player.Name + "[#FFFFFF]: " + text);
		TXTAddLine("聊天日志.txt", "[" + GetTime() + "] " + player.Name + ": " + text);
	}

	//print(player.Name+": "+text);
}

function onPlayerCommand(player, cmd, text) {
	if (cmd && cmd != "") {
		cmd = cmd.tolower();
		if (text) print("玩家 [" + player.Name + "] 使用指令 [" + cmd + "] + [" + text + "]");
		else print("玩家 [" + player.Name + "] 使用指令 [" + cmd + "]");
	}

	//Basic
	if (cmd == "fps") {
		MessagePlayer("[#00FF00]FPS: " + player.FPS, player);
	} else if (cmd == "fix") {
		if (player.Vehicle) player.Vehicle.Fix();
	} else if (cmd == "ff" || cmd == "filp") {
		if (player.Vehicle) player.Vehicle.Rotation = Multiply(player.Vehicle.Rotation, ss(PI));
	} else if (cmd == "s") {
		TXTAddLine("export/记录坐标.txt", "" + player.Pos.x + "," + player.Pos.y + "," + player.Pos.z + "");
		Announce("~y~Pos Saved!", player, 0);
	} else if (cmd == "p") {
		if (player.Vehicle) {
			MessagePlayer("Vector(" + player.Vehicle.Pos.x + "," + player.Vehicle.Pos.y + "," + player.Vehicle.Pos.z + ")", player);
			MessagePlayer(player.Vehicle.GetRadiansAngleEx().tostring, player);
		} else {
			MessagePlayer("Vector(" + player.Pos.x + "," + player.Pos.y + "," + player.Pos.z + ")", player);
			MessagePlayer(player.Angle.tostring, player);
		}
	} else if (cmd == "fly") {
		state[player.ID].fly = !state[player.ID].fly;
		MessagePlayer("[#00FF00]Your fly mode is (" + state[player.ID].fly + ")", player);
	} else if (cmd == "autosave") {
		AutoSaveOn = !AutoSaveOn;
		MessagePlayer("[#00FF00]Auto save mode is (" + AutoSaveOn + ")", player);
	} else if (cmd == "delallveh") {
		if (GetVehicleCount() == 0) {
			MessagePlayer("[#FF0000]There are no vehicles on the server.", player);
			return;
		}
		MessagePlayer("[#FFFF00]" + GetVehicleCount() + " vehicles has been deleted.", player);
		for (local i = 0; i <= 1000; i++) {
			local veh = FindVehicle(i);
			if (veh) veh.Delete();
		}
		print("玩家 [" + player.Name + "] 删除了所有载具!");
	} else if (cmd == "cc" || cmd == "car" || cmd == "getcar") {
		if (text && text != "") {
			if ((IsNum(text) && text.tointeger() >= 130 && text.tointeger() <= 236) || (GetVehicleModelFromName(text) >= 130 && GetVehicleModelFromName(text) <= 236) || (IsNum(text) && text.tointeger() >= 6400)) CreateVehForPlr(player.ID, text);
			else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<VehName/ID>", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<VehName/ID>", player);
	} else if (cmd == "tp") {
		if (text && text != "" && IsNum(text) && text.tointeger() >= 1) {
			if (state[player.ID].tp == null) state[player.ID].tp = {};

			if (state[player.ID].tp.rawin(text.tointeger())) {
				local arr = split(state[player.ID].tp.rawget(text.tointeger()), ",");
				if (player.Vehicle) player.Vehicle.Pos = Vector(arr[0].tofloat(), arr[1].tofloat(), arr[2].tofloat());
				else {
					player.Pos = Vector(arr[0].tofloat(), arr[1].tofloat(), arr[2].tofloat());
					player.Angle = arr[3].tofloat();
				}
				MessagePlayer("[#00FF00]Return the position successfully!", player);
			} else {
				state[player.ID].tp.rawset(text.tointeger(), "" + player.Pos.x + "," + player.Pos.y + "," + player.Pos.z + "," + player.Angle + "");
				MessagePlayer("[#00FF00]Record the position successfully, type [#FFFFFF]'/" + cmd + " " + text + "' [#00FF00]again can return.", player);
			}
		}
	} else if (cmd == "hide") {
		if (state[player.ID].hide == false) {
			state[player.ID].hide = true;
			SendDataToClient(player, StreamType.SendHide);
		}
	} else if (cmd == "hidelist") {
		if (MapHideCount > 0) {
			for (local i = 1; i <= MapHideCount; i++) {
				if (MapHideID.rawin(i)) {
					local id = MapHideID.rawget(i);
					MessagePlayer("[#00FF00]ID: [#FFFFFF]" + i + " [#FFFF00]| [#00FF00]Model: [#FFFFFF]" + id + "", player);
				}
			}
		} else MessagePlayer("[#FF0000]You haven't hidden any buildings yet.", player);
	} else if (cmd == "show") {
		if (MapHideCount > 0 && MapHideID.len() > 0) {
			if (text && text != "all") {
				if (IsNum(text) && text.tointeger() > 0) {
					if (MapHideID.rawin(text.tointeger())) {
						local id = MapHideID.rawget(text.tointeger());
						local pos = MapHidePos.rawget(text.tointeger());
						ShowMapObject(id, pos.x, pos.y, pos.z);
						MapHideID.rawdelete(text.tointeger());
						MapHidePos.rawdelete(text.tointeger());
						MessagePlayer("[#00FF00]ID: " + text + " object is showed now!", player);
					} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<ID/All>", player);
				} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<ID/All>", player);
			} else if (text == "all") {
				ShowAllMapObjects();
				MapHideID.clear();
				MapHidePos.clear();
				MapHideCount = 0;
				MessagePlayer("[#00FF00]No objects are hidden now!", player);
				print("玩家 [" + player.Name + "] 恢复了所有隐藏的原版建筑.");
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<ID/All>", player);
		} else MessagePlayer("[#FF0000]You haven't hidden any buildings yet.", player);
	} else if (cmd == "exec") {
		if (text && text != "") {
			try {
				local script = compilestring(text);
				script();
				MessagePlayer("[#FFFF00]Loading Code: " + text + "", player);
			} catch (e) MessagePlayer("[#FF0000]Error: " + e, player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Squirrel Code>", player);
	} else if (cmd == "col") {
		if (player.Vehicle != null) {
			if (text && text != "") {
				local arr = split(text, " ");
				if (arr && arr.len() == 2 && typeof(GetArgValue(arr[0])) == "integer" && arr[0].tointeger() >= 0 && arr[0].tointeger() <= 94 && typeof(GetArgValue(arr[1])) == "integer" && arr[1].tointeger() >= 0 && arr[1].tointeger() <= 94) {
					player.Vehicle.Colour1 = arr[0].tointeger();
					player.Vehicle.Colour2 = arr[1].tointeger();
				} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Col1> <Col2>", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Col1> <Col2>", player);
		}
	} else if (cmd == "exportveh") {
		for (local i = 0; i < 1000; i++) {
			local veh = FindVehicle(i);
			if (veh) {
				TXTAddLine("export/导出车辆.nut", "CreateVehicle(" + veh.Model + ",1,Vector(" + veh.Pos.x + "," + veh.Pos.y + "," + veh.Pos.z + ")," + veh.GetRadiansAngle() + "," + veh.Colour1 + "," + veh.Colour2 + ");");
			}
		}
		Message("[#FFFF00]File done!");
	}

	//Map
	else if (cmd == "createmap" || cmd == "cmap") {
		if (WorldMap == null) {
			if (text && text != "" && IsNum(text) == false) {
				local q = QuerySQL(db, "SELECT * FROM Maps WHERE Name='" + text + "'");
				if (q) MessagePlayer("[#FF0000]You've already created this map.", player);
				else {
					QuerySQL(db, "INSERT INTO Maps(Name,ObjCount)VALUES('" + text + "','0')");
					QuerySQL(db, "CREATE TABLE IF NOT EXISTS " + text + "(ID INTEGER,Model INTEGER,Info TEXT,Alpha INTEGER)");
					WorldMap = text;
					UpdateMapInfo(player.ID);
					MessagePlayer("[#00FF00]Map [#FFFFFF]'" + text + "' [#00FF00]created successfully, now you can add objects.", player);
					AutoSave = 0;
				}
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Map Name>", player);
		} else MessagePlayer("[#FF0000]You must close the current map in order to do this.", player);
	} else if (cmd == "loadmap") {
		if (WorldMap == null) {
			if (text && text != "" && IsNum(text) == false) {
				local q = QuerySQL(db, "SELECT * FROM Maps WHERE Name='" + text + "'");
				if (q) {
					LoadMap(text);
					AutoSave = 0;
				} else MessagePlayer("[#FF0000]This map doesn't exist.", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Map Name>", player);
		} else MessagePlayer("[#FF0000]You must close the current map in order to do this.", player);
	} else if (cmd == "savemap") {
		if (WorldMap != null) SaveMap();
		else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "closemap") {
		if (WorldMap != null) CloseMap("save");
		else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "exportmap") {
		if (WorldMap != null) ExportMap();
		else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "abandmap") {
		if (WorldMap != null) CloseMap("aband");
		else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "maplist") {
		if (GetSQLRowCount("Maps") >= 1) {
			local q = QuerySQL(db, "SELECT * FROM Maps"), count = 0;
			do {
				count += 1;
				MessagePlayer("[#FFFF00]" + count + "[#FFFFFF]. [#00FF00]" + GetSQLColumnData(q, 0) + " [#FFFFFF]|  [#FFFF00]ObjCount[#FFFFFF]: [#00FF00]" + GetSQLColumnData(q, 1), player);
			}
			while (GetSQLNextRow(q))
		} else MessagePlayer("[#FF0000]There's no map in the database.", player);
	}

	//Object
	else if (cmd == "addobj") {
		if (WorldMap != null) {
			if (text && text != "" && IsNum(text) && text.tointeger() >= 300) {
				local obj = CreateObject(text.tointeger(), player.World, player.Pos, 0);
				if (obj) {
					if (AutoAlignment == "true") obj.RotateTo(EulerToQuaternion(0, 0, AlignmentAngle(player.Pos.x, player.Pos.y, obj.Pos.x, obj.Pos.y)), 0);
					obj.SetAlpha(255, 500);
					obj.TrackingShots = true;
					state[player.ID].obj = obj;
					UpdateObjInfo(player.ID);
					CreateObjMarker(obj.ID, "c");
					SaveObject(obj.ID);
					UpdateMapInfo(player.ID);
					MessagePlayer("[#00FF00]You created object with Model [#FFFFFF]'" + obj.Model + "' [#00FF00]and ID [#FFFFFF]'" + obj.ID + "'", player);

					if (state[player.ID].objarr != null) SendDataToClient(player, StreamType.ObjArrSpr, "null");
				}
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<ID>", player);
		} else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "caddobj") {
		if (WorldMap != null) {
			if (state[player.ID].cadd == false) {
				state[player.ID].cadd = true;
				SendDataToClient(player, StreamType.SendCAdd);
			}
		} else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "dofile") {
		if (WorldMap != null) {
			if (text && text != "") {
				local f = null;
				try {
					f = file("export/" + text + ".nut", "rb+");
				} catch (e) f = null;

				if (f != null) {
					local a = [], b = [];
					for (local i = 0; i <= 3000; i++) {
						local obj = FindObject(i);
						if (obj) a.append(obj.ID);
					}
					dofile("export/" + text + ".nut");
					for (local i = 0; i <= 3000; i++) {
						local obj = FindObject(i);
						if (obj) {
							obj.TrackingShots = true;
							CreateObjMarker(obj.ID, "c");
						}
					}
					for (local i = 0; i <= GetMaxPlayers(); i++) {
						local plr = FindPlayer(i);
						if (plr) UpdateMapInfo(plr.ID);
					}
					for (local i = 0; i <= 3000; i++) {
						local obj = FindObject(i);
						if (obj) {
							local find = false;
							for (local i = 0; i < a.len(); i++) {
								if (obj.ID == a[i]) {
									find = true;
									break;
								}
							}
							if (find == false) b.append(obj.ID);
						}
					}
					state[player.ID].objarr = b;
					if (state[player.ID].obj != null) {
						state[player.ID].obj = null;
						UpdateObjInfo(player.ID);
					}
					UpdateObjArrInfo(player.ID);
					Message("[#FFFF00]The object on file [#FFFFFF]'" + text + ".nut' [#FFFF00]has been successfully loaded onto the current map!");
				} else MessagePlayer("[#FF0000]Please enter the correct file name.", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<File Name>", player);
		} else MessagePlayer("[#FF0000]You have to create or load a map in order to do this.", player);
	} else if (cmd == "copy") {
		if (state[player.ID].obj != null || state[player.ID].objarr != null) {
			if (text && text != "") {
				local arr = split(text, " ");
				if (arr && arr.len() >= 1 && (arr[0] == "before" || arr[0] == "after" || arr[0] == "left" || arr[0] == "right" || arr[0] == "up" || arr[0] == "down")) {
					if (arr.len() >= 2 && IsNum(arr[1]) && arr[1].tointeger() >= 1) {
						if (arr.len() == 3 && IsNum(arr[2])) {
							if (state[player.ID].obj != null) {
								local obj = state[player.ID].obj, a = player.Angle, count = 0;

								if (arr[0] == "after") a = a - PI;
								if (arr[0] == "left") a = a + (PI / 2);
								if (arr[0] == "right") a = a - (PI / 2);

								for (local i = 0; i < arr[1].tointeger(); i++) {
									count += 1;
									local pos = null, x = 0, y = 0, z = 0;
									if (arr[0] == "up" || arr[0] == "down") {
										z = (i + 1) * arr[2].tointeger();
										if (arr[0] == "up") pos = Vector(obj.Pos.x, obj.Pos.y, obj.Pos.z + z);
										if (arr[0] == "down") pos = Vector(obj.Pos.x, obj.Pos.y, obj.Pos.z - z);
									} else {
										x = (i + 1) * arr[2].tointeger() * sin(a), y = (i + 1) * arr[2].tointeger() * cos(a);
										pos = Vector(obj.Pos.x - x, obj.Pos.y + y, obj.Pos.z);
									}
									local obj2 = CreateObject(obj.Model, player.World, pos, obj.Alpha);
									obj2.RotateTo(obj.Rotation, 0);
									obj2.TrackingShots = true;
									CreateObjMarker(obj2.ID, "c");
								}

								UpdateObjInfo(player.ID);
								MessagePlayer("[#00FF00]" + count + " objects were successfully copiedt.", player);
							} else if (state[player.ID].objarr != null) {
								local obj = null, a = player.Angle, count = 0;
								for (local i = 0; i < state[player.ID].objarr.len(); i++) {
									local obj = FindObject(state[player.ID].objarr[i]);
									if (obj) {
										if (arr[0] == "after") a = a - PI;
										if (arr[0] == "left") a = a + (PI / 2);
										if (arr[0] == "right") a = a - (PI / 2);

										for (local i = 0; i < arr[1].tointeger(); i++) {
											count += 1;
											local pos = null, x = 0, y = 0, z = 0;
											if (arr[0] == "up" || arr[0] == "down") {
												z = (i + 1) * arr[2].tointeger();
												if (arr[0] == "up") pos = Vector(obj.Pos.x, obj.Pos.y, obj.Pos.z + z);
												if (arr[0] == "down") pos = Vector(obj.Pos.x, obj.Pos.y, obj.Pos.z - z);
											} else {
												x = (i + 1) * arr[2].tointeger() * sin(a), y = (i + 1) * arr[2].tointeger() * cos(a);
												pos = Vector(obj.Pos.x - x, obj.Pos.y + y, obj.Pos.z);
											}
											local obj2 = CreateObject(obj.Model, player.World, pos, obj.Alpha);
											obj2.RotateTo(obj.Rotation, 0);
											obj2.TrackingShots = true;
											CreateObjMarker(obj2.ID, "c");
										}
									}
								}
								UpdateObjInfo(player.ID);
								MessagePlayer("[#00FF00]" + count + " objects were successfully copiedt.", player);
							}
						} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> <" + arr[1] + "> [#FF0000]<Interval>", player);
					} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> [#FF0000]<Quantity> <Interval>", player);
				} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Direction> <Quantity> <Interval>", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Direction> <Quantity> <Interval>", player);
		} else MessagePlayer("[#FF0000]You must first choose an object.", player);
	} else if (cmd == "setalpha") {
		if (state[player.ID].obj != null) {
			if (text && text != "" && IsNum(text) && text.tointeger() >= 0 && text.tointeger() <= 255) {
				state[player.ID].obj.SetAlpha(text.tointeger(), 250);
				UpdateObjInfo(player.ID);
				MessagePlayer("[#00FF00]You set object's alpha to " + text + ".", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<0~255>", player);
		} else MessagePlayer("[#FF0000]You must first choose an object.", player);
	} else if (cmd == "saveobj") {
		if (state[player.ID].obj != null) {
			local obj = state[player.ID].obj;
			SaveObject(obj.ID);
			ObjVaguelyVisible(obj.ID);
			MessagePlayer("[#00FF00]The object was saved successfully!", player);
		} else MessagePlayer("[#FF0000]You must first choose an object.", player);
	} else if (cmd == "selectobj" || cmd == "selobj" || cmd == "objsel") {
		if (GetObjectCount() >= 1) {
			local olddis = 5000, newdis = 0, id = 0;
			for (local i = 0; i <= 3000; i++) {
				local obj = FindObject(i);
				if (obj) {
					if (CheckObjNotEditedForPlr(obj.ID, player.ID) == false) {
						newdis = DistanceFromPoint(player.Pos.x, player.Pos.y, obj.Pos.x, obj.Pos.y);
						if (newdis <= olddis) olddis = newdis, id = i;
					}
				}
			}

			if (text && text == "m") {
				local object = FindObject(id);
				if (state[player.ID].objarr == null) {
					local b = [];
					if (state[player.ID].obj != null) {
						b.append(state[player.ID].obj.ID);
						state[player.ID].obj = null;
						UpdateObjInfo(player.ID);
					}
					b.append(object.ID);
					ObjVaguelyVisible(id);
					state[player.ID].objarr = b;
					UpdateObjArrInfo(player.ID);
					MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
				} else {
					local find = false;
					for (local i = 0; i < state[player.ID].objarr.len(); i++)
						if (object.ID == state[player.ID].objarr[i]) find = true;
					if (find == false) {
						state[player.ID].objarr.append(object.ID);
						UpdateObjArrInfo(player.ID);
						ObjVaguelyVisible(id);
						MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
					}
				}
			} else {
				state[player.ID].obj = FindObject(id);
				UpdateObjInfo(player.ID);
				ObjVaguelyVisible(id);
				MessagePlayer("[#00FF00]You select the object ID " + id + " nearest to you.", player);
				if (state[player.ID].objarr != null) SendDataToClient(player, StreamType.ObjArrSpr, "null");
			}
		} else MessagePlayer("[#FF0000]There are no objects in the server.", player);
	} else if (cmd == "setcross") {
		if (text && text != "" && IsNum(text) && text.tointeger() >= 0 && text.tointeger() <= 150) {
			state[player.ID].objarrlen = text.tointeger();
			SendDataToClient(player, StreamType.SendObjArrLen, state[player.ID].objarrlen);
			if (state[player.ID].objarrlen == 0) state[player.ID].objarrsee = false;
			else if (state[player.ID].objarrsee == false) state[player.ID].objarrsee = true;
			MessagePlayer("[#00FF00]You set the number of cue centers to " + state[player.ID].objarrlen + ".", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<0~150>", player);
	} else if (cmd == "setcpos") {
		if (state[player.ID].obj == null) {
			state[player.ID].rtxpos = player.Pos;
			state[player.ID].rtxobjid = null;
			MessagePlayer("[#00FF00]You set absolute rotation pos to (" + player.Pos.x + "," + player.Pos.y + "," + player.Pos.z + ")", player);
		} else {
			state[player.ID].rtxobjid = state[player.ID].obj.ID;
			state[player.ID].rtxpos = null;
			MessagePlayer("[#00FF00]You set absolute rotation pos to ID " + state[player.ID].obj.ID + " object.", player);
		}
	}

	//Other
	else if (cmd == "doconvert") {
		if (WorldMap != null) {
			if (GetObjectCount() > 0) {
				for (local i = 0; i <= 3000; i++) {
					local obj = FindObject(i);
					if (obj) {
						ConvertHideID.rawset(obj.ID, obj.Model);
						ConvertHidePos.rawset(obj.ID, obj.Pos);
						ConvertHideAngle.rawset(obj.ID, obj.Rotation);
						ConvertHideAlpha.rawset(obj.ID, obj.Alpha);
						obj.Delete();
					}
				}
				MessagePlayer("[#FFFF00]In order not to affect the conversion map, the current building is temporarily hidden.", player);
			}
		}

		local convert = true;
		local myfile = file("export/ipl convert/ipl.txt", "rb");
		if (myfile.len() > 0) {
			if (myfile.len() / 1000 <= ConvertSaveKb) {
				print("检测到IPL转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 正在读取代码中...");
				MessagePlayer("[#00FF00]Detected [#FFFFFF]'" + (myfile.len() / 1000) + "kb' [#00FF00]of code in [#FFFFFF]'IPL' [#00FF00]converter, reading code...", player);
			} else {
				convert = false;
				print("检测到IPL转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 由于文件的大小超过设置的安全范围 (" + ConvertSaveKb + "kb), 因此不会启动转换.");
				MessagePlayer("[#FFFFFF]'" + (myfile.len() / 1000) + "kb' [#FFFF00]code detected in the [#FFFFFF]'IPL' [#FFFF00]converter. ", player);
				MessagePlayer("[#FFFF00]The conversion will not start because the file size exceeds the set safety range [#FFFFFF](" + ConvertSaveKb + "kb)", player);
			}
		}

		if (convert == true) {
			local text = ReadTextFromFile("export/ipl convert/ipl.txt");
			local arr = split(text, "\n");
			if (arr.len() >= 1) {
				print("成功读取文件内 " + arr.len() + " 行代码, 正在转换中...");
				MessagePlayer("[#00FF00]Read the [#FFFFFF]'" + arr.len() + "' [#00FF00]line of code in the file successfully, is being converted...", player);
				for (local i = 0; i < arr.len(); i++) {
					local arr2 = split(arr[i], ",");
					if (arr2 && arr2.len() >= 12) {
						local o = CreateObject(arr2[0].tointeger(), 1, Vector(arr2[3].tofloat(), arr2[4].tofloat(), arr2[5].tofloat() + ConvertHigh), 255);
						o.RotateTo(Quaternion(arr2[9].tofloat(), arr2[10].tofloat(), arr2[11].tofloat(), arr2[12].tofloat()), 0);
					}
				}
				ConvertMap("ipl");
				MessagePlayer("[#00FF00]The code conversion in [#FFFFFF]'IPL' [#00FF00]converter is complete!", player);
			}
		}

		local convert = true;
		local myfile = file("export/ipl convert/xml.txt", "rb");
		if (myfile.len() > 0) {
			if (myfile.len() / 1000 <= ConvertSaveKb) {
				print("检测到XML转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 正在读取代码中...");
				MessagePlayer("[#00FF00]Detected [#FFFFFF]'" + (myfile.len() / 1000) + "kb' [#00FF00]of code in [#FFFFFF]'XML' [#00FF00]converter, reading code...", player);
			} else {
				convert = false;
				print("检测到XML转换器里存在 " + (myfile.len() / 1000) + "kb 的代码, 由于文件的大小超过设置的安全范围 (" + ConvertSaveKb + "kb), 因此不会启动转换.");
				MessagePlayer("[#FFFFFF]'" + (myfile.len() / 1000) + "kb' [#FFFF00]code detected in the [#FFFFFF]'XML' [#FFFF00]converter. ", player);
				MessagePlayer("[#FFFF00]The conversion will not start because the file size exceeds the set safety range [#FFFFFF](" + ConvertSaveKb + "kb)", player);
			}
		}

		if (convert == true) {
			local text = ReadTextFromFile("export/ipl convert/xml.txt");
			local arr = split(text, "\n");
			if (arr.len() >= 1) {
				print("成功读取文件内 " + arr.len() + " 行代码, 正在转换中...");
				MessagePlayer("[#00FF00]Read the [#FFFFFF]'" + arr.len() + "' [#00FF00]line of code in the file successfully, is being converted...", player);

				local marr = [], posarr = [], rotarr = [];
				for (local i = 0; i < arr.len(); i++) {
					local model = GetTextBetween(arr[i], "model=", " name");
					if (model != null) {
						model = model.slice(1, model.len() - 1);
						marr.append(model.tointeger());
					}

					local x = GetTextBetween(arr[i], "x=", " y"), y = GetTextBetween(arr[i], "y=", " z"), z = GetTextBetween(arr[i], "z=", " "), w = GetTextBetween(arr[i], "angle=", " ");
					if (x != null && y != null && z != null) {
						x = x.slice(1, x.len() - 1);
						y = y.slice(1, y.len() - 1);
						z = z.slice(1, z.len() - 1);
						posarr.append(Vector(x.tofloat(), y.tofloat(), z.tofloat()));

						if (w != null) {
							w = w.slice(1, w.len() - 1);
							posarr.remove(posarr.len() - 1);
							rotarr.append(Quaternion(x.tofloat(), y.tofloat(), z.tofloat(), w.tofloat() * ConvertXmlFix));
						}
					}
				}

				for (local i = 0; i < marr.len(); i++) {
					local pos = posarr[i];
					local o = CreateObject(marr[i].tointeger(), 1, Vector(pos.x, pos.y, pos.z + ConvertHigh), 255);
					o.RotateTo(rotarr[i], 0);
				}
				ConvertMap("xml");
				MessagePlayer("[#00FF00]The code conversion in [#FFFFFF]'XML' [#00FF00]converter is complete!", player);
			}
		}

		if (WorldMap != null) {
			if (ConvertHideID.len() > 0) {
				for (local i = 0; i <= 3000; i++) {
					if (ConvertHideID.rawin(i)) {
						local id = ConvertHideID.rawget(i);
						local pos = ConvertHidePos.rawget(i);
						local angle = ConvertHideAngle.rawget(i);
						local alpha = ConvertHideAlpha.rawget(i);
						local o = CreateObject(id, 1, pos, alpha);
						o.RotateTo(angle, 0);
						ConvertHideID.rawdelete(i);
						ConvertHidePos.rawdelete(i);
						ConvertHideAngle.rawdelete(i);
						ConvertHideAlpha.rawdelete(i);
					}
				}
				ConvertHideID.clear();
				ConvertHidePos.clear();
				ConvertHideAngle.clear();
				ConvertHideAlpha.clear();
			}
		}
	} else if (cmd == "ator") {
		if (text && IsNum(text) && text.tointeger() >= 0 && text.tointeger() <= 360) {
			local angle;
			if (text.tointeger() <= 180) angle = text.tointeger() / (180 / PI);
			else angle = (-text.tointeger() / (180 / PI) + (2 * PI)) * -1;
			if (angle.tostring() == "-0") angle = 0;
			MessagePlayer("[#00FF00]Angle: [#FFFFFF]" + text + " [#FFFF00]-> [#00FF00]Radian: [#FFFFFF]" + angle + "", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<0~360>", player);
	} else if (cmd == "vtoq") {
		if (text) {
			local arr = split(text, " ");
			if (arr && arr.len() >= 1 && arr[0] != "" && (typeof(GetArgValue(arr[0])) == "integer" || typeof(GetArgValue(arr[0])) == "float")) {
				if (arr.len() >= 2 && arr[1] != "" && (typeof(GetArgValue(arr[1])) == "integer" || typeof(GetArgValue(arr[1])) == "float")) {
					if (arr.len() == 3 && arr[2] != "" && (typeof(GetArgValue(arr[2])) == "integer" || typeof(GetArgValue(arr[2])) == "float")) {
						local v = Vector(GetArgValue(arr[0]), GetArgValue(arr[1]), GetArgValue(arr[2]));
						local q = EulerToQuaternion(v.x, v.y, v.z);
						MessagePlayer("[#00FF00]Vector(" + v.x + "," + v.y + "," + v.z + ") [#FFFF00]-> [#00FF00]Quaternion(" + q.x + "," + q.y + "," + q.z + "," + q.w + ")", player);
					} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> <" + arr[1] + "> [#FF0000]<rz>", player);
				} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> [#FF0000]<ry> <rz>", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<rx> <ry> <rz>", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<rx> <ry> <rz>", player);
	} else if (cmd == "frozenmode") {
		if (state[player.ID].frozen == false) {
			state[player.ID].frozen = true;
			MessagePlayer("[#00FF00]You will now auto freeze yourself when editing building.", player);
		} else {
			state[player.ID].frozen = false;
			MessagePlayer("[#FFFF00]You turned off the auto-freeze function.", player);
		}
	} else if (cmd == "guntpmode") {
		if (state[player.ID].guntp == false) {
			state[player.ID].guntp = true;
			MessagePlayer("[#00FF00]You turned on the shot transfer function.", player);
		} else {
			state[player.ID].guntp = false;
			MessagePlayer("[#FFFF00]You turned off the shot transfer function.", player);
		}
		SendDataToClient(player, StreamType.GunTPMode, "" + state[player.ID].guntp + "");
	} else if (cmd == "wep") {
		if (text) {
			local arr = split(text, " ");
			if (arr && arr.len() >= 1 && arr[0] != "") {
				local wep = "", error = "";
				for (local i = 0; i < arr.len(); i++) {
					if (arr[i] && arr[i] != "" && (typeof(GetArgValue(arr[i])) == "string" || typeof(GetArgValue(arr[i])) == "integer")) {
						if ((IsNum(arr[i]) && arr[i].tointeger() >= 1 && arr[i].tointeger() <= 33) || (GetWeaponID(arr[i]) >= 1 && GetWeaponID(arr[i]) <= 33) || arr[i].tointeger() >= 100) {
							local id = GetWeaponID(arr[i]);
							if (IsNum(arr[i])) id = arr[i].tointeger();
							player.GiveWeapon(id, 9999);

							if (i != arr.len() - 1) wep += "" + GetWeaponName(id) + ",";
							else wep += "" + GetWeaponName(id) + "";
						} else error += " <" + arr[i] + ">";
					} else error += " <" + arr[i] + ">";
				}
				if (wep != "") {
					MessagePlayer("[#00FF00]You got a weapon [#FFFF00][" + wep + "] [#00FF00]and [#FFFFFF]'9999' [#00FF00]rounds of ammunition.", player);
					if (error != "") MessagePlayer("[#FFFF00]Server unrecognizable [#FFFFFF]" + error + " [#FFFF00]Name or ID of the weapon.", player);
				} else MessagePlayer("[#00FF00]/" + cmd + " <Wep1> ...", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " <Wep1> ...", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " <Wep1> ...", player);
	} else if (cmd == "tp2") {
		if (text && text != "") {
			local arr = split(text, " ");
			if (arr && arr.len() == 3) {
				player.Pos = Vector(arr[0].tointeger(), arr[1].tointeger(), arr[2].tointeger());
				MessagePlayer("[#00FF00]You teleport to pos (" + arr[0] + "," + arr[1] + "," + arr[2] + ") here.", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<X> <Y> <Z>", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<X> <Y> <Z>", player);
	} else if (cmd == "disarm") {
		player.Disarm();
	} else if (cmd == "time") {
		if (text) {
			local arr = split(text, " ");
			if (arr && arr.len() >= 1) {
				if (arr[0] && IsNum(arr[0]) && arr[0].tointeger() >= 0 && arr[0].tointeger() <= 12) {
					if (arr && arr.len() == 2) {
						if (arr[1] && IsNum(arr[1]) && arr[1].tointeger() >= 0 && arr[1].tointeger() <= 60) {
							SetTime(arr[0].tointeger(), arr[1].tointeger());
							MessagePlayer("[#00FF00]You have changed time to [#FFFFFF]'" + arr[0] + ":" + arr[1] + "'", player);
						} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> [#FF0000]<Minute>", player);
					} else MessagePlayer("[#00FF00]/" + cmd + " <" + arr[0] + "> [#FF0000]<Minute>", player);
				} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Hour> <Minute>", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Hour> <Minute>", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<Hour> <Minute>", player);
	} else if (cmd == "skin") {
		if (text && text != "") {
			if (IsNum(text) && ((text.tointeger() >= 0 && text.tointeger() <= 194) || text.tointeger() >= 200)) {
				player.Skin = text.tointeger();
				MessagePlayer("[#00FF00]You have changed skin to [#FFFFFF]ID: " + player.Skin + "", player);
			} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<SkinID>", player);
		} else MessagePlayer("[#00FF00]/" + cmd + " [#FF0000]<SkinID>", player);
	} else if (cmd == "cmds") {
		MessagePlayer("[#FFFF00]Basic: /fps /pos /fly /autosave /s /hide /hidelist /show /delallveh /cc /fix /ff /exec", player);
		MessagePlayer("[#FFFF00]Map: /createmap /loadmap /savemap /closemap /abandmap /exportmap /maplist", player);
		MessagePlayer("[#FFFF00]Object: /addobj /caddobj /dofile /copy /saveobj /selectobj /setalpha /setcross /setcpos", player);
		MessagePlayer("[#FFFF00]Other: /doconvert /ator /vtoq /frozenmode /guntpmode /wep /tp /time /skin /disarm", player);
	} else MessagePlayer("[#FF0000]The cmd you typed does not exist, please type [#FFFF00]/cmds [#FF0000]to check server commands.", player);
}

function onPlayerPM(player, playerTo, message) {
	return 1;
}

function onPlayerBeginTyping(player) {}

function onPlayerEndTyping(player) {}

/*
function onLoginAttempt(player,password,ipAddress)
{
}
*/

function onNameChangeable(player) {}

function onPlayerMove(player, lastX, lastY, lastZ, newX, newY, newZ) {}

function onPlayerHealthChange(player, lastHP, newHP) {
	if (player.Health != 100) player.Health = 100;
}

function onPlayerArmourChange(player, lastArmour, newArmour) {}

function onPlayerWeaponChange(player, oldWep, newWep) {}

function onPlayerAwayChange(player, newStatus) {}

function onPlayerSpectate(player, target) {}

function onPlayerCrashDump(player, crashReport) {}

function onPlayerNameChange(player, oldName, newName) {}

function onPlayerActionChange(player, oldAction, newAction) {}

function onPlayerStateChange(player, oldState, newState) {}

function onPlayerOnFireChange(player, isOnFireNow) {}

function onPlayerCrouchChange(player, isCrouchingNow) {}

function onPlayerGameKeysChange(player, oldKeys, newKeys) {}

function onPlayerUpdate(player, update) {}

function onPlayerModuleList(player, report) {}

function onClientScriptData(player) {
	local stream = Stream.ReadByte();
	switch (stream) {
		case 0x08: {
			local str = Stream.ReadString();
			local arr = split(str, ",");
			HideMapObject(arr[0].tointeger(), arr[1].tofloat(), arr[2].tofloat(), arr[3].tofloat());
			MapHideCount += 1;
			MapHideID.rawset(MapHideCount, arr[0].tointeger());
			MapHidePos.rawset(MapHideCount, Vector(arr[1].tofloat(), arr[2].tofloat(), arr[3].tofloat()));
			state[player.ID].hide = false;
			MessagePlayer("HideMapObject(" + arr[0].tointeger() + "," + arr[1].tofloat() + "," + arr[2].tofloat() + "," + arr[3].tofloat() + ");", player);
			MessagePlayer("[#00FF00]You can type [#FFFFFF]/show " + MapHideCount + " [#00FF00]to show the object.", player);
		}
		break;

		case 0x09: {
			local str = Stream.ReadString();
			local arr = split(str, ",");

			local obj = CreateObject(arr[0].tointeger(), player.World, Vector(arr[1].tofloat(), arr[2].tofloat(), arr[3].tofloat()), 255);
			if (AutoAlignment == "true") obj.RotateTo(EulerToQuaternion(0, 0, AlignmentAngle(player.Pos.x, player.Pos.y, obj.Pos.x, obj.Pos.y)), 0);
			obj.TrackingShots = true;
			state[player.ID].obj = obj;
			UpdateObjInfo(player.ID);
			CreateObjMarker(obj.ID, "c");
			SaveObject(obj.ID);
			UpdateMapInfo(player.ID);
			MessagePlayer("[#00FF00]You created object with Model [#FFFF00]" + obj.Model + " [#00FF00]and ID [#FFFF00]" + obj.ID + "[#00FF00].", player);

			if (state[player.ID].objarr != null) SendDataToClient(player, StreamType.ObjArrSpr, "null");
			state[player.ID].cadd = false;
		}
		break;

		case 0x10: {
			local str = Stream.ReadString();
			local arr = split(str, ",");
			player.Pos = Vector(arr[0].tofloat(), arr[1].tofloat(), arr[2].tofloat() + 0.5);
		}
		break;

		default:
			break;
	}
}

//============================== V E H I C L E  E V E N T S ==============================

function onPlayerEnteringVehicle(player, vehicle, door) {
	return 1;
}

function onPlayerEnterVehicle(player, vehicle, door) {}

function onPlayerExitVehicle(player, vehicle) {}

function onVehicleExplode(vehicle) {}

function onVehicleRespawn(vehicle) {}

function onVehicleHealthChange(vehicle, oldHP, newHP) {}

function onVehicleMove(vehicle, lastX, lastY, lastZ, newX, newY, newZ) {}

//============================== P I C K U P  E V E N T S ==============================

function onPickupClaimPicked(player, pickup) {
	return 1;
}

function onPickupPickedUp(player, pickup) {}

function onPickupRespawn(pickup) {}

//============================== O B J E C T  E V E N T S ==============================

function onObjectShot(object, player, weapon) {
	if (state[player.ID].keyx == true) {
		if (state[player.ID].obj != null) {
			if (object.ID == state[player.ID].obj.ID) {
				state[player.ID].obj = null;
				UpdateObjInfo(player.ID);
				MessagePlayer("[#00FF00]The selected object with ID " + object.ID + " now deselected.", player);

				if (state[player.ID].objarr != null) UpdateObjArrInfo(player.ID);
				return false;
			}
		}

		if (state[player.ID].obj == null) {
			if (state[player.ID].objarr != null) {
				for (local i = 0; i < state[player.ID].objarr.len(); i++) {
					if (state[player.ID].objarr[i] == object.ID) {
						state[player.ID].objarr.remove(i);
						UpdateObjArrInfo(player.ID);
						MessagePlayer("[#00FF00]The selected object with ID " + object.ID + " now deselected.", player);
						break;
					}
				}
			}
		}
		return false;
	}

	if (state[player.ID].keyc == true) {
		if (state[player.ID].objarr == null) {
			if (state[player.ID].obj == null) {
				state[player.ID].obj = object;
				UpdateObjInfo(player.ID);
				MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
			} else {
				if (object.ID == state[player.ID].obj.ID) return false;

				local b = [];
				b.append(state[player.ID].obj.ID);
				state[player.ID].obj = null;
				UpdateObjInfo(player.ID);

				b.append(object.ID);
				state[player.ID].objarr = b;
				UpdateObjArrInfo(player.ID);
				MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
			}
			return false;
		} else {
			if (state[player.ID].obj == null) {
				local find = false;
				for (local i = 0; i < state[player.ID].objarr.len(); i++)
					if (object.ID == state[player.ID].objarr[i]) find = true;
				if (find == false) {
					state[player.ID].objarr.append(object.ID);
					UpdateObjArrInfo(player.ID);
					MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
				}
			} else {
				if (object.ID == state[player.ID].obj.ID) return false;
				state[player.ID].objarr.clear();

				local b = [];
				b.append(state[player.ID].obj.ID);
				state[player.ID].obj = null;
				UpdateObjInfo(player.ID);

				b.append(object.ID);
				state[player.ID].objarr = b;
				UpdateObjArrInfo(player.ID);
				MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);
			}
			return false;
		}
	}

	if (state[player.ID].keyc == false && state[player.ID].keyx == false) {
		if (state[player.ID].obj != null)
			if (object.ID == state[player.ID].obj.ID) return false;
		state[player.ID].obj = object;
		UpdateObjInfo(player.ID);
		MessagePlayer("[#00FF00]The object with ID " + object.ID + " is selected!", player);

		if (state[player.ID].objarr != null) SendDataToClient(player, StreamType.ObjArrSpr, "null");
	}
}

function onObjectBump(object, player) {}

//============================== C H E C K P O I N T  E V E N T S ==============================

function onCheckpointEntered(player, checkpoint) {}

function onCheckpointExited(player, checkpoint) {}

//============================== B I N D K E Y  E V E N T S ==============================

function onKeyDown(player, key) {
	if (key == Key_T) state[player.ID].istype = true;

	if (key == Key_Enter) {
		if (state[player.ID].istype = true) {
			if (state[player.ID].keyttimer != null) {
				state[player.ID].keyttimer.Delete();
				state[player.ID].keyttimer = null;
			}
			state[player.ID].keyttimer = NewTimer("onKeyTUp", 250, 1, player.ID);
		}
	}

	if (state[player.ID].istype == true) return false;

	if (key == Key_Up) state[player.ID].keyup = true;
	if (key == Key_Down) state[player.ID].keydown = true;
	if (key == Key_Left) state[player.ID].keyleft = true;
	if (key == Key_Right) state[player.ID].keyright = true;
	if (key == Key_PageUp) state[player.ID].keypageup = true;
	if (key == Key_PageDown) state[player.ID].keypagedown = true;
	if (key == Key_Shift) state[player.ID].keyshift = true;
	if (key == Key_Alt) state[player.ID].keyalt = true;
	if (key == Key_W) state[player.ID].keyw = true;
	if (key == Key_Ctrl) state[player.ID].keyctrl = true;
	if (key == Key_RButton)
		if (state[player.ID].keyw == true) CreateVehForPlr(player.ID, "191");
	if (key == Key_LButton) {
		state[player.ID].keylb = true;
		if (player.Vehicle) {
			local v = player.Vehicle, a = v.GetRadiansAngle(), x = cos(a), y = sin(a);
			v.AddSpeed(Vector(-y, x, 0) * 0.25);

			player.Vehicle.Health = 249;
			PlaySoundForPlayer(player, 365);
			if (LBTimer != null) {
				LBTimer.Delete();
				LBTimer = null;
			}
			LBTimer = NewTimer("VehFix", 100, 1, player.Vehicle.ID);
		}
	}
	if (key == Key_X) state[player.ID].keyx = true;

	if (state[player.ID].fly == true) {
		if (state[player.ID].keyup == true || state[player.ID].keydown == true || state[player.ID].keyleft == true || state[player.ID].keyright == true || state[player.ID].keypageup == true || state[player.ID].keypagedown == true) {
			if (state[player.ID].obj == null && state[player.ID].objarr == null) SendDataToClient(player, StreamType.SendFly, "true");
			onKeyWork(player.ID);
			if (state[player.ID].keytimer == null) state[player.ID].keytimer = NewTimer("onKeyWork", 10, 0, player.ID);
		} else onKeyBreak(player.ID);
	}

	if (key == Key_1) {
		state[player.ID].speedarr += 1;
		if (state[player.ID].speedarr == SpeedArr.len()) state[player.ID].speedarr = 0;
		state[player.ID].speed = SpeedArr[state[player.ID].speedarr];
		MessagePlayer("[#00FF00]Your speed level is [#FFFFFF]'" + state[player.ID].speed + "'", player);
		SendDataToClient(player, StreamType.SendSpeed, state[player.ID].speed.tofloat());
		UpdatePlrInfo(player.ID);
	}

	if (key == Key_2) {
		if (state[player.ID].mode == "Move") state[player.ID].mode = "Rotate";
		else if (state[player.ID].mode == "Rotate") state[player.ID].mode = "Move";
		MessagePlayer("[#00FF00]Your edit mode is [#FFFFFF]'" + state[player.ID].mode + "'", player);
		UpdatePlrInfo(player.ID);
	}

	if (key == Key_3) {
		if (state[player.ID].editmode == "Absolute World") state[player.ID].editmode = "Relative Player";
		else if (state[player.ID].editmode == "Relative Player") state[player.ID].editmode = "Absolute World";
		MessagePlayer("[#00FF00]Your edit logic is [#FFFFFF]'" + state[player.ID].editmode + "'", player);
		UpdatePlrInfo(player.ID);
	}

	if (key == Key_4) {
		if (state[player.ID].rtxmode == false) state[player.ID].rtxmode = true;
		else state[player.ID].rtxmode = false;
		MessagePlayer("[#00FF00]Your relative rotation mode is [#FFFFFF]'" + state[player.ID].rtxmode + "'", player);
		UpdatePlrInfo(player.ID);
	}

	if (key == Key_R) {
		if (state[player.ID].obj != null) {
			state[player.ID].obj.RotateTo(Quaternion(0, 0, 0, 1), 100);
			NewTimer("UpdateObjInfo", 150, 1, player.ID);
		} else if (state[player.ID].objarr != null) {
			for (local i = 0; i < state[player.ID].objarr.len(); i++) {
				local obj = FindObject(state[player.ID].objarr[i]);
				if (obj) obj.RotateTo(Quaternion(0, 0, 0, 1), 100);
			}
		}
	}

	if (key == Key_E) {
		if (state[player.ID].obj != null) {
			local a = null;
			local x1 = player.Pos.x, y1 = player.Pos.y, z1 = player.Pos.z;
			local obj = state[player.ID].obj, x2 = obj.Pos.x, y2 = obj.Pos.y, z2 = obj.Pos.z;

			local rz = AlignmentAngle(x1, y1, x2, y2);
			local tz = QuaternionToEuler(obj.Rotation.x, obj.Rotation.y, obj.Rotation.z, obj.Rotation.w).z;

			a = Multiply(obj.Rotation, tt(rz - tz));
			state[player.ID].obj.RotateTo(a, 100);
			NewTimer("UpdateObjInfo", 150, 1, player.ID);
		} else if (state[player.ID].objarr != null) {
			local x1 = player.Pos.x, y1 = player.Pos.y, z1 = player.Pos.z;

			for (local i = 0; i < state[player.ID].objarr.len(); i++) {
				local obj = FindObject(state[player.ID].objarr[i]);
				if (obj) {
					local a = null;
					local x2 = obj.Pos.x, y2 = obj.Pos.y, z2 = obj.Pos.z;

					local rz = AlignmentAngle(x1, y1, x2, y2);
					local tz = QuaternionToEuler(obj.Rotation.x, obj.Rotation.y, obj.Rotation.z, obj.Rotation.w).z;
					a = Multiply(obj.Rotation, tt(rz - tz));
					obj.RotateTo(a, 100);
				}
			}
		}
	}

	if (key == Key_BackSpace) {
		if (state[player.ID].obj != null) {
			state[player.ID].obj = null;
			UpdateObjInfo(player.ID);

			if (state[player.ID].objarr != null) UpdateObjArrInfo(player.ID);
			MessagePlayer("[#00FF00]The selected object now deselected.", player);
		} else if (state[player.ID].objarr != null) {
			state[player.ID].objarr = null;
			UpdateObjArrInfo(player.ID);
		}
	}

	if (key == Key_Delete) {
		if (state[player.ID].obj != null) {
			DeleteObject(state[player.ID].obj.ID);
			MessagePlayer("[#00FF00]You deleted this object!", player);
		} else if (state[player.ID].objarr != null) {
			for (local i = 0; i < state[player.ID].objarr.len(); i++) {
				local obj = FindObject(state[player.ID].objarr[i]);
				if (obj) DeleteObject(obj.ID);
			}
			UpdateObjArrInfo(player.ID);
			MessagePlayer("[#00FF00]You deleted file objects!", player);
		}
	}

	if (key == Key_C) {
		state[player.ID].keyc = true;
		if (state[player.ID].keyctrl == true) {
			if (state[player.ID].obj != null) {
				local obj = state[player.ID].obj;
				local obj2 = CreateObject(obj.Model, player.World, obj.Pos, obj.Alpha);
				obj2.RotateTo(obj.Rotation, 0);
				obj2.TrackingShots = true;
				CreateObjMarker(obj2.ID, "c");

				state[player.ID].obj = obj2;
				UpdateObjInfo(player.ID);
				MessagePlayer("[#00FF00]You copy the select object.", player);
			} else if (state[player.ID].objarr != null) {
				local a = [], b = [];
				for (local i = 0; i <= 3000; i++) {
					local obj = FindObject(i);
					if (obj) a.append(obj.ID);
				}
				for (local i = 0; i < state[player.ID].objarr.len(); i++) {
					local obj = FindObject(state[player.ID].objarr[i]);
					if (obj) {
						local obj2 = CreateObject(obj.Model, player.World, obj.Pos, obj.Alpha);
						if (obj2) {
							obj2.RotateTo(obj.Rotation, 0);
							obj2.TrackingShots = true;
							CreateObjMarker(obj2.ID, "c");
						}
					}
				}
				for (local i = 0; i <= 3000; i++) {
					local obj = FindObject(i);
					if (obj) {
						local find = false;
						for (local i = 0; i < a.len(); i++) {
							if (obj.ID == a[i]) {
								find = true;
								break;
							}
						}
						if (find == false) b.append(obj.ID);
					}
				}
				state[player.ID].objarr = b;
				if (state[player.ID].obj != null) {
					state[player.ID].obj = null;
					UpdateObjInfo(player.ID);
				}
				for (local i = 0; i <= GetMaxPlayers(); i++) {
					local plr = FindPlayer(i);
					if (plr) UpdateMapInfo(plr.ID);
				}
				UpdateObjArrInfo(player.ID);
				MessagePlayer("[#00FF00]You copy the all the select objects.", player);
			}
		}
	}
}

function onKeyUp(player, key) {
	if (key == Key_Up) state[player.ID].keyup = false;
	if (key == Key_Down) state[player.ID].keydown = false;
	if (key == Key_Left) state[player.ID].keyleft = false;
	if (key == Key_Right) state[player.ID].keyright = false;
	if (key == Key_PageUp) state[player.ID].keypageup = false;
	if (key == Key_PageDown) state[player.ID].keypagedown = false;
	if (key == Key_Shift) state[player.ID].keyshift = false;
	if (key == Key_Alt) state[player.ID].keyalt = false;
	if (key == Key_Ctrl) state[player.ID].keyctrl = false;
	if (key == Key_W) state[player.ID].keyw = false;
	if (key == Key_C) state[player.ID].keyc = false;
	if (key == Key_LButton) state[player.ID].keylb = false;
	if (key == Key_X) state[player.ID].keyx = false;

	if (state[player.ID].fly == true) {
		if (state[player.ID].keyup == false && state[player.ID].keydown == false && state[player.ID].keyleft == false && state[player.ID].keyright == false && state[player.ID].keypageup == false && state[player.ID].keypagedown == false) {
			SendDataToClient(player, StreamType.SendFly, "false");
			onKeyBreak(player.ID);
		}
	}
}

function onKeyTUp(i) {
	local plr = FindPlayer(i);
	if (plr) state[plr.ID].istype = false;
}

function onKeyWork(i) {
	local plr = FindPlayer(i);
	if (plr) {
		if (state[plr.ID].fly == true) {
			if (state[plr.ID].obj == null) {
				if (state[plr.ID].objarr == null) {
					if (plr.Vehicle != null) {
						local s = 0.01, v = plr.Vehicle, a = v.GetRadiansAngle(), x = cos(a), y = sin(a);
						if (state[plr.ID].keyshift == true) s = s * 5;
						if (state[plr.ID].keyalt == true) s = 0.2 * s;

						s = s * state[plr.ID].speed;

						if (state[plr.ID].keyup == true) v.AddSpeed(Vector(-y, x, 0) * s);
						if (state[plr.ID].keydown == true) v.AddSpeed(Vector(y, -x, 0) * s);
						if (state[plr.ID].keyleft == true) v.AddSpeed(Vector(-x, -y, 0) * s);
						if (state[plr.ID].keyright == true) v.AddSpeed(Vector(x, y, 0) * s);
						if (state[plr.ID].keypageup == true) v.AddSpeed(Vector(0, 0, s));
						if (state[plr.ID].keypagedown == true) v.AddSpeed(Vector(0, 0, -s));
					} else {
						/*
                        local s=1,pos=plr.Pos,x=pos.x,y=pos.y,z=pos.z,a=plr.Angle;
                        if(state[plr.ID].keyshift==true) s=s*5;
                        if(state[plr.ID].keyalt==true) s=0.2*s;
                        s=s*state[plr.ID].speed;

                        if(state[plr.ID].keyup==true) x-=s*sin(a),y+=s*cos(a);
                        if(state[plr.ID].keydown==true) x-=s*sin(a-PI),y+=s*cos(a-PI);
                        if(state[plr.ID].keyleft==true) x-=s*sin(a+(PI/2)),y+=s*cos(a+(PI/2));
				        if(state[plr.ID].keyright==true) x-=s*sin(a-(PI/2)),y+=s*cos(a-(PI/2));
                        if(state[plr.ID].keypageup==true) z+=s;
                        if(state[plr.ID].keypagedown==true) z-=s;
                        plr.Pos=Vector(x,y,z);
                        */
					}
				} else {
					for (local i = 0; i < state[plr.ID].objarr.len(); i++) {
						local obj = FindObject(state[plr.ID].objarr[i]);
						if (obj) {
							if (state[plr.ID].mode == "Move") {
								local pos = obj.Pos, x = pos.x, y = pos.y, z = pos.z, a = plr.Angle, s = 0.05;
								if (state[plr.ID].keyshift == true) s = s * 5;
								if (state[plr.ID].keyalt == true) s = 0.2 * s;

								s = s * state[plr.ID].speed;

								if (state[plr.ID].editmode == "Relative Player") {
									if (state[plr.ID].keypageup == true) z += s;
									if (state[plr.ID].keypagedown == true) z -= s;
									if (state[plr.ID].keyup == true) x -= s * sin(a), y += s * cos(a);
									if (state[plr.ID].keydown == true) x -= s * sin(a - PI), y += s * cos(a - PI);
									if (state[plr.ID].keyleft == true) x -= s * sin(a + (PI / 2)), y += s * cos(a + (PI / 2));
									if (state[plr.ID].keyright == true) x -= s * sin(a - (PI / 2)), y += s * cos(a - (PI / 2));
								}

								if (state[plr.ID].editmode == "Absolute World") {
									if (state[plr.ID].keypageup == true) z += s;
									if (state[plr.ID].keypagedown == true) z -= s;
									if (state[plr.ID].keyup == true) y += s;
									if (state[plr.ID].keydown == true) y -= s;
									if (state[plr.ID].keyleft == true) x -= s;
									if (state[plr.ID].keyright == true) x += s;
								}
								obj.MoveTo(Vector(x, y, z), 10);
								CreateObjMarker(obj.ID, "c");
							}

							if (state[plr.ID].mode == "Rotate") {
								local a = null, s = 0.005;
								if (state[plr.ID].keyshift == true) s = s * 5;
								if (state[plr.ID].keyalt == true) s = 0.2 * s;

								s = s * state[plr.ID].speed;

								if (state[plr.ID].editmode == "Relative Player") {
									if (state[plr.ID].rtxmode == false) {
										a = plr.Angle;
										local x = 0, y = 0, z = 0;
										if (state[plr.ID].keypageup == true) z += s;
										if (state[plr.ID].keypagedown == true) z -= s;
										if (state[plr.ID].keyup == true) x -= s * cos(a - (PI / 2)), y += s * sin(a - (PI / 2));
										if (state[plr.ID].keydown == true) x += s * cos(a - (PI / 2)), y -= s * sin(a - (PI / 2));
										if (state[plr.ID].keyleft == true) x -= s * cos(a), y += s * sin(a);
										if (state[plr.ID].keyright == true) x += s * cos(a), y -= s * sin(a);
										obj.RotateByEuler(Vector(x, y, z), 10);
									} else {
										a = 0.1;
										local x0 = plr.Pos.x, y0 = plr.Pos.y, z0 = plr.Pos.z, x1 = obj.Pos.x, y1 = obj.Pos.y, z1 = obj.Pos.z, x2, y2, z2;
										a = a * (s * 10);

										if (state[plr.ID].keypageup == true) x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
										if (state[plr.ID].keypagedown == true) a = a * (-1), x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
										if (state[plr.ID].keyup == true) y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
										if (state[plr.ID].keydown == true) a = a * (-1), y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
										if (state[plr.ID].keyleft == true) z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
										if (state[plr.ID].keyright == true) a = a * (-1), z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
										obj.MoveTo(Vector(x2, y2, z2), 10);
										CreateObjMarker(obj.ID, "c");
									}
								}

								if (state[plr.ID].editmode == "Absolute World") {
									if (state[plr.ID].rtxmode == false) {
										if (state[plr.ID].keypageup == true) a = Multiply(obj.Rotation, tt(s));
										if (state[plr.ID].keypagedown == true) a = Multiply(obj.Rotation, tt(-s));
										if (state[plr.ID].keyup == true) a = Multiply(obj.Rotation, rr(s));
										if (state[plr.ID].keydown == true) a = Multiply(obj.Rotation, rr(-s));
										if (state[plr.ID].keyleft == true) a = Multiply(obj.Rotation, ss(s));
										if (state[plr.ID].keyright == true) a = Multiply(obj.Rotation, ss(-s));
										obj.RotateTo(a, 10);
									} else {
										a = 0.1;
										local x0 = 0, y0 = 0, z0 = 0;
										if (state[plr.ID].rtxpos != null) x0 = state[plr.ID].rtxpos.x, y0 = state[plr.ID].rtxpos.y, z0 = state[plr.ID].rtxpos.z;

										if (state[plr.ID].rtxobjid != null) {
											local o = FindObject(state[plr.ID].rtxobjid);
											if (o) x0 = o.Pos.x, y0 = o.Pos.y, z0 = o.Pos.z;
										}
										local x1 = obj.Pos.x, y1 = obj.Pos.y, z1 = obj.Pos.z, x2, y2, z2;
										a = a * (s * 10);

										if (state[plr.ID].keypageup == true) x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
										if (state[plr.ID].keypagedown == true) a = a * (-1), x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
										if (state[plr.ID].keyup == true) y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
										if (state[plr.ID].keydown == true) a = a * (-1), y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
										if (state[plr.ID].keyleft == true) z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
										if (state[plr.ID].keyright == true) a = a * (-1), z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
										obj.MoveTo(Vector(x2, y2, z2), 10);
										CreateObjMarker(obj.ID, "c");
									}
								}
							}
						}
					}
					UpdateObjArrInfo(plr.ID);

					if (state[plr.ID].frozen == true)
						if (plr.Frozen == false) plr.Frozen = true;
				}
			} else {
				local obj = state[plr.ID].obj;
				if (state[plr.ID].mode == "Move") {
					local pos = obj.Pos, x = pos.x, y = pos.y, z = pos.z, a = plr.Angle, s = 0.05;
					if (state[plr.ID].keyshift == true) s = s * 5;
					if (state[plr.ID].keyalt == true) s = 0.2 * s;

					s = s * state[plr.ID].speed;

					if (state[plr.ID].editmode == "Relative Player") {
						if (state[plr.ID].keypageup == true) z += s;
						if (state[plr.ID].keypagedown == true) z -= s;
						if (state[plr.ID].keyup == true) x -= s * sin(a), y += s * cos(a);
						if (state[plr.ID].keydown == true) x -= s * sin(a - PI), y += s * cos(a - PI);
						if (state[plr.ID].keyleft == true) x -= s * sin(a + (PI / 2)), y += s * cos(a + (PI / 2));
						if (state[plr.ID].keyright == true) x -= s * sin(a - (PI / 2)), y += s * cos(a - (PI / 2));
					}

					if (state[plr.ID].editmode == "Absolute World") {
						if (state[plr.ID].keypageup == true) z += s;
						if (state[plr.ID].keypagedown == true) z -= s;
						if (state[plr.ID].keyup == true) y += s;
						if (state[plr.ID].keydown == true) y -= s;
						if (state[plr.ID].keyleft == true) x -= s;
						if (state[plr.ID].keyright == true) x += s;
					}
					obj.MoveTo(Vector(x, y, z), 10);
					CreateObjMarker(obj.ID, "c");
				}

				if (state[plr.ID].mode == "Rotate") {
					local a = null, s = 0.005;
					if (state[plr.ID].keyshift == true) s = s * 5;
					if (state[plr.ID].keyalt == true) s = 0.2 * s;

					s = s * state[plr.ID].speed;

					if (state[plr.ID].editmode == "Relative Player") {
						if (state[plr.ID].rtxmode == false) {
							a = plr.Angle;
							local x = 0, y = 0, z = 0;
							if (state[plr.ID].keypageup == true) z += s;
							if (state[plr.ID].keypagedown == true) z -= s;
							if (state[plr.ID].keyup == true) x -= s * cos(a - (PI / 2)), y += s * sin(a - (PI / 2));
							if (state[plr.ID].keydown == true) x += s * cos(a - (PI / 2)), y -= s * sin(a - (PI / 2));
							if (state[plr.ID].keyleft == true) x -= s * cos(a), y += s * sin(a);
							if (state[plr.ID].keyright == true) x += s * cos(a), y -= s * sin(a);
							obj.RotateByEuler(Vector(x, y, z), 10);
						} else {
							a = 0.1;
							local x0 = plr.Pos.x, y0 = plr.Pos.y, z0 = plr.Pos.z, x1 = obj.Pos.x, y1 = obj.Pos.y, z1 = obj.Pos.z, x2, y2, z2;
							a = a * (s * 10);

							if (state[plr.ID].keypageup == true) x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
							if (state[plr.ID].keypagedown == true) a = a * (-1), x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
							if (state[plr.ID].keyup == true) y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
							if (state[plr.ID].keydown == true) a = a * (-1), y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
							if (state[plr.ID].keyleft == true) z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
							if (state[plr.ID].keyright == true) a = a * (-1), z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
							obj.MoveTo(Vector(x2, y2, z2), 10);
							CreateObjMarker(obj.ID, "c");
						}
					}

					if (state[plr.ID].editmode == "Absolute World") {
						if (state[plr.ID].rtxmode == false) {
							if (state[plr.ID].keypageup == true) a = Multiply(obj.Rotation, tt(s));
							if (state[plr.ID].keypagedown == true) a = Multiply(obj.Rotation, tt(-s));
							if (state[plr.ID].keyup == true) a = Multiply(obj.Rotation, rr(s));
							if (state[plr.ID].keydown == true) a = Multiply(obj.Rotation, rr(-s));
							if (state[plr.ID].keyleft == true) a = Multiply(obj.Rotation, ss(s));
							if (state[plr.ID].keyright == true) a = Multiply(obj.Rotation, ss(-s));
							obj.RotateTo(a, 10);
						} else {
							a = 0.1;
							local x0 = 0, y0 = 0, z0 = 0;
							if (state[plr.ID].rtxpos != null) x0 = state[plr.ID].rtxpos.x, y0 = state[plr.ID].rtxpos.y, z0 = state[plr.ID].rtxpos.z;

							if (state[plr.ID].rtxobjid != null) {
								local o = FindObject(state[plr.ID].rtxobjid);
								if (o) x0 = o.Pos.x, y0 = o.Pos.y, z0 = o.Pos.z;
							}
							local x1 = obj.Pos.x, y1 = obj.Pos.y, z1 = obj.Pos.z, x2, y2, z2;
							a = a * (s * 10);

							if (state[plr.ID].keypageup == true) x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
							if (state[plr.ID].keypagedown == true) a = a * (-1), x2 = (x1 - x0) * cos(a) - (y1 - y0) * sin(a) + x0, y2 = (x1 - x0) * sin(a) + (y1 - y0) * cos(a) + y0, z2 = z1;
							if (state[plr.ID].keyup == true) y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
							if (state[plr.ID].keydown == true) a = a * (-1), y2 = (y1 - y0) * cos(a) - (z1 - z0) * sin(a) + y0, z2 = (y1 - y0) * sin(a) + (z1 - z0) * cos(a) + z0, x2 = x1;
							if (state[plr.ID].keyleft == true) z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
							if (state[plr.ID].keyright == true) a = a * (-1), z2 = (z1 - z0) * cos(a) - (x1 - x0) * sin(a) + z0, x2 = (z1 - z0) * sin(a) + (x1 - x0) * cos(a) + x0, y2 = y1;
							obj.MoveTo(Vector(x2, y2, z2), 10);
							CreateObjMarker(obj.ID, "c");
						}
					}
				}

				UpdateObjInfo(plr.ID);

				if (state[plr.ID].frozen == true)
					if (plr.Frozen == false) plr.Frozen = true;
			}
		} else onKeyBreak(plr.ID);
	} else onKeyBreak(plr.ID);
}

function onKeyBreak(i) {
	local plr = FindPlayer(i);
	if (plr) {
		if (state[plr.ID].keytimer != null) {
			state[plr.ID].keytimer.Delete();
			state[plr.ID].keytimer = null;
		}

		if (state[plr.ID].frozen == true)
			if (plr.Frozen == true) plr.Frozen = false;
	}
}

//============================== E N D  O F  O F F I C I A L  E V E N T S ==============================


//============================== F U N C T I O S ==============================


//============================== P L A Y E R  F U N C T I O S ==============================

function SendDataToClient(player, ...) {
	if (vargv[0]) {
		local byte = vargv[0], len = vargv.len();
		if (1 > len) devprint("ToClent <" + byte + "> No params specified.");
		else {
			Stream.StartWrite();
			Stream.WriteByte(byte);
			for (local i = 1; i < len; i++) {
				switch (typeof(vargv[i])) {
					case "integer":
						Stream.WriteInt(vargv[i]);
						break;
					case "string":
						Stream.WriteString(vargv[i]);
						break;
					case "float":
						Stream.WriteFloat(vargv[i]);
						break;
				}
			}
			if (player == null) Stream.SendStream(null);
			else if (typeof(player) == "instance") Stream.SendStream(player);
			else devprint("ToClient <" + byte + "> Player is not online.");
		}
	} else devprint("ToClient: Even the byte wasn't specified...");
}

function GetPlayerColor(i) {
	local plr = FindPlayer(i);
	if (plr) return format("[#%02X%02X%02X]", plr.Colour.r, plr.Colour.g, plr.Colour.b);
}

function UpdatePlrInfo(i) {
	local plr = FindPlayer(i);
	if (plr) {
		local info = "" + state[plr.ID].speed + "," + state[plr.ID].mode + "," + state[plr.ID].editmode + "," + state[plr.ID].rtxmode + "";
		SendDataToClient(plr, StreamType.SendInfo, info);
	}
}

function CreateVehForPlr(i, text) {
	local plr = FindPlayer(i);
	if (plr) {
		local id = GetVehicleModelFromName(text), a = EulerToQuaternion(0, 0, plr.Angle), s = null;
		if (IsNum(text)) id = text.tointeger();
		if (plr.Vehicle != null) {
			a = plr.Vehicle.Rotation;
			s = Vector(plr.Vehicle.Speed.x, plr.Vehicle.Speed.y, plr.Vehicle.Speed.z);
			plr.Vehicle.Delete();
		}
		local veh = CreateVehicle(id, plr.World, plr.Pos, 0, 1, 1);

		if (veh != null) {
			veh.Rotation = a;
			plr.Vehicle = veh;
			MessagePlayer("[#00FF00]You created [#FFFFFF]'" + GetVehicleNameFromModel(id) + "' [#00FF00]with Model [#FFFFFF]'" + id + "'", plr);
		} else MessagePlayer("[#FF0000]This vehicle ID or name could not be spawned.", plr);
	}
}

function CheckObjNotEditedForPlr(i, p) {
	local obj = FindObject(i), plr = FindPlayer(p);
	if (obj && plr) {
		local find = false;
		if (state[plr.ID].obj != null)
			if (state[plr.ID].obj.ID == obj.ID) find = true;
		if (state[plr.ID].objarr != null) {
			for (local i = 0; i < state[plr.ID].objarr.len(); i++) {
				local obj2 = FindObject(state[plr.ID].objarr[i]);
				if (obj2) {
					if (obj2.ID == obj.ID) {
						find = true;
						break;
					}
				}
			}
		}
		return find;
	}
}

//============================== V E H I C L E  F U N C T I O S ==============================

function CVehicle::GetRadiansAngle() {
	local angle = ::asin(this.Rotation.z) * -2;
	return this.Rotation.w < 0 ? 3.1415926 - angle : (2 * 3.1415926) - angle;
}

function CVehicle::GetRadiansAngleEx() {
	local angle = ::asin(this.Rotation.z) * -2;
	return angle;
}

function VehFix(i) {
	local veh = FindVehicle(i);
	if (veh) veh.Fix();
}

//============================== O B J E C T  F U N C T I O S ==============================

function UpdateObjInfo(i) {
	local plr = FindPlayer(i);
	if (plr) {
		local str = null;
		if (state[plr.ID].obj != null) {
			local obj = state[plr.ID].obj;
			str = "" + obj.ID + "," + obj.Model + "," + obj.Alpha + "," + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + "," + obj.Rotation.x + "," + obj.Rotation.y + "," + obj.Rotation.z + "," + obj.Rotation.w + "";
		} else str = "?,?,?,?,?,?,?,?,?,?";
		SendDataToClient(plr, StreamType.ObjInfo, str);
	}
}

function UpdateObjArrInfo(i) {
	local plr = FindPlayer(i);
	if (plr) {
		if (state[plr.ID].objarrsee == true) {
			local str = "null";
			if (state[plr.ID].objarr != null) {
				str = "";
				for (local i = 0; i < state[plr.ID].objarr.len(); i++) {
					local obj = FindObject(state[plr.ID].objarr[i]);
					if (obj)
						if (i <= state[plr.ID].objarrlen) str += "" + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + ",";
				}
			}
			SendDataToClient(plr, StreamType.ObjArrSpr, str);
		}
	}
}

function SaveObject(i) {
	local obj = FindObject(i);
	if (obj) {
		if (WorldMap != null) {
			local info = "" + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + "," + obj.Rotation.x + "," + obj.Rotation.y + "," + obj.Rotation.z + "," + obj.Rotation.w + "";
			local q = QuerySQL(db, "SELECT * FROM " + WorldMap + " WHERE ID='" + obj.ID + "'");
			if (q) QuerySQL(db, "UPDATE " + WorldMap + " SET Model='" + obj.Model + "',Info='" + info + "',Alpha='" + obj.Alpha + "' WHERE ID='" + obj.ID + "'");
			else QuerySQL(db, "INSERT INTO " + WorldMap + "(ID,Model,Info,Alpha)VALUES('" + obj.ID + "','" + obj.Model + "','" + info + "','" + obj.Alpha + "')");
			QuerySQL(db, "UPDATE Maps SET ObjCount='" + GetObjectCount() + "' WHERE Name='" + WorldMap + "'");
		}
	}
}

function DeleteObject(i) {
	local obj = FindObject(i);
	if (obj) {
		local q = QuerySQL(db, "SELECT * FROM " + WorldMap + " WHERE ID='" + obj.ID + "'");
		if (q) QuerySQL(db, "DELETE FROM " + WorldMap + " WHERE ID='" + obj.ID + "'");
		DestroyMarker(ObjMarker.rawget(obj.ID));
		ObjMarker.rawdelete(obj.ID);

		for (local i = 0; i <= GetMaxPlayers(); i++) {
			local plr = FindPlayer(i);
			if (plr) {
				if (state[plr.ID].obj != null) {
					if (state[plr.ID].obj.ID == obj.ID) {
						state[plr.ID].obj = null;
						UpdateObjInfo(plr.ID);
					}
				}
			}
		}
		obj.Delete();

		for (local i = 0; i <= GetMaxPlayers(); i++) {
			local plr = FindPlayer(i);
			if (plr) UpdateMapInfo(plr.ID);
		}
	}
}

function ObjVaguelyVisible(i) {
	local obj = FindObject(i);
	if (obj) {
		local a = null;
		if (obj.Alpha != 255) a = obj.Alpha;
		obj.SetAlpha(0, 250);
		NewTimer("ObjVaguelyVisible2", 250, 1, obj.ID, a);
	}
}

function ObjVaguelyVisible2(i, a) {
	local obj = FindObject(i);
	if (obj) {
		obj.SetAlpha(255, 250);
		NewTimer("ObjVaguelyVisible3", 250, 1, obj.ID, a);
	}
}

function ObjVaguelyVisible3(i, a) {
	local obj = FindObject(i);
	if (obj) {
		obj.SetAlpha(0, 250);
		NewTimer("ObjVaguelyVisible4", 250, 1, obj.ID, a);
	}
}

function ObjVaguelyVisible4(i, a) {
	local obj = FindObject(i);
	if (obj) {
		if (a != null) obj.SetAlpha(a, 250);
		else obj.SetAlpha(255, 250);
	}
}

function CreateObjMarker(i, mode) {
	local obj = FindObject(i);
	if (obj) {
		local m = null;
		if (ObjMarker.rawin(obj.ID)) {
			local m = ObjMarker.rawget(obj.ID);
			DestroyMarker(m);
			ObjMarker.rawdelete(obj.ID);
		}
		if (mode == "c") {
			m = CreateMarker(1, obj.Pos, 1, RGBA(255, 255, 255, 255), 0);
			ObjMarker.rawset(obj.ID, m);
		}
	}
}

//============================== M A P  F U N C T I O S ==============================

function UpdateMapInfo(i) {
	local plr = FindPlayer(i);
	if (plr) {
		local str = null;
		if (WorldMap != null) str = "" + WorldMap + "," + GetObjectCount();
		else {
			str = "null,?";
			if (state[plr.ID].objarr != null) {
				state[plr.ID].objarr = null;
				UpdateObjArrInfo(plr.ID);
			}
		}
		SendDataToClient(plr, StreamType.SendMap, str);
	}
}

function LoadMap(map) {
	local q = QuerySQL(db, "SELECT * FROM Maps WHERE Name='" + map + "'");
	if (q) {
		if (GetSQLRowCount(map) > 0) {
			q = QuerySQL(db, "SELECT * FROM " + map + "");
			local count = 0;
			do {
				local model = GetSQLColumnData(q, 1), info = GetSQLColumnData(q, 2), alpha = GetSQLColumnData(q, 3);
				local arr = split(info, ",");

				local obj = CreateObject(model, 1, Vector(arr[0].tofloat(), arr[1].tofloat(), arr[2].tofloat()), 0);
				obj.RotateTo(Quaternion(arr[3].tofloat(), arr[4].tofloat(), arr[5].tofloat(), arr[6].tofloat()), 0);
				obj.SetAlpha(alpha, 500);
				obj.TrackingShots = true;
				CreateObjMarker(obj.ID, "c");
				count += 1;
			}
			while (GetSQLNextRow(q))
			Message("[#FFFFFF]" + count + " [#FFFF00]objects of the map [#FFFFFF]'" + map + "' [#FFFF00]have been loaded!");
			print("地图 [" + map + "] 里 [" + count + "] 个建筑加载成功!");
		} else Message("[#FFFF00]There are no objects on this map.");

		WorldMap = map;
		for (local i = 0; i <= GetMaxPlayers(); i++) {
			local plr = FindPlayer(i);
			if (plr) UpdateMapInfo(plr.ID);
		}
	}
}

function SaveMap() {
	for (local i = 0; i <= 3000; i++) {
		local obj = FindObject(i);
		if (obj) SaveObject(obj.ID);
	}
	if (GetObjectCount() > 0) {
		Message("[#FFFFFF]" + GetObjectCount() + " [#FFFF00]objects on the map are saved successfully!");

		for (local i = 0; i <= 100; i++) {
			local plr = FindPlayer(i);
			if (plr) UpdateMapInfo(i);
		}
	}
}

function CloseMap(mode) {
	if (mode == "save") SaveMap();
	Message("[#00FF00]Map [#FFFFFF]'" + WorldMap + "' [#00FF00]has been closed.");
	for (local i = 0; i <= 3000; i++) {
		local obj = FindObject(i);
		if (obj) {
			CreateObjMarker(obj.ID, "d");
			obj.Delete();
		}
	}
	WorldMap = null;
	for (local i = 0; i <= GetMaxPlayers(); i++) {
		local plr = FindPlayer(i);
		if (plr) {
			UpdateMapInfo(plr.ID);
			if (state[plr.ID].obj != null) {
				state[plr.ID].obj = null;
				UpdateObjInfo(plr.ID);
			}
		}
	}
}

function ExportMap() {
	local count = 0;
	if (GetObjectCount() >= 1) {
		local ipl = "", nut = "", xml = "";
		ipl += "#该图是由pq的制图工具制作, 地图作者: " + Author + ", 地图名称: " + WorldMap + ", 导出时间: " + GetTime() + " \n";
		ipl += "inst\n";
		nut += "//该图是由pq的制图工具制作, 地图作者: " + Author + ", 地图名称: " + WorldMap + ", 导出时间: " + GetTime() + " \n";
		xml += "<?xml version=\"1.0\" encoding=\"ASCII\" ?> \n";
		xml += "<!-- 该图是由pq的制图工具制作, 地图作者: " + Author + ", 地图名称: " + WorldMap + ", 导出时间: " + GetTime() + " --> \n";
		xml += "	<itemlist> \n";
		for (local i = 0; i <= 3000; i++) {
			local obj = FindObject(i);
			if (obj) {
				count += 1;
				ipl += "" + obj.Model + ", , 0, " + obj.Pos.x + ", " + obj.Pos.y + ", " + obj.Pos.z + ", 1, 1, 1, " + obj.Rotation.x + ", " + obj.Rotation.y + ", " + obj.Rotation.z + ", " + obj.Rotation.w + " \n";
				nut += "CreateObject(" + obj.Model + ",1,Vector(" + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + ")," + obj.Alpha + ").RotateTo(Quaternion(" + obj.Rotation.x + "," + obj.Rotation.y + "," + obj.Rotation.z + "," + obj.Rotation.w + "),0); \n";
				xml += "		<item model=\"" + obj.Model + "\" name=\"" + count + "\"> \n";
				xml += "			<position x=\"" + obj.Pos.x + "\" y=\"" + obj.Pos.y + "\" z=\"" + obj.Pos.z + "\" /> \n";
				xml += "			<rotation format=\"axisangle\" x=\"" + obj.Rotation.x + "\" y=\"" + obj.Rotation.y + "\" z=\"" + obj.Rotation.z + "\" angle=\"" + (-1 * obj.Rotation.w) + "\" /> \n";
				xml += "		</item> \n";
			}
		}
		xml += "	</itemlist> \n";
		ipl += "end\ncull\nend\npick\nend\npath\nend\n\n";

		ipl += "#未经作者授权禁止私自搬运和盗用 \n";
		nut += "//未经作者授权禁止私自搬运和盗用 \n";
		xml += "<!-- 未经作者授权禁止私自搬运和盗用 --> \n";

		exportMapToFile(WorldMap, ipl, "ipl");
		exportMapToFile(WorldMap, nut, "nut");
		exportMapToFile(WorldMap, xml, "xml");
		Message("[#00FF00]Map [#FFFFFF]'" + WorldMap + "' [#00FF00]has been exported!");
		CloseMap("save");
	}
}

function BackUpMap() {
	local count = 0;
	if (GetObjectCount() >= 1) {
		local nut = "";
		nut += "//该图是由pq的制图工具制作, 地图作者: " + Author + ", 地图名称: " + WorldMap + ", 导出时间: " + GetTime() + " \n";
		for (local i = 0; i <= 3000; i++) {
			local obj = FindObject(i);
			if (obj) {
				count += 1;
				nut += "CreateObject(" + obj.Model + ",1,Vector(" + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + ")," + obj.Alpha + ").RotateTo(Quaternion(" + obj.Rotation.x + "," + obj.Rotation.y + "," + obj.Rotation.z + "," + obj.Rotation.w + "),0); \n";
			}
		}
		nut += "//未经作者授权禁止私自搬运和盗用 \n";
		exportMapToFile("autosave/" + WorldMap + "_" + GetTime(), nut, "nut");
	}
}

function ConvertMap(mode) {
	local count = 0;
	if (GetObjectCount() >= 1) {
		local ipl = "", nut = "", xml = "";
		ipl += "#该文件由pq的制图工具转换, 导出时间: " + GetTime() + "  \n";
		ipl += "inst\n";
		nut += "//该文件由pq的制图工具转换, 导出时间: " + GetTime() + " \n";
		xml += "<?xml version=\"1.0\" encoding=\"ASCII\" ?> \n";
		xml += "<!-- 该文件由pq的制图工具转换, 导出时间: " + GetTime() + " --> \n";
		xml += "	<itemlist> \n";
		for (local i = 0; i <= 3000; i++) {
			local obj = FindObject(i);
			if (obj) {
				count += 1;
				if (mode == "xml") ipl += "" + obj.Model + ", , 0, " + obj.Pos.x + ", " + obj.Pos.y + ", " + obj.Pos.z + ", 1, 1, 1, " + obj.Rotation.x + ", " + obj.Rotation.y + ", " + obj.Rotation.z + ", " + (obj.Rotation.w * ConvertXmlFix) + " \n";
				else ipl += "" + obj.Model + ", , 0, " + obj.Pos.x + ", " + obj.Pos.y + ", " + obj.Pos.z + ", 1, 1, 1, " + obj.Rotation.x + ", " + obj.Rotation.y + ", " + obj.Rotation.z + ", " + obj.Rotation.w + " \n";
				nut += "CreateObject(" + obj.Model + ",1,Vector(" + obj.Pos.x + "," + obj.Pos.y + "," + obj.Pos.z + ")," + obj.Alpha + ").RotateTo(Quaternion(" + obj.Rotation.x + "," + obj.Rotation.y + "," + obj.Rotation.z + "," + obj.Rotation.w + "),0); \n";
				xml += "		<item model=\"" + obj.Model + "\" name=\"" + count + "\"> \n";
				xml += "			<position x=\"" + obj.Pos.x + "\" y=\"" + obj.Pos.y + "\" z=\"" + obj.Pos.z + "\" /> \n";
				xml += "			<rotation format=\"axisangle\" x=\"" + obj.Rotation.x + "\" y=\"" + obj.Rotation.y + "\" z=\"" + obj.Rotation.z + "\" angle=\"" + obj.Rotation.w + "\" /> \n";
				xml += "		</item> \n";
			}
		}
		xml += "	</itemlist> \n";
		ipl += "end\ncull\nend\npick\nend\npath\nend\n\n";

		if (mode == "ipl") {
			//exportMapToFile("IPL转换_"+GetTime(),nut,"nut");
			exportMapToFile("IPL转换_" + GetTime(), xml, "xml");
		}

		if (mode == "xml") {
			exportMapToFile("XML转换_" + GetTime(), ipl, "ipl");
			exportMapToFile("XML转换_" + GetTime(), nut, "nut");
		}
		print("" + count + " 个对象转换成功!");

		for (local i = 0; i <= 3000; i++) {
			local obj = FindObject(i);
			if (obj) obj.Delete();
		}
		if (ConvertClear == "true") {
			if (mode == "ipl") WriteTextToFile("export/ipl convert/ipl.txt", "");
			if (mode == "xml") WriteTextToFile("export/ipl convert/xml.txt", "");
			print("转换器里的代码已经清除.");
		}
	}
}

//============================== M E S S A G E  F U N C T I O S ==============================

function devprint(text) {
	Message("[#bbbbbb]" + text);
	print(text);
}

function timeprint(text) {
	print("\r\r\r[" + GetTime() + "] " + text);
}

function printarr(arr) {
	local str = "";
	for (local i = 0; i < arr.len(); i++) {
		if (i == 0) str += "" + arr[i] + "";
		else str += "," + arr[i] + "";
	}
	print(str);
}

MSGAll <- Message;
function Message(text) {
	MSGAll(text);
	print(ClearColor(text));
}

function ClearColor(text) {
	local data = "", find = false, find2 = 0;
	for (local i = 0; i < text.len(); i++) {
		local a = text.slice(i, i + 1);
		if (a == "[") {
			local b = text.slice(i + 1, i + 2);
			if (b == "#") find = true;
		}

		if (find == true) find2 += 1;
		else data += a;
		if (find2 == 9) {
			find = false;
			find2 = 0;
		}
	}
	return data;
}

//============================== A N G L E  F U N C T I O S ==============================

function EulerToQuaternion(x, y, z) {
	local sx = sin(x / 2), sy = sin(y / 2), sz = sin(z / 2);
	local cx = cos(x / 2), cy = cos(y / 2), cz = cos(z / 2);
	local qx = sy * sz * cx + cy * cz * sx;
	local qy = sy * cz * cx + cy * sz * sx;
	local qz = cy * sz * cx - sy * cz * sx;
	local qw = cy * cz * cx - sy * sz * sx;
	return Quaternion(qx, qy, qz, qw);
}

function QuaternionToEuler(x, y, z, w) {
	local v = Vector(0, 0, 0), e = 0.00097625, m = 0.5 - e;
	local test = w * y - x * z;
	if (-m > test || test > m) {
		local s = null;
		if (test >= 0) s = 1;
		else s = -1;
		v.z = atan2(x, w) * (-2) * s;
		v.y = (PI / 2) * s;
		v.x = 0;
	} else {
		v.x = atan2(2 * (y * z + w * x), w * w - x * x - y * y + z * z);
		v.y = asin(-2 * (x * z - w * y));
		v.z = atan2(2 * (x * y + w * z), w * w + x * x - y * y - z * z);
	}
	return v;
}

function Multiply(a, b) {
	local v1 = Vector(a.x, a.y, a.z);
	local v2 = Vector(b.x, b.y, b.z);
	local r1 = a.w;
	local r2 = b.w;
	local r = r1 * r2 - Dot(v1, v2);
	local v = MultiplyWithScalar(v2, r1) + MultiplyWithScalar(v1, r2) + Cross(v1, v2);
	return Quaternion(v.x, v.y, v.z, r);
}

function Dot(v1, v2) {
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

function Cross(a, b) {
	local i = a.y * b.z - a.z * b.y
	local j = a.z * b.x - a.x * b.z
	local k = a.x * b.y - a.y * b.x
	return Vector(i, j, k);
}

function MultiplyWithScalar(v, s) {
	return Vector(v.x * s, v.y * s, v.z * s);
}

function rr(a) {
	return Quaternion(sin(a / 2), 0, 0, cos(a / 2));
}

function ss(a) {
	return Quaternion(0, sin(a / 2), 0, cos(a / 2));
}

function tt(a) {
	return Quaternion(0, 0, sin(a / 2), cos(a / 2));
}

function AlignmentAngle(x1, y1, x2, y2) {
	return atan2(-(x2 - x1), y2 - y1);
}

//============================== S Q L I T E  F U N C T I O S ==============================

function GetSQLRowCount(sql) {
	local q = QuerySQL(db, "SELECT COUNT(*) FROM " + sql + "");
	if (q) return GetSQLColumnData(q, 0);
	else return 0;
}

//============================== O T H E R  F U N C T I O N S ==============================

function GetTime() {
	local sj = "" + date().year + "年" + (date().month + 1) + "月" + date().day + "日-" + date().hour + "时" + date().min + "分" + date().sec + "秒";
	return sj;
}

function GetArgValue(arg) {
	local type = arg.find(".") ? ArgType.FLOAT : ArgType.INTEGER;
	foreach(c in arg) {
		if ((c < 48 || c > 57) && c != 46 && c != 43 && c != 45) {
			type = ArgType.STRING;
			break;
		}
	}

	if (type == ArgType.INTEGER) {
		try {
			return arg.tointeger();
		} catch (e) return 0;
	} else if (type == ArgType.FLOAT) {
		try {
			return arg.tofloat();
		} catch (e) return 0.0;
	} else if (type == ArgType.STRING) {
		if (arg == "on" || arg == "true" || arg == "enabled") return true;
		else if (arg == "off" || arg == "false" || arg == "disabled") return false;
	}
	return arg;
}

function GetTextBetween(text, begin_str, end_str, must_end = true) {
	local start_idx = text.find(begin_str, 0);
	if (start_idx == null) return null;
	start_idx += begin_str.len();
	local end_idx = text.find(end_str, start_idx);
	if (end_idx == null) {
		if (must_end) return null;
		else return text.slice(start_idx);
	}
	return text.slice(start_idx, end_idx);
}

//============================== F I L E  F U N C T I O N S ==============================

function WriteTextToFile(path, text) {
	local f = file(path, "wb+"), s = "";
	f.seek(0, 'e');
	foreach(c in text) f.writen(c, 'b');
	f.close();
}

function exportMapToFile(mapName, data, suffix) {
	local mapFile = mapName;
	local segments = split(data, "\n");
	data = "";
	foreach(segment in segments) {
		data += segment;
		data += "\r\n";
	}
	WriteTextToFile("export/" + mapFile + "." + suffix + "", data);
}

function ReadTextFromFile(path) {
	local f = file(path, "rb"), s = "";
	while (!f.eos()) s += format(@ "%c", f.readn('b'));
	f.close();
	return s;
}

function TXTAddLine(filename, text) {
	local f = file(filename, "a+");
	foreach(char in text) f.writen(char, 'c');
	f.writen('\n', 'c');
	f.close();
	f = null;
}

//============================== E N D  O F  C U S T O M  F U N C T I O N S ==============================


//============================== E N D  O F  M A P  E D I T O R  S C R I P T ==============================