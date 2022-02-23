unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    btnWeiter: TButton;
    btnStop: TButton;
    btnNew: TButton;
    btnHighscore: TButton;
    procedure btnHighscoreClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnWeiterClick(Sender: TObject);

  private

  public

  end;

var
  Form3: TForm3;

implementation

uses
  Unit1,Unit6;

{$R *.lfm}

{ TForm3 }

procedure TForm3.btnWeiterClick(Sender: TObject);
begin
  Form3.Hide;
  Form1.Timer2.Enabled:=true;
  Form1.Timer2.Interval:=750;
end;

procedure TForm3.btnStopClick(Sender: TObject);
begin
  Form1.Stop;
  Form3.Hide;
  Form1.Timer2.Interval:=750;
end;

procedure TForm3.btnNewClick(Sender: TObject);
begin
  Form1.Stop;
  Form3.Hide;
  Form1.Timer2.Interval:=750;
  Form1.Start;

end;

procedure TForm3.btnHighscoreClick(Sender: TObject);
begin
  Form5.Show;
end;


end.

