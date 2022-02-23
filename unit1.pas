unit Unit1;

{$mode objfpc}{$H+}

interface



uses
  Classes, SysUtils, Windows, LCLIntf, FileUtil, MMSystem, Forms, Controls,
  Math, Graphics, Dialogs, StdCtrls, LCLType, ExtCtrls, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblScore: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuNeuesSpiel: TMenuItem;
    MenuItem3: TMenuItem;
    MenuPause: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Shape1: TShape;
    Timer2: TTimer;
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuPauseClick(Sender: TObject);
    procedure MenuNeuesSpielClick(Sender: TObject);
    function ShapeErstellen(Block, Shape: integer): TShape;
    function NextShapeErstellen(Block, Shape: integer): TShape;
    function HoldShapeErstellen(Block, i: integer): TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure BlockErstellen;
    procedure ShapeSpeichern;
    procedure Drehen;
    procedure Kollisionsabfrage;
    procedure Stop;
    procedure Start;
    procedure Pause;
    procedure ZeilenLoeschen;
    procedure Highscore;
    procedure Hold;
    procedure Timer2Timer(Sender: TObject);
  private
    Shape: array[1..7, 1..4] of TShape;
    NextShape: array[1..4] of TShape;
    HoldShape: array [1..4] of TShape;
    Formen: array[1..7, 1..4] of TPoint;
    zahl, Score, NextBlock, Zahlhold, Center1, center2: integer;
    shapesunten: array of tshape;
    PanelTouched, LeftTouched, RightTouched, InterSectLinks, InterSectRechts: boolean;

  public
    GlobalScore: integer;
    HighscoreA: array of integer;
    HighscoreName: array of string;

  end;

var
  Form1: TForm1;

implementation

uses
  Unit4, Unit5, Unit6;

{$R *.lfm}

{ TForm1 }




procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i, j, k: integer;
  t: array[1..4] of integer;
begin

  PanelTouched := False;
  InterSectLinks := False;
  InterSectRechts := False;

  for i := 1 to 4 do
  begin

    if (Shape[Zahl, i].Top = 500) then
    begin
      PanelTouched := True;
      Shape[Zahl, i].Top := Shape[Zahl, i].Top - 25;
    end;

    if (Shape[Zahl, i].Left = 0) then
      InterSectLinks := True;

    if (Shape[Zahl, i].Left = 225) then
      interSectRechts := True;
  end;

  if key = vk_down then
  begin
    Timer2.Interval := 50;
  end;

  if key = VK_Up then
    Drehen;

  for i := 1 to 4 do
    t[i] := Shape[Zahl, i].Left;

  if key = vk_left then
  begin
    for I := 1 to 4 do
    begin
      if InterSectLinks = False then
      begin
        Shape[Zahl, i].Left := (Shape[Zahl, i].Left) - 25;
        for j := low(shapesunten) to high(shapesunten) do
        begin
          if (shape[Zahl, i].BoundsRect.IntersectsWith(shapesunten[j].BoundsRect)) and
            (shapesunten[j].Visible = True) then
          begin
            for k := 1 to 4 do
            begin
              Shape[Zahl, k].Left := t[k];
            end;
            InterSectLinks := True;
          end;
        end;
      end;
    end;
  end;


  if key = vk_right then
  begin
    for I := 1 to 4 do
    begin
      if InterSectRechts = False then
      begin
        Shape[Zahl, i].Left := (Shape[Zahl, i].Left) + 25;
        for j := low(shapesunten) to high(shapesunten) do
        begin
          if (shape[Zahl, i].BoundsRect.IntersectsWith(shapesunten[j].BoundsRect)) and
            (shapesunten[j].Visible = True) then
          begin
            for k := 1 to 4 do
            begin
              Shape[Zahl, k].Left := t[k];
            end;
            InterSectRechts := True;
          end;
        end;
      end;
    end;
  end;


  if key = VK_Escape then
    Pause;

  if key = VK_C then
  begin
    Timer2.Enabled := False;
    Hold;
  end;


  key := 0;

end;

procedure TForm1.Hold;
var
  i: integer;
begin

  for i := 1 to 4 do
  begin
    Shape[Zahl, i].Visible := False;
    HoldShape[i].Visible := False;
  end;

  Zahl := Zahl xor ZahlHold;
  ZahlHold := ZahlHold xor Zahl;
  Zahl := Zahl xor zahlHold;

  for i := 1 to 4 do
  begin
    Shape[Zahl, i] := ShapeErstellen(Zahl, i);
    HoldShape[i] := HoldShapeErstellen(ZahlHold, i);
  end;

  Timer2.Enabled := True;

