
local Key_Up=KeyBind(0x26),Key_Down=KeyBind(0x28),Key_Left=KeyBind(0x25),Key_Right=KeyBind(0x27),Key_PageUp=KeyBind(0x21),Key_PageDown=KeyBind(0x22),Key_Shift=KeyBind(0x10),Key_Alt=KeyBind(0x12);
local keyup=false,keydown=false,keyleft=false,keyright=false,keypageup=false,keypagedown=false,keyshift=false,keyalt=false;
local player=World.FindLocalPlayer(),fly=false,speed=1,isobjinfo=false;
local objinfo1=null,objinfo2=null,objinfo3=null,objinlb1=null,objinlb2=null,objinlb3=null;
local plrinfo1=null,plrinfo2=null,plrinfo3=null,plrinfo4=null,plrinlb1=null,plrinlb2=null,plrinlb3=null,plrinlb4=null;
local info1=null,info2=null,info3=null,info4=null,info5=null,info6=null,info7=null,info8=null,info9=null,info10=null;
local inlb1=null,inlb2=null,inlb3=null,inlb4=null,inlb5=null,inlb6=null,inlb7=null,inlb8=null,inlb9=null,inlb10=null;
local basiclb1=null,basiclb2=null,objm=null,isobj=false,objpos=null;
local objarrspr={},objarrpos={},objarrlen=10;
local Key_M=KeyBind(0x4D),objmenu1=null,objmenu2=null,menubut1=null,menubut2=null,menupage=1;
local Key_W=KeyBind(0x57),Key_C=KeyBind(0x43),keyw=false,keyc=false;
local hide=false,cadd=false,guntp=false;

enum StreamType
{
    SendHide=0x08
    SendCAdd=0x09
    GunTPMode=0x10
}
 
