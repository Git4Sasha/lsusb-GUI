unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes
  , SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , StdCtrls
  , EditNum
  , process
  , StringWork

  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnGetDescruptors: TButton;
    ednPID: TEditNum;
    ednVID: TEditNum;
    logm: TMemo;
    procedure btnClearClick(Sender: TObject);
    procedure btnGetDescruptorsClick(Sender: TObject);
  private
    lsusbproc:TProcess;
    exelogout:TStringList;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnGetDescruptorsClick(Sender: TObject);
var
  i:Integer;
  str,strvidpid:string;
  bns,dns:string;
begin
  strvidpid:=ednVID.Text+':'+ednPID.Text;

  lsusbproc:=TProcess.Create(nil);
  lsusbproc.Options:=lsusbproc.Options + [poWaitOnExit, poUsePipes, poStderrToOutPut];
  lsusbproc.Executable:='lsusb';

  lsusbproc.Execute;

  exelogout:=TStringList.Create;
  exelogout.LoadFromStream(lsusbproc.Output);

  lsusbproc.Free;
  lsusbproc:=nil;

  logm.Clear;
  logm.Lines.AddStrings(exelogout);

  for i:=0 to exelogout.Count-1 do begin
    str:=exelogout.Strings[i];
    if pos(strvidpid, str)<>0 then begin
      logm.Lines.Add(Format('Описатели для устройства с VID:PID = %s',[strvidpid]));
      Break;
    end;
  end;
  exelogout.Free;

  bns:=CopyString('Bus ', ' Device', str, True);
  if bns<>'' then begin
    dns:=CopyString('Device ', ': ', str, True);
    if dns<>'' then begin
      if Pos(strvidpid, str)>1 then begin
        lsusbproc:=TProcess.Create(nil);
        lsusbproc.Options:=lsusbproc.Options + [poWaitOnExit, poUsePipes, poStderrToOutPut];
        lsusbproc.Parameters.Add('-s');
        lsusbproc.Parameters.Add(bns+':'+dns);
        lsusbproc.Parameters.Add('-v');

        lsusbproc.Executable:='lsusb';

        lsusbproc.Execute;



        exelogout:=TStringList.Create;
        exelogout.LoadFromStream(lsusbproc.Output);

        logm.Lines.AddStrings(exelogout);

        //for i:=0 to exelogout.Count-1 do begin
        //  if exelogout.Strings[i]<>'' then
        //    lbLogOut.Items.Add(exelogout.Strings[i]);
        //end;
        //lbLogOut.Items.AddStrings(exelogout);

        lsusbproc.Free;
        lsusbproc:=nil;
        exelogout.Free;
      end else begin
        logm.Lines.Add('Устройство не найдено');
      end;
    end;
  end;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  logm.Clear;
end;

end.