end;

procedure TForm1.MenuPauseClick(Sender: TObject);
begin
  Pause;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  Timer2.Enabled := True;
  Timer2.Interval := 750;
end;

procedure TForm1.MenuNeuesSpielClick(Sender: TObject);
begin
  Stop;
  Form3.Hide;
  Timer2.Enabled := True;
  Timer2.Interval := 750;
  Start;
end;


procedure TForm1.Pause;
begin
  Form3.Show;
  Timer2.Enabled := False;
end;




procedure TForm1.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if key = VK_DOWN then
    Timer2.Interval := 750;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Start;
end;

procedure TForm1.Start;
var
  x, i: integer;
begin

  PlaySound('TetrisTheme.wav', 0, SND_ASYNC);

  Timer2.Interval := 750;

  PanelTouched := False;
  InterSectLinks := False;
  InterSectRechts := False;
  LeftTouched := False;
  RightTouched := False;

  Formen[1, 1].x := 75;  //4
  Formen[1, 1].y := 0;   //1
  Formen[1, 2].x := 100; //5
  Formen[1, 2].y := 0;   //1
  Formen[1, 3].x := 125; //6
  Formen[1, 3].y := 0;   //1
  Formen[1, 4].x := 150; //7
  Formen[1, 4].y := 0;   //1

  Formen[2, 1].x := 100; //5
  Formen[2, 1].y := 0;   //1
  Formen[2, 2].x := 125; //6
  Formen[2, 2].y := 0;   //1
  Formen[2, 3].x := 125; //6
  Formen[2, 3].y := 25;  //2
  Formen[2, 4].x := 150; //7
  Formen[2, 4].y := 25;  //2

  Formen[3, 1].x := 100; //5
  Formen[3, 1].y := 25;  //2
  Formen[3, 2].x := 125; //6
  Formen[3, 2].y := 25;  //2
  Formen[3, 3].x := 125; //6
  Formen[3, 3].y := 0;   //1
  Formen[3, 4].x := 150; //7
  Formen[3, 4].y := 0;   //1

  Formen[4, 1].x := 100; //5
  Formen[4, 1].y := 0;   //1
  Formen[4, 2].x := 125; //6
  Formen[4, 2].y := 0;   //1
  Formen[4, 3].x := 100; //5
  Formen[4, 3].y := 25;  //2
  Formen[4, 4].x := 125; //6
  Formen[4, 4].y := 25;  //2

  Formen[5, 1].x := 100; //5
  Formen[5, 1].y := 0;   //1
  Formen[5, 2].x := 125; //6
  Formen[5, 2].y := 0;   //1
  Formen[5, 3].x := 150; //7
  Formen[5, 3].y := 0;   //1
  Formen[5, 4].x := 150; //7
  Formen[5, 4].y := 25;  //2

  Formen[6, 1].x := 100; //5
  Formen[6, 1].y := 0;   //1
  Formen[6, 2].x := 100; //5
  Formen[6, 2].y := 25;  //2
  Formen[6, 3].x := 125; //6
  Formen[6, 3].y := 0;   //1
  Formen[6, 4].x := 150; //7
  Formen[6, 4].y := 0;   //1

  Formen[7, 1].x := 100; //5
  Formen[7, 1].y := 0;   //1
  Formen[7, 2].x := 125; //6
  Formen[7, 2].y := 0;   //1
  Formen[7, 3].x := 150; //7
  Formen[7, 3].y := 0;   //1
  Formen[7, 4].x := 125; //6
  Formen[7, 4].y := 25;  //2



  SetLength(shapesunten, length(shapesunten) + 1);
  x := high(shapesunten);
  ShapesUnten[x] := Shape1;


  Randomize;
  NextBlock := (RandomRange(1, 8));
  Blockerstellen;
  Timer2.Enabled := True;

  Zahlhold := 4;
  for i := 1 to 4 do
    HoldShape[i] := (HoldShapeErstellen(4, i));

end;

procedure TForm1.Highscore;
var
  x: integer;
  ListBoxItem: string;
begin
  SetLength(HighscoreA, length(HighscoreA) + 1);
  x := high(HighscoreA);
  HighscoreA[x] := Score;

  SetLength(HighscoreName, length(HighscoreName) + 1);
  x := high(HighscoreName);
  HighscoreName[x] := Form4.edtName.Text;

  ListBoxitem := (HighscoreName[x] + '-' + IntToStr(HighscoreA[x]));
  Form5.ListBox1.Items.Add(ListBoxitem);
end;

procedure TForm1.Stop;
var
  i: integer;
