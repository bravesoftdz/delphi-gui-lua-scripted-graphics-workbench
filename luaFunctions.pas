unit luaFunctions;

interface
uses
  csintf,sysutils,classes,lua,lauxlib,luadebug,lualib;

var
  L: Plua_state;
  colorTag: integer;
  colorList: TList;

	procedure d(statement: string);
  function lua_print(L: Plua_State): Integer; cdecl;
  function lua_pixel(L: Plua_State): Integer; cdecl;
  function lua_point(L: Plua_State): Integer; cdecl;
  function lua_line(L: Plua_State): Integer; cdecl;
	function lua_debug(L: Plua_State): Integer; cdecl;
  procedure Execute(Str: string);

implementation
uses main,GR32, GR32_Image;

// color(red,green,blue,alpha=255) returns TColor32
function lua_color(L: Plua_State): integer; cdecl;
var
  r,g,b,a:byte;
  p : PColor32;
begin
  r := round(luaL_opt_number(L,1,255));
  g := round(luaL_opt_number(L,2,255));
  b := round(luaL_opt_number(L,3,255));
  a := round(luaL_opt_number(L,4,255));
//  lua_pushnumber(L,color32(r,g,b,a));
  New(p);
	p^ := color32(r,g,b,a);
  colorList.Add(p);
	lua_pushusertag(L,p,colorTag);
  result := 1;
end;

function lua_color_getTable(L: Plua_State): Integer; cdecl;
var
  element : string;
begin
  result := 1;
  element := lua_tostring(L,2);
  if element = 'alpha' then
    lua_pushnumber(L,PColor32(lua_touserdata(L,1))^ and $FF000000 shr 24)
  else if element = 'red' then
    lua_pushnumber(L,PColor32(lua_touserdata(L,1))^ and $00FF0000 shr 16)
  else if element = 'green' then
    lua_pushnumber(L,PColor32(lua_touserdata(L,1))^ and $0000FF00 shr 8)
  else if element = 'blue' then
    lua_pushnumber(L,PColor32(lua_touserdata(L,1))^ and $000000FF)
  else
    result := 0
end;

function lua_color_setTable(L: Plua_State): Integer; cdecl;
var
  element : string;
begin
  result := 0;
  element := lua_tostring(L,2);
  if element = 'alpha' then
    PColor32(lua_touserdata(L,1))^ := (PColor32(lua_touserdata(L,1))^ and $00FFFFFF)+(round(luaL_opt_number(L,3,255)) shl 24)
  else if element = 'red' then
    PColor32(lua_touserdata(L,1))^ := (PColor32(lua_touserdata(L,1))^ and $FF00FFFF)+(round(luaL_opt_number(L,3,255)) shl 16)
  else if element = 'green' then
    PColor32(lua_touserdata(L,1))^ := (PColor32(lua_touserdata(L,1))^ and $FFFF00FF)+(round(luaL_opt_number(L,3,255)) shl 8)
  else if element = 'blue' then
    PColor32(lua_touserdata(L,1))^ := (PColor32(lua_touserdata(L,1))^ and $FFFFFF00)+(round(luaL_opt_number(L,3,255)))
end;

function lua_pixel(L: Plua_State): Integer; cdecl;
var
  x, y: TFixed;
  p: PColor32;
begin
  x := Round(lua_tonumber(L,1));
  y := Round(lua_tonumber(L,2));
  New(p);
  p^ := Form1.Image321.Bitmap.Pixel[x,y];
  colorList.Add(p);
	lua_pushusertag(L,p,colorTag);
  Result := 1;
end;

function lua_point(L: Plua_State): Integer; cdecl;
var
  x, y: TFixed;
  c : TColor32;
begin
  x := Round(lua_tonumber(L,1) * 65536);
  y := Round(lua_tonumber(L,2) * 65536);
  c := Round(TColor32(lua_touserdata(L,3)^));
  Form1.Image321.Bitmap.SetPixelXS(x,y,c);
  result := 0;
end;

function lua_line(L: Plua_State): Integer; cdecl;
var
  x1,y1,x2,y2 : Integer;
  c : TColor32;
begin
  x1 := Round(lua_tonumber(L,1));
  y1 := Round(lua_tonumber(L,2));
  x2 := Round(lua_tonumber(L,3));
  y2 := Round(lua_tonumber(L,4));
  c  := Round(TColor32(lua_touserdata(L,5)^));
  Form1.Image321.Bitmap.LineAS(x1,y1,x2,y2,c,False);
  Result := 0
end;

function lua_print(L: Plua_State): Integer; cdecl;
begin
	d(floattostr(lua_tonumber(L,1)));
  result := 0;
end;

function lua_debug(L: Plua_State): Integer; cdecl;
var
  N, I: Integer;
begin
  N := lua_gettop(L);    
  for I := 1 to N do
  begin
    if I > 1 then
      Form1.Memo2.Lines.Add(#9);
    if lua_isstring(L, I) <> 0 then   
      Form1.Memo2.Lines.Add(StringReplace(lua_tostring(L, I), #10, #13#10, [rfReplaceAll]))  
    else
      Form1.Memo2.Lines.Add(Format('%s:%p', [lua_typename(L, lua_type(L, i)),  
                                lua_topointer(L, i)]))            
  end;
  Form1.Memo2.Lines.Add(#13#10);
  Result := 0           
end;

procedure Execute(Str: string);
begin
//  Form1.Image321.Bitmap.LineA(10,10,20,50,clYellow32,False);
  Form1.Memo2.Lines.Add('Executing...');
  L := lua_open(0);
  lua_mathlibopen(L);

  colorList := TList.Create;
	colorTag := lua_newtag(L);
  lua_register(L, 'color', lua_color);
  lua_pushcfunction(L, lua_color_getTable);
  lua_settagmethod(L, colorTag, 'gettable');
  lua_pushcfunction(L, lua_color_SetTable);
  lua_settagmethod(L, colorTag, 'settable');

  lua_register(L, 'print', lua_print);
  lua_register(L, 'point', lua_point);
  lua_register(L, 'line', lua_line);
  lua_register(L, 'pixel', lua_pixel);
	lua_register(L, LUA_ERRORMESSAGE, lua_debug);
  lua_dostring(L, PChar(Str));
  lua_close(L);
end;

procedure d(statement: string);
begin
	form1.Memo2.Lines.Append('debug:'+statement);
end;

end.