function Script::ScriptLoad()
{
    seterrorhandler(errorHandling);
    srand(System.GetTimestamp());

    objmenu1=GUISprite("objmenu.png",VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion((1080-854)/2,"y")));
    objmenu1.Size=VectorScreen(GetProportion(1204,"x"),GetProportion(30,"y"));
    objmenu1.Alpha=255;
    objmenu1.RemoveFlags(GUI_FLAG_VISIBLE);

    objmenu2=GUISprite("obj"+menupage+".png",VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion((1080-854)/2+30,"y")));
    objmenu2.Size=VectorScreen(GetProportion(1204,"x"),GetProportion(854,"y"));
    objmenu2.Alpha=255;
    objmenu2.RemoveFlags(GUI_FLAG_VISIBLE);

    objm=GUISprite("m.png",VectorScreen(0,0));
    objm.Size=VectorScreen(GetProportion(64,"x"),GetProportion(64,"y"));
    objm.Alpha=255;
    objm.RemoveFlags(GUI_FLAG_VISIBLE);

    menubut1=GUIButton(VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion(((1080-854)/2)+30+854,"y")),VectorScreen(GetProportion(180,"x"),GetProportion(40,"y")),Colour(255,255,255),"Previous "+menupage+"/12",GUI_FLAG_BORDER);
    menubut1.TextColour=Colour(0,0,0,255);
    menubut1.FontSize=GetPropForFont(20);
    menubut1.RemoveFlags(GUI_FLAG_VISIBLE);

    menubut2=GUIButton(VectorScreen(GetProportion((1920-1204)/2+1204-180,"x"),GetProportion(((1080-854)/2)+30+854,"y")),VectorScreen(GetProportion(180,"x"),GetProportion(40,"y")),Colour(255,255,255),"Next Page "+menupage+"/12",GUI_FLAG_BORDER);
    menubut2.TextColour=Colour(0,0,0,255);
    menubut2.FontSize=GetPropForFont(20);
    menubut2.RemoveFlags(GUI_FLAG_VISIBLE);

    local bx=1520,bsize=180;

    plrinfo1=GUICanvas();
    plrinfo1.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(690,"y"));
    plrinfo1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo1.Color=Colour(0,0,0,128);

    plrinfo2=GUICanvas();
    plrinfo2.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(720,"y"));
    plrinfo2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo2.Color=Colour(0,0,0,128);

    plrinfo3=GUICanvas();
    plrinfo3.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(750,"y"));
    plrinfo3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo3.Color=Colour(0,0,0,128);

    plrinfo4=GUICanvas();
    plrinfo4.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(780,"y"));
    plrinfo4.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo4.Color=Colour(0,0,0,128);

    plrinlb1=GUILabel();
    plrinlb1.AddFlags(GUI_FLAG_TEXT_TAGS);
    plrinlb1.Text="[#00ff00]Speed:  [#ffffff]?";
    plrinlb1.TextColour=Colour(255,255,255,255);
    plrinlb1.FontSize=GetPropForFont(20);
    plrinlb1.Pos=VectorScreen(0,0);
    plrinlb1.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    plrinlb1.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    plrinlb2=GUILabel();
    plrinlb2.AddFlags(GUI_FLAG_TEXT_TAGS);
    plrinlb2.Text="[#00ff00]Mode:  [#ffffff]Move";
    plrinlb2.TextColour=Colour(255,255,255,255);
    plrinlb2.FontSize=GetPropForFont(20);
    plrinlb2.Pos=VectorScreen(0,0);
    plrinlb2.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    plrinlb2.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    plrinlb3=GUILabel();
    plrinlb3.AddFlags(GUI_FLAG_TEXT_TAGS);
    plrinlb3.Text="[#00ff00]Edit:  [#ffffff]Relative";
    plrinlb3.TextColour=Colour(255,255,255,255);
    plrinlb3.FontSize=GetPropForFont(20);
    plrinlb3.Pos=VectorScreen(0,0);
    plrinlb3.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    plrinlb3.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    plrinlb4=GUILabel();
    plrinlb4.AddFlags(GUI_FLAG_TEXT_TAGS);
    plrinlb4.Text="[#00ff00]SR Mode:  [#ffffff]false";
    plrinlb4.TextColour=Colour(255,255,255,255);
    plrinlb4.FontSize=GetPropForFont(20);
    plrinlb4.Pos=VectorScreen(0,0);
    plrinlb4.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    plrinlb4.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    plrinfo1.AddChild(plrinlb1);
    plrinfo2.AddChild(plrinlb2);
    plrinfo3.AddChild(plrinlb3);
    plrinfo4.AddChild(plrinlb4);

    objinfo1=GUICanvas();
    objinfo1.Pos=VectorScreen(GetProportion(bx-bsize,"x"),GetProportion(850,"y"));
    objinfo1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    objinfo1.Color=Colour(0,0,0,128);

    objinfo2=GUICanvas();
    objinfo2.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(850,"y"));
    objinfo2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    objinfo2.Color=Colour(0,0,0,128);

    objinfo3=GUICanvas();
    objinfo3.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(850,"y"));
    objinfo3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    objinfo3.Color=Colour(0,0,0,128);

    objinlb1=GUILabel();
    objinlb1.AddFlags(GUI_FLAG_TEXT_TAGS);
    objinlb1.Text="[#00ff00]ID:  [#ffffff]?";
    objinlb1.TextColour=Colour(255,255,255,255);
    objinlb1.FontSize=GetPropForFont(20);
    objinlb1.Pos=VectorScreen(0,0);
    objinlb1.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    objinlb1.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    objinlb2=GUILabel();
    objinlb2.AddFlags(GUI_FLAG_TEXT_TAGS);
    objinlb2.Text="[#00ff00]Model:  [#ffffff]?";
    objinlb2.TextColour=Colour(255,255,255,255);
    objinlb2.FontSize=GetPropForFont(20);
    objinlb2.Pos=VectorScreen(0,0);
    objinlb2.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    objinlb2.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    objinlb3=GUILabel();
    objinlb3.AddFlags(GUI_FLAG_TEXT_TAGS);
    objinlb3.Text="[#00ff00]Alpha:  [#ffffff]?";
    objinlb3.TextColour=Colour(255,255,255,255);
    objinlb3.FontSize=GetPropForFont(20);
    objinlb3.Pos=VectorScreen(0,0);
    objinlb3.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    objinlb3.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    objinfo1.AddChild(objinlb1);
    objinfo2.AddChild(objinlb2);
    objinfo3.AddChild(objinlb3);

    basiclb1=GUILabel();
    basiclb1.TextColour=Colour(255,255,255,255);
    basiclb1.FontSize=GetPropForFont(20);
    basiclb1.Pos=VectorScreen(GetProportion(20,"x"),GetProportion(1010,"y"));
    basiclb1.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    basiclb1.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;
    basiclb1.AddFlags(GUI_FLAG_TEXT_TAGS);
    basiclb1.Text="[#00ff00]Map:  [#ffffff]Null";

    basiclb2=GUILabel();
    basiclb2.TextColour=Colour(255,255,255,255);
    basiclb2.FontSize=GetPropForFont(20);
    basiclb2.Pos=VectorScreen(GetProportion(20,"x"),GetProportion(1040,"y"));
    basiclb2.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    basiclb2.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;
    basiclb2.AddFlags(GUI_FLAG_TEXT_TAGS);
    basiclb2.Text="[#00ff00]Obj Count:  [#ffffff]?";

    info1=GUICanvas();
    info1.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(900,"y"));
    info1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info1.Color=Colour(0,0,0,128);

    info2=GUICanvas();
    info2.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(930,"y"));
    info2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info2.Color=Colour(0,0,0,128);

    info3=GUICanvas();
    info3.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(960,"y"));
    info3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info3.Color=Colour(0,0,0,128);

    info4=GUICanvas();
    info4.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(990,"y"));
    info4.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info4.Color=Colour(0,0,0,128);

    info10=GUICanvas();
    info10.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(1020,"y"));
    info10.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info10.Color=Colour(0,0,0,128);

    inlb1=GUILabel();
    inlb1.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb1.Text="[#ffff00]Position";
    inlb1.TextColour=Colour(255,255,255,255);
    inlb1.FontSize=GetPropForFont(22);
    inlb1.Pos=VectorScreen(0,0);
    inlb1.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb1.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb2=GUILabel();
    inlb2.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb2.Text="[#00ff00]X:  [#ffffff]?";
    inlb2.TextColour=Colour(255,255,255,255);
    inlb2.FontSize=GetPropForFont(18);
    inlb2.Pos=VectorScreen(0,0);
    inlb2.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb2.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb3=GUILabel();
    inlb3.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb3.Text="[#00ff00]Y:  [#ffffff]?";
    inlb3.TextColour=Colour(255,255,255,255);
    inlb3.FontSize=GetPropForFont(18);
    inlb3.Pos=VectorScreen(0,0);
    inlb3.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb3.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb4=GUILabel();
    inlb4.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb4.Text="[#00ff00]Z:  [#ffffff]?";
    inlb4.TextColour=Colour(255,255,255,255);
    inlb4.FontSize=GetPropForFont(18);
    inlb4.Pos=VectorScreen(0,0);
    inlb4.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb4.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb10=GUILabel();
    inlb10.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb10.Text="[#00ff00]A:  [#ffffff]?";
    inlb10.TextColour=Colour(255,255,255,255);
    inlb10.FontSize=GetPropForFont(18);
    inlb10.Pos=VectorScreen(0,0);
    inlb10.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb10.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    info1.AddChild(inlb1);
    info2.AddChild(inlb2);
    info3.AddChild(inlb3);
    info4.AddChild(inlb4);
    info10.AddChild(inlb10);

    info5=GUICanvas();
    info5.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(900,"y"));
    info5.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info5.Color=Colour(0,0,0,128);

    info6=GUICanvas();
    info6.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(930,"y"));
    info6.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info6.Color=Colour(0,0,0,128);

    info7=GUICanvas();
    info7.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(960,"y"));
    info7.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info7.Color=Colour(0,0,0,128);

    info8=GUICanvas();
    info8.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(990,"y"));
    info8.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info8.Color=Colour(0,0,0,128);

    info9=GUICanvas();
    info9.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(1020,"y"));
    info9.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info9.Color=Colour(0,0,0,128);

    inlb5=GUILabel();
    inlb5.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb5.Text="[#ffff00]Rotation";
    inlb5.TextColour=Colour(255,255,255,255);
    inlb5.FontSize=GetPropForFont(22);
    inlb5.Pos=VectorScreen(0,0);
    inlb5.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb5.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb6=GUILabel();
    inlb6.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb6.Text="[#00ff00]X:  [#ffffff]?";
    inlb6.TextColour=Colour(255,255,255,255);
    inlb6.FontSize=GetPropForFont(18);
    inlb6.Pos=VectorScreen(0,0);
    inlb6.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb6.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb7=GUILabel();
    inlb7.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb7.Text="[#00ff00]Y:  [#ffffff]?";
    inlb7.TextColour=Colour(255,255,255,255);
    inlb7.FontSize=GetPropForFont(18);
    inlb7.Pos=VectorScreen(0,0);
    inlb7.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb7.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb8=GUILabel();
    inlb8.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb8.Text="[#00ff00]Z:  [#ffffff]?";
    inlb8.TextColour=Colour(255,255,255,255);
    inlb8.FontSize=GetPropForFont(18);
    inlb8.Pos=VectorScreen(0,0);
    inlb8.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb8.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    inlb9=GUILabel();
    inlb9.AddFlags(GUI_FLAG_TEXT_TAGS);
    inlb9.Text="[#00ff00]W:  [#ffffff]?";
    inlb9.TextColour=Colour(255,255,255,255);
    inlb9.FontSize=GetPropForFont(18);
    inlb9.Pos=VectorScreen(0,0);
    inlb9.TextAlignment=GUI_ALIGN_LEFT|GUI_ALIGN_TOP;
    inlb9.FontFlags=GUI_FFLAG_BOLD|GUI_FFLAG_OUTLINE;

    info5.AddChild(inlb5);
    info6.AddChild(inlb6);
    info7.AddChild(inlb7);
    info8.AddChild(inlb8);
    info9.AddChild(inlb9);
}