begin

  Highscore;
  Form4.lblScore.Caption := IntToStr(Score);
  Score := 0;
  Form4.Show;
  lblScore.Caption := '0';
  for i := low(shapesunten) to high(shapesunten) do
    shapesunten[i].Visible := False;

  for i := 1 to 4 do
  begin
    Shape[Zahl, i].Visible := False;
    NextShape[i].Visible := False;
    HoldShape[i].Visible := False;
  end;

  Timer2.Enabled := False;

end;

function TForm1.ShapeErstellen(Block, Shape: integer): TShape;
begin
  Result := tShape.Create(Panel1);
  Result.parent := Panel1;
  Result.Visible := True;
  Result.Height := 25;
  Result.Width := 25;
  Result.top := Formen[Block, Shape].y;
  Result.Left := Formen[Block, Shape].x;

  case Block of
    1: Result.Brush.Color := RGB(123, 112, 218);
    2: Result.Brush.Color := clRed;
    3: Result.Brush.Color := RGB(0, 204, 0);
    4: Result.Brush.Color := RGB(255, 255, 0);
    5: Result.Brush.Color := clBlue;
    6: Result.Brush.Color := RGB(255, 128, 0);
    7: Result.Brush.Color := clFuchsia;
  end;
end;



function TForm1.NextShapeErstellen(Block, Shape: integer): TShape;
begin
  Result := tShape.Create(Panel2);
  Result.parent := Panel2;
  Result.Visible := True;
  Result.Height := 25;
  Result.Width := 25;
  Result.top := Formen[Block, Shape].y + 25;
  Result.Left := Formen[Block, Shape].x - 50;

  case Block of
    1: Result.Brush.Color := RGB(123, 112, 218);
    2: Result.Brush.Color := clRed;
    3: Result.Brush.Color := RGB(0, 204, 0);
    4: Result.Brush.Color := RGB(255, 255, 0);
    5: Result.Brush.Color := clBlue;
    6: Result.Brush.Color := RGB(255, 128, 0);
    7: Result.Brush.Color := clFuchsia;
  end;
end;

function TForm1.HoldShapeErstellen(Block, i: integer): TShape;
begin

  Result := tShape.Create(Panel3);
  Result.parent := Panel3;
  Result.Visible := True;
  Result.Height := 25;
  Result.Width := 25;
  Result.top := Formen[Block, i].y + 25;
  Result.Left := Formen[Block, i].x - 50;
  Result.Brush.Color := RGB(255, 255, 0);

  case Block of
    1: Result.Brush.Color := RGB(123, 112, 218);
    2: Result.Brush.Color := clRed;
    3: Result.Brush.Color := RGB(0, 204, 0);
    4: Result.Brush.Color := RGB(255, 255, 0);
    5: Result.Brush.Color := clBlue;
    6: Result.Brush.Color := RGB(255, 128, 0);
    7: Result.Brush.Color := clFuchsia;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
  i: integer;
begin

  PanelTouched := False;

  if Timer2.Interval = 50 then
  begin
    Inc(Score, 3);
    lblScore.Caption := IntToStr(Score);
  end;

  for i := 1 to 4 do
    Shape[Zahl, i].Top := Shape[Zahl, i].Top + 25;

  for i := 1 to 4 do
  begin
    if Shape[Zahl, i].Top = 500 then
      PanelTouched := True;
    Kollisionsabfrage;

  end;

  if PanelTouched = True then
  begin
    for i := 1 to 4 do
      Shape[Zahl, i].Top := Shape[Zahl, i].Top - 25;

    ShapeSpeichern;
    BlockErstellen;
    ZeilenLoeschen;

  end;

end;

procedure TForm1.Kollisionsabfrage;
var
  i, j: integer;
begin
  for i := 1 to 4 do
  begin
    for j := low(shapesunten) to high(shapesunten) do
    begin
      if shape[Zahl, i].BoundsRect.IntersectsWith(shapesunten[j].BoundsRect) then
        if shapesunten[j].Visible = True then
          PanelTouched := True;
    end;
  end;

end;

procedure TForm1.BlockErstellen;
var
  i: integer;
begin
  Zahl := NextBlock;
  NextBlock := (RandomRange(1, 8));

  for i := 1 to 4 do
    Shape[Zahl, i] := ShapeErstellen(Zahl, i);

  for i := 1 to 4 do
    NextShape[i].Free;

  for i := 1 to 4 do
    NextShape[i] := NextShapeErstellen(NextBlock, i);
end;

procedure TForm1.ShapeSpeichern;
var
  i, x: integer;
  Oben: boolean;
