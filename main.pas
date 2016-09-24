unit main;

interface

uses
  Forms, Graphics,
  Controls, GR32, GR32_Image, Classes, StdCtrls;
type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Image321: TImage32;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  Form1: TForm1;

implementation

uses luaFunctions;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Canvas: TCanvas;
begin
  Image321.SetupBitmap();

  Canvas := TCanvas.Create; 
  try
    Canvas.Handle := Image321.Bitmap.Handle; 
	  Execute(Memo1.Text);

  finally
    Canvas.Free;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Image321.Bitmap.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
	Image321.Bitmap.RenderText(10,10,'Hello World',0,clRed32);
end;

end.