function Script::ScriptProcess()
{
    if(fly==true)
    {
        local pos=player.Position,x=pos.X,y=pos.Y,z=pos.Z,a=GetAngle("x"),s=speed;
        if(keyshift==true) s=s*5;
        if(keyalt==true) s=0.2*s;

        if(keypageup==true) z+=s;
        if(keypagedown==true) z-=s;
        if(keyup==true) x-=s*sin(a),y+=s*cos(a);
        if(keydown==true) x-=s*sin(a-PI),y+=s*cos(a-PI);
        if(keyleft==true) x-=s*sin(a+(PI/2)),y+=s*cos(a+(PI/2));
        if(keyright==true) x-=s*sin(a-(PI/2)),y+=s*cos(a-(PI/2));
        player.Position=Vector(x,y,z);
    }

    if(isobj==true)
    {
        local dis=Distance(objpos[0],objpos[1],objpos[2],player.Position.X,player.Position.Y,player.Position.Z);
        local size=96-(dis.tointeger()*2);
        if(size>=30) objm.Size=VectorScreen(GetProportion(size,"x"),GetProportion(size,"y"));

        local pos=GUI.WorldPosToScreen(Vector(objpos[0],objpos[1],objpos[2]));
        if(pos.Z<1) objm.Pos=VectorScreen(pos.X-objm.Size.X/2,pos.Y-objm.Size.Y/2); 
    }

    if(objarrpos.len()>0)
    {
        for(local i=0;i<objarrpos.len()*3;i+=3)
        {
            if(objarrpos.rawin(i)&&objarrspr.rawin(i)) 
            {
                local p=objarrpos.rawget(i);
                local pos=GUI.WorldPosToScreen(Vector(p.X,p.Y,p.Z));
                local dis=Distance(p.X,p.Y,p.Z,player.Position.X,player.Position.Y,player.Position.Z);
                local size=96-(dis.tointeger()*2);

                local m=objarrspr.rawget(i);
                if(size>=30) m.Size=VectorScreen(GetProportion(size,"x"),GetProportion(size,"y"));
                else m.Size=VectorScreen(GetProportion(30,"x"),GetProportion(30,"y"));
                if(pos.Z<1) m.Pos=VectorScreen(pos.X-m.Size.X/2,pos.Y-m.Size.Y/2); 
            }
            else break;
        }
    }

    if(keyw==true&&keyc==true)
    {
        if(isobj==false&&objarrpos.len()==0)
        {
            local pos=player.Position,x=pos.X,y=pos.Y,z=pos.Z,a=GetAngle("x"),s=speed;
            if(keyshift==true) s=s*5;
            if(keyalt==true) s=0.2*s;
            player.Position=Vector(x-s*sin(a),y+s*cos(a),z+0.5);
        }
    }
}