begin
  Oben := False;
  for i := 1 to 4 do
  begin
    SetLength(shapesunten, length(shapesunten) + 1);
    x := high(shapesunten);
    shapesunten[x] := shape[zahl, i];
    if Shapesunten[x].Top = 0 then
      Oben := True;
  end;
  if Oben = True then
    Stop;
end;

procedure TForm1.Drehen;
var
  d1, d2, i, j: integer;
  y1, x1: double;
  LeftSave: array [1..4] of integer;
  TopSave: array [1..4] of integer;
  InterSect: boolean;
begin

  InterSect := False;

  case Zahl of
    1:
    begin
      center1 := Shape[Zahl, 3].Left;
      center2 := Shape[Zahl, 3].Top;
    end;
    2:
    begin
      center1 := Shape[Zahl, 3].Left;
      center2 := Shape[Zahl, 3].Top;
    end;
    3:
    begin
      center1 := Shape[Zahl, 2].Left;
      center2 := Shape[Zahl, 2].Top;
    end;
    4:
    begin
      center1 := Shape[Zahl, 4].Left;
      center2 := Shape[Zahl, 4].Top;
    end;
    5:
    begin
      center1 := Shape[Zahl, 4].Left;
      center2 := Shape[Zahl, 4].Top;
    end;
    6:
    begin
      center1 := Shape[Zahl, 2].Left;
      center2 := Shape[Zahl, 2].Top;
    end;
    7:
    begin
      center1 := Shape[Zahl, 4].Left;
      center2 := Shape[Zahl, 4].Top;
    end;
  end;


  for i := 1 to 4 do
  begin
    LeftSave[i] := Shape[Zahl, i].Left;
    TopSave[i] := Shape[Zahl, i].Top;
  end;

  for i := 1 to 4 do
  begin
    d1 := Shape[Zahl, i].Left - Center1;
    d2 := Shape[Zahl, i].Top - Center2;
    x1 := -d2;
    y1 := d1;
    Shape[Zahl, i].Left := round(x1) + Center1;
    Shape[Zahl, i].Top := round(y1) + Center2;
  end;

  for i := 1 to 4 do
  begin
    for j := low(shapesunten) to high(shapesunten) do
    begin
      if shape[Zahl, i].BoundsRect.IntersectsWith(shapesunten[j].BoundsRect) then
        if shapesunten[j].Visible = True then
          InterSect := True;
    end;
  end;

  if InterSect = True then
  begin
    for i := 1 to 4 do
    begin
      Shape[Zahl, i].Left := LeftSave[i];
      Shape[Zahl, i].Top := TopSave[i];
    end;
  end;

  repeat
    LeftTouched := False;
    RightTouched := False;
    for i := 1 to 4 do
    begin
      if Shape[Zahl, i].Left < 0 then
        LeftTouched := True;
      if Shape[Zahl, i].Left >= 250 then
        RightTouched := True;
    end;
    for i := 1 to 4 do
    begin
      if LeftTouched = True then
        Shape[Zahl, i].Left := Shape[Zahl, i].Left + 25;
      if RightTouched = True then
        Shape[Zahl, i].Left := Shape[Zahl, i].Left - 25;
    end;
  until (RightTouched = False) and (LeftTouched = False);
end;

procedure TForm1.ZeilenLoeschen;
var
  Spalte: array [1..10] of integer;
  ShapesIndex, ShapeTop, i, j: integer;

begin
  ShapeTop := 25;
  repeat
    j := 1;
    for i := low(shapesunten) to high(shapesunten) do
    begin
      if (ShapesUnten[i].Top = ShapeTop) and (ShapesUnten[i].Visible = True) then
      begin
        Spalte[j] := i;
        Inc(j);
      end;
    end;
    ShapeTop := ShapeTop + 25;

  until (j = 11) or (ShapeTop = 500);


  if j = 11 then
  begin
    for i := 1 to 10 do
    begin
      ShapesIndex := Spalte[i];
      if ShapesUnten[ShapesIndex].Visible = True then
        ShapesUnten[ShapesIndex].Visible := False;
    end;
  end;

  if j = 11 then
  begin
    for i := low(shapesunten) to high(shapesunten) do
    begin
      if ShapesUnten[i].Top <= ShapeTop - 50 then
      begin
        ShapesUnten[i].Top := ShapesUnten[i].Top + 25;
      end;
    end;
  end;

  if j = 11 then
  begin
    ZeilenLoeschen;
    Inc(Score, 1000);
    lblScore.Caption := IntToStr(Score);
  end;

end;

end.
