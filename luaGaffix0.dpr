program luaGaffix0;

uses
  Forms,
  main in 'main.pas' {Form1},
  luaFunctions in 'luaFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