function Player::PlayerShoot(player,weapon,hitEntity,hitPosition)
{
    if(hitEntity&&hitEntity.Type==OBJ_BUILDING) 
    {
        if(cadd==true)
        {
            cadd=false;
            SendDataToServer(StreamType.SendCAdd,""+hitEntity.ModelIndex+","+hitEntity.Position.X+","+hitEntity.Position.Y+","+hitEntity.Position.Z+"");
        }
        else
        {
            if(hide==false) 
            {
                if(guntp==false) Console.Print("[#FFFF00]Shot Object Model ID: "+hitEntity.ModelIndex);
            }
            else 
            {
                hide=false;
                SendDataToServer(StreamType.SendHide,""+hitEntity.ModelIndex+","+hitEntity.Position.X+","+hitEntity.Position.Y+","+hitEntity.Position.Z+"");
            }
        }
        if(guntp==true) SendDataToServer(StreamType.GunTPMode,""+hitPosition.X+","+hitPosition.Y+","+hitPosition.Z+"");
    }
}

function Player::PlayerDeath(player)
{
}

function Server::ServerData(stream)
{
    local type=stream.ReadByte();
    switch(type)
    {
        case 0x01:
        {
            local str=stream.ReadString();
            local arr=split(str,",");
            objinlb1.Text="[#00ff00]ID:  [#ffffff]"+arr[0];
            objinlb2.Text="[#00ff00]Model:  [#ffffff]"+arr[1];
            objinlb3.Text="[#00ff00]Alpha:  [#ffffff]"+arr[2];
            inlb2.Text="[#00ff00]X:  [#ffffff]"+arr[3];
            inlb3.Text="[#00ff00]Y:  [#ffffff]"+arr[4];
            inlb4.Text="[#00ff00]Z:  [#ffffff]"+arr[5];

            local err=false;
            try
            {
                arr[5]=arr[5].tofloat();
            }
            catch(e) err=true;

            if(err==true)
            {
                inlb6.Text="[#00ff00]X:  [#ffffff]"+arr[6];
                inlb7.Text="[#00ff00]Y:  [#ffffff]"+arr[7];
                inlb8.Text="[#00ff00]Z:  [#ffffff]"+arr[8];
                inlb9.Text="[#00ff00]W:  [#ffffff]"+arr[9];
                inlb10.Text="[#00ff00]A:  [#ffffff]"+arr[8]+"";

                if(isobj==true) 
                {
                    isobj=false;
                    objpos=null;
                    objm.RemoveFlags(GUI_FLAG_VISIBLE);
                }
            }
            else
            {
                inlb6.Text="[#00ff00]X:  [#ffffff]"+Decimal(arr[6].tofloat(),4);
                inlb7.Text="[#00ff00]Y:  [#ffffff]"+Decimal(arr[7].tofloat(),4);
                inlb8.Text="[#00ff00]Z:  [#ffffff]"+Decimal(arr[8].tofloat(),4);
                inlb9.Text="[#00ff00]W:  [#ffffff]"+Decimal(arr[9].tofloat(),4);
                inlb10.Text="[#00ff00]A:  [#ffffff]"+Decimal(asin(arr[8].tofloat())*(-2),4)+"";

                if(isobj==false) 
                {
                    isobj=true;
                    objpos=[];
                    objm.AddFlags(GUI_FLAG_VISIBLE);
                }
                if(objpos!=null) objpos=[arr[3].tofloat(),arr[4].tofloat(),arr[5].tofloat()];
            }
        }
        break;

        case 0x02:
        {
            local str=stream.ReadString();
            if(str=="true") fly=true;
            if(str=="false") fly=false;
        }
        break;

        case 0x03:
        {
            local s=stream.ReadFloat();
            speed=s;
            plrinlb1.Text="[#00ff00]Speed:  [#ffffff]"+speed;
        }
        break;

        case 0x04:
        {
            local str=stream.ReadString();
            local arr=split(str,",");
            plrinlb1.Text="[#00ff00]Speed:  [#ffffff]"+arr[0];
            plrinlb2.Text="[#00ff00]Mode:  [#ffffff]"+arr[1];

            if(arr[2]=="Relative Player") arr[2]="Relative";
            if(arr[2]=="Absolute World") arr[2]="Absolute";
            plrinlb3.Text="[#00ff00]Edit:  [#ffffff]"+arr[2];
            plrinlb4.Text="[#00ff00]SR Mode:  [#ffffff]"+arr[3];
        }
        break;

        case 0x05:
        {
            local str=stream.ReadString();
            local arr=split(str,",");

            basiclb1.Text="[#00ff00]Map:  [#ffffff]"+arr[0];
            basiclb2.Text="[#00ff00]Obj Count:  [#ffffff]"+arr[1];
        }
        break;

        case 0x06:
        {
            local str=stream.ReadString();
            if(str!="null")
            {
                local arr=split(str,",");

                objarrpos.clear();
                for(local i=0;i<arr.len();i+=3)
                {
                    local x=arr[i].tofloat(),y=arr[i+1].tofloat(),z=arr[i+2].tofloat();
                    local pos=GUI.WorldPosToScreen(Vector(x,y,z));
                    local dis=Distance(x,y,z,player.Position.X,player.Position.Y,player.Position.Z);
                    local size=96-(dis.tointeger()*2);
                    objarrpos.rawset(i,Vector(x,y,z));

                    if(objarrspr.rawin(i))
                    {
                        local m=objarrspr.rawget(i);
                        if(size>=30) m.Size=VectorScreen(GetProportion(size,"x"),GetProportion(size,"y"));
                        else m.Size=VectorScreen(GetProportion(30,"x"),GetProportion(30,"y"));
                        if(pos.Z<1) m.Pos=VectorScreen(pos.X-objm.Size.X/2,pos.Y-objm.Size.Y/2); 
                        m.AddFlags(GUI_FLAG_VISIBLE);
                    }
                    else break;
                }

                if(objarrspr.len()>objarrpos.len())
                {
                    for(local i=0;i<objarrlen*3;i+=3)
                    {
                        if(objarrspr.rawin(i))
                        {
                            if(objarrpos.rawin(i)==false)
                            {
                                local m=objarrspr.rawget(i);
                                m.RemoveFlags(GUI_FLAG_VISIBLE);
                            }
                        }
                    }
                }
            }
            else
            {
                for(local i=0;i<objarrlen*3;i+=3)
                {
                    local m=objarrspr.rawget(i);
                    m.RemoveFlags(GUI_FLAG_VISIBLE);
                }
                objarrpos.clear();
            }
        }
        break;

        case 0x07:
        {
            for(local i=0;i<objarrlen*3;i+=3)
            {
                if(objarrspr.rawin(i)) 
                {
                    local m=objarrspr.rawget(i);
                    m=null;
                }
            }
            objarrspr.clear();

            local len=stream.ReadInt();
            objarrlen=len;

            for(local i=0;i<objarrlen*3;i+=3)
            {
                local m=GUISprite("m.png",VectorScreen(0,0));
                m.Size=VectorScreen(GetProportion(64,"x"),GetProportion(64,"y"));
                m.Alpha=255;
                m.RemoveFlags(GUI_FLAG_VISIBLE);
                objarrspr.rawset(i,m);
            }

            if(objarrpos.len()>0)
            {
                for(local i=0;i<objarrpos.len()*3;i+=3)
                {
                    if(objarrpos.rawin(i)&&objarrspr.rawin(i)) 
                    {
                        local p=objarrpos.rawget(i);
                        local pos=GUI.WorldPosToScreen(Vector(p.X,p.Y,p.Z));
                        local dis=Distance(p.X,p.Y,p.Z,player.Position.X,player.Position.Y,player.Position.Z);
                        local size=96-(dis.tointeger()*2);

                        local m=objarrspr.rawget(i);
                        if(size>=30) m.Size=VectorScreen(GetProportion(size,"x"),GetProportion(size,"y"));
                        else m.Size=VectorScreen(GetProportion(30,"x"),GetProportion(30,"y"));
                        if(pos.Z<1) m.Pos=VectorScreen(pos.X-m.Size.X/2,pos.Y-m.Size.Y/2); 
                        m.AddFlags(GUI_FLAG_VISIBLE);
                    }
                    else break;
                }
            }
        }
        break;

        case 0x08:
        {
            hide=true;
            Console.Print("[#FFFF00]Shoot the next building that can be hidden.");
        }
        break;

        case 0x09:
        {
            cadd=true;
            Console.Print("[#FFFF00]Shooting the original object can create an identical one.");
        }
        break;

        case 0x10:
        {
            local str=stream.ReadString();
            if(str=="true") guntp=true;
            else guntp=false;
        }
        break;

        default:
        break;
    }
}

function onGameResize(width,height)
{
}

function GUI::GameResize(width,height)
{
    local bx=1520,bsize=180;

    plrinfo1.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(690,"y"));
    plrinfo1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo2.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(720,"y"));
    plrinfo2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo3.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(750,"y"));
    plrinfo3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    plrinfo4.Pos=VectorScreen(GetProportion(bx+bsize/2,"x"),GetProportion(780,"y"));
    plrinfo4.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));

    plrinlb1.FontSize=GetPropForFont(20);
    plrinlb2.FontSize=GetPropForFont(20);
    plrinlb3.FontSize=GetPropForFont(20);
    plrinlb4.FontSize=GetPropForFont(20);

    objinfo1.Pos=VectorScreen(GetProportion(bx-bsize,"x"),GetProportion(850,"y"));
    objinfo1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    objinfo2.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(850,"y"));
    objinfo2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    objinfo3.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(850,"y"));
    objinfo3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));

    objinlb1.FontSize=GetPropForFont(20);
    objinlb2.FontSize=GetPropForFont(20);
    objinlb3.FontSize=GetPropForFont(20);

    basiclb1.FontSize=GetPropForFont(20);
    basiclb1.Pos=VectorScreen(GetProportion(20,"x"),GetProportion(1010,"y"));
    basiclb2.FontSize=GetPropForFont(20);
    basiclb2.Pos=VectorScreen(GetProportion(20,"x"),GetProportion(1040,"y"));

    info1.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(900,"y"));
    info1.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info2.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(930,"y"));
    info2.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info3.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(960,"y"));
    info3.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info4.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(990,"y"));
    info4.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info10.Pos=VectorScreen(GetProportion(bx,"x"),GetProportion(1020,"y"));
    info10.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));

    inlb1.FontSize=GetPropForFont(22);
    inlb2.FontSize=GetPropForFont(18);
    inlb3.FontSize=GetPropForFont(18);
    inlb4.FontSize=GetPropForFont(18);
    inlb10.FontSize=GetPropForFont(10);

    info5.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(900,"y"));
    info5.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info6.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(930,"y"));
    info6.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info7.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(960,"y"));
    info7.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info8.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(990,"y"));
    info8.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));
    info9.Pos=VectorScreen(GetProportion(bx+bsize,"x"),GetProportion(1020,"y"));
    info9.Size=VectorScreen(GetProportion(bsize,"x"),GetProportion(30,"y"));

    inlb5.FontSize=GetPropForFont(22);
    inlb6.FontSize=GetPropForFont(18);
    inlb7.FontSize=GetPropForFont(18);
    inlb8.FontSize=GetPropForFont(18);
    inlb9.FontSize=GetPropForFont(18);

    objmenu1.Pos=VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion((1080-854)/2,"y"));
    objmenu1.Size=VectorScreen(GetProportion(1204,"x"),GetProportion(30,"y"));

    objmenu2.Pos=VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion((1080-854)/2+30,"y"));
    objmenu2.Size=VectorScreen(GetProportion(1204,"x"),GetProportion(854,"y"));
    objm.Size=VectorScreen(GetProportion(64,"x"),GetProportion(64,"y"));

    menubut1.Pos=VectorScreen(GetProportion((1920-1204)/2,"x"),GetProportion(((1080-854)/2)+30+854,"y"));
    menubut1.Size=VectorScreen(GetProportion(180,"x"),GetProportion(40,"y"));
    menubut1.FontSize=GetPropForFont(20);

    menubut2.Pos=VectorScreen(GetProportion((1920-1204)/2+1204-180,"x"),GetProportion(((1080-854)/2)+30+854,"y"));
    menubut2.Size=VectorScreen(GetProportion(180,"x"),GetProportion(40,"y"));
    menubut2.FontSize=GetPropForFont(20);
}

function GUI::ElementClick(element,mouseX,mouseY)
{
    if(element==menubut1)
    {
        menupage-=1;
        if(menupage<1) menupage=12;
        objmenu2.SetTexture("obj"+menupage+".png");
        menubut1.Text="Previous "+menupage+"/12";
        menubut2.Text="Next Page "+menupage+"/12";
    }

    if(element==menubut2)
    {
        menupage+=1;
        if(menupage>12) menupage=1;
        objmenu2.SetTexture("obj"+menupage+".png");
        menubut1.Text="Previous "+menupage+"/12";
        menubut2.Text="Next Page "+menupage+"/12";
    }
}

function KeyBind::OnDown(key)
{
    if(key==Key_Up) keyup=true;
    if(key==Key_Down) keydown=true;
    if(key==Key_Left) keyleft=true;
    if(key==Key_Right) keyright=true;
    if(key==Key_PageUp) keypageup=true;
    if(key==Key_PageDown) keypagedown=true;

    if(key==Key_Shift) keyshift=true;
    if(key==Key_Alt) keyalt=true;

    if(key==Key_M)
    {
        objmenu1.AddFlags(GUI_FLAG_VISIBLE);
        objmenu2.AddFlags(GUI_FLAG_VISIBLE);

        Hud.RemoveFlags(HUD_FLAG_CASH);
        Hud.RemoveFlags(HUD_FLAG_CLOCK);
        Hud.RemoveFlags(HUD_FLAG_WANTED);
        Hud.RemoveFlags(HUD_FLAG_HEALTH);
        Hud.RemoveFlags(HUD_FLAG_RADAR);
        Hud.RemoveFlags(HUD_FLAG_WEAPON);

        info1.RemoveFlags(GUI_FLAG_VISIBLE);
        info2.RemoveFlags(GUI_FLAG_VISIBLE);
        info3.RemoveFlags(GUI_FLAG_VISIBLE);
        info4.RemoveFlags(GUI_FLAG_VISIBLE);
        info5.RemoveFlags(GUI_FLAG_VISIBLE);
        info6.RemoveFlags(GUI_FLAG_VISIBLE);
        info7.RemoveFlags(GUI_FLAG_VISIBLE);
        info8.RemoveFlags(GUI_FLAG_VISIBLE);
        info9.RemoveFlags(GUI_FLAG_VISIBLE);
        info10.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb1.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb2.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb3.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb4.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb5.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb6.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb7.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb8.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb9.RemoveFlags(GUI_FLAG_VISIBLE);
        inlb10.RemoveFlags(GUI_FLAG_VISIBLE);

        objinfo1.RemoveFlags(GUI_FLAG_VISIBLE);
        objinfo2.RemoveFlags(GUI_FLAG_VISIBLE);
        objinfo3.RemoveFlags(GUI_FLAG_VISIBLE);
        objinlb1.RemoveFlags(GUI_FLAG_VISIBLE);
        objinlb2.RemoveFlags(GUI_FLAG_VISIBLE);
        objinlb3.RemoveFlags(GUI_FLAG_VISIBLE);

        GUI.SetMouseEnabled(true);

        menubut1.AddFlags(GUI_FLAG_VISIBLE);
        menubut2.AddFlags(GUI_FLAG_VISIBLE);
    }

    if(key==Key_W) keyw=true;
    if(key==Key_C) keyc=true;
}

function KeyBind::OnUp(key)
{
    if(key==Key_Up) keyup=false;
    if(key==Key_Down) keydown=false;
    if(key==Key_Left) keyleft=false;
    if(key==Key_Right) keyright=false;
    if(key==Key_PageUp) keypageup=false;
    if(key==Key_PageDown) keypagedown=false;

    if(key==Key_Shift) keyshift=false;
    if(key==Key_Alt) keyalt=false;

    if(key==Key_M)
    {
        objmenu1.RemoveFlags(GUI_FLAG_VISIBLE);
        objmenu2.RemoveFlags(GUI_FLAG_VISIBLE);

        Hud.AddFlags(HUD_FLAG_CASH);
        Hud.AddFlags(HUD_FLAG_CLOCK);
        Hud.AddFlags(HUD_FLAG_WANTED);
        Hud.AddFlags(HUD_FLAG_HEALTH);
        Hud.AddFlags(HUD_FLAG_RADAR);
        Hud.AddFlags(HUD_FLAG_WEAPON);

        info1.AddFlags(GUI_FLAG_VISIBLE);
        info2.AddFlags(GUI_FLAG_VISIBLE);
        info3.AddFlags(GUI_FLAG_VISIBLE);
        info4.AddFlags(GUI_FLAG_VISIBLE);
        info5.AddFlags(GUI_FLAG_VISIBLE);
        info6.AddFlags(GUI_FLAG_VISIBLE);
        info7.AddFlags(GUI_FLAG_VISIBLE);
        info8.AddFlags(GUI_FLAG_VISIBLE);
        info9.AddFlags(GUI_FLAG_VISIBLE);
        info10.AddFlags(GUI_FLAG_VISIBLE);
        inlb1.AddFlags(GUI_FLAG_VISIBLE);
        inlb2.AddFlags(GUI_FLAG_VISIBLE);
        inlb3.AddFlags(GUI_FLAG_VISIBLE);
        inlb4.AddFlags(GUI_FLAG_VISIBLE);
        inlb5.AddFlags(GUI_FLAG_VISIBLE);
        inlb6.AddFlags(GUI_FLAG_VISIBLE);
        inlb7.AddFlags(GUI_FLAG_VISIBLE);
        inlb8.AddFlags(GUI_FLAG_VISIBLE);
        inlb9.AddFlags(GUI_FLAG_VISIBLE);
        inlb10.AddFlags(GUI_FLAG_VISIBLE);

        objinfo1.AddFlags(GUI_FLAG_VISIBLE);
        objinfo2.AddFlags(GUI_FLAG_VISIBLE);
        objinfo3.AddFlags(GUI_FLAG_VISIBLE);
        objinlb1.AddFlags(GUI_FLAG_VISIBLE);
        objinlb2.AddFlags(GUI_FLAG_VISIBLE);
        objinlb3.AddFlags(GUI_FLAG_VISIBLE);

        GUI.SetMouseEnabled(false);

        menubut1.RemoveFlags(GUI_FLAG_VISIBLE);
        menubut2.RemoveFlags(GUI_FLAG_VISIBLE);

        GUI.SetFocusedElement(null);
    }

    if(key==Key_W) keyw=false;
    if(key==Key_C) keyc=false;
}

function SendDataToServer(...)
{
    if(vargv[0])
    {
        local byte=vargv[0],len=vargv.len(); 
        if(1>len) Console.Print("ToClent <"+byte+"> No params specified.");
        else
        {
            local pftStream=Stream();
            pftStream.WriteByte(byte);
            for(local i=1;i<len;i++)
            {
                switch(typeof(vargv[i]))
                {
                    case "integer": pftStream.WriteInt(vargv[i]); break;
                    case "string": pftStream.WriteString(vargv[i]); break;
                    case "float": pftStream.WriteFloat(vargv[i]); break;
                }
            }
            Server.SendData(pftStream);
        }
    }
    else Console.Print("ToClient: Not even the byte was specified...");
}

function errorHandling(err)
{
	local stackInfos=getstackinfos(2);
	if(stackInfos) 
    {
	 	local locals="";
	 	foreach(index,value in stackInfos.locals) locals=locals+"["+index+": "+typeof(value)+"] "+value+"\n";
	 	local callStacks="";
	 	local level=2;
	 	do 
        {
	 	 	callStacks+="*FUNCTION ["+stackInfos.func+"()] "+stackInfos.src+" line ["+stackInfos.line+"]\n";
	 	 	level++;
	 	} 
        while((stackInfos=getstackinfos(level)));
	 	local errorMsg="AN ERROR HAS OCCURRED ["+err+"]\n";
	 	errorMsg+="\nCALLSTACK\n";
	 	errorMsg+=callStacks;
	 	errorMsg+="\nLOCALS\n";
	 	errorMsg+=locals;
		foreach(i,a in split(errorMsg,"\n")) Console.Print("[#FFFFFF]Client Exception: "+a);
	}
}

function GetProportion(a,b)
{
    local x=GUI.GetScreenSize().X,y=GUI.GetScreenSize().Y;
    if(b=="x")
    {
        a=(a.tofloat()*x.tofloat())/1920;
        local c=x.tofloat()*(a.tofloat()/x.tofloat());

        if(c.tointeger()<1) return c.tointeger()+1;
        else return c.tointeger();
    }
    if(b=="y")
    {
        a=(a.tofloat()*y.tofloat())/1080;
        local c=y.tofloat()*(a.tofloat()/y.tofloat());
        
        if(c.tointeger()<1) return c.tointeger()+1;
        else return c.tointeger();
    }
}

function Decimal(a,b)
{
	local s=pow(10,b);
	local a=((a.tofloat()*s.tofloat()).tointeger()).tofloat()/s.tofloat();
	if(a==(-0)) a=0;
	return a;
}

function GetAngle(m)
{
    local angle;
    local a=GUI.ScreenPosToWorld(Vector(GUI.GetScreenSize().X/2,GUI.GetScreenSize().Y/2,1));
    local b=GUI.ScreenPosToWorld(Vector(GUI.GetScreenSize().X/2,GUI.GetScreenSize().Y/2,-1));
    if(m=="x") angle=-atan2(a.X-b.X,a.Y-b.Y);
    if(m=="y") angle=-atan2(b.Y-a.Y,a.Z-b.Z);
    angle=(angle*100).tointeger();
    angle=angle.tofloat()*0.01;
    return angle;
}

function Distance(x1,y1,z1,x2,y2,z2)
{
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
}

function GetPropForFont(a)
{
    local xy=GUI.GetScreenSize().X+GUI.GetScreenSize().Y;
    a=(a.tofloat()*xy.tofloat())/(1920+1080);
    local c=xy.tofloat()*(a.tofloat()/xy.tofloat());

    if(c.tointeger()<1) return c.tointeger()+1;
    else return c.tointeger();
}