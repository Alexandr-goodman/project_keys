unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, ODBCConn, Dialogs;

type

  { Tdm }

  Tdm = class(TDataModule)
    ODBCCon: TODBCConnection;       // Компонент для подключения к БД через ODBC
    SQLQue: TSQLQuery;                // Компонент для выполнения SQL-запросов
    SQLTran: TSQLTransaction;           // Компонент для управления транзакциями
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function ConnectToDB: Boolean;   // Подключение к БД
    function AddRecord(FirstName, LastName, EmpPos, Department, HireDate: string): Boolean;   // Добавление записи
    function UpdateRecord(ID: Integer; FirstName, LastName, EmpPos, Department, HireDate: string): Boolean;   // Обновление записи
    function DeleteRecord(ID: Integer): Boolean;   // Удаление записи
  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

{ Tdm }
// Создание модуля данных и автоматически подключается при создании
procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  ConnectToDB;
end;
 // Подключение К бд
// Настройка параметров ODBC и установка соединения
function Tdm.ConnectToDB: Boolean;
begin
  Result := False;
  try   // Указываем, что используем ODBC драйвер
    ODBCCon.Driver := 'ODBC';
    ODBCCon.DatabaseName := 'MyCompanyDB';
     // Параметры подключения
    ODBCCon.Params.Clear;
    ODBCCon.Params.Add('DSN=MyCompanyDB');
    ODBCCon.Params.Add('UID=Alexandr--');
    ODBCCon.Params.Add('PWD=Sanya200525Pomelov');
    ODBCCon.Params.Add('DATABASE=CompanyDB');
    ODBCCon.Params.Add('SERVER=KOMPUTER\SQLEXPRESS');
    ODBCCon.Params.Add('Trusted_Connection=No');
     // Связываем компоненты
    SQLTran.DataBase := ODBCCon;
    SQLQue.DataBase := ODBCCon;
    SQLQue.Transaction := SQLTran;
     // Устанавливаем соединение
    ODBCCon.Connected := True;
    SQLTran.Active := True;

    Result := True;
    ShowMessage(' Подключение к SQL Server через ODBC успешно!');

  except
    on E: Exception do
      ShowMessage('Ошибка подключения: ' + E.Message);
  end;
end;
// ДОБАВЛЕНИЕ ЗАПИСИ
// Выполняет INSERT запрос и фиксирует транзакцию
function Tdm.AddRecord(FirstName, LastName, EmpPos, Department, HireDate: string): Boolean;
begin
  Result := False;
  try
    SQLQue.Close; // SQL-запрос на добавление новой записи
    SQLQue.SQL.Text := 'INSERT INTO Employees (FirstName, LastName, Position, Department, HireDate) ' +
                       'VALUES (' +
                       QuotedStr(FirstName) + ', ' +
                       QuotedStr(LastName) + ', ' +
                       QuotedStr(EmpPos) + ', ' +
                       QuotedStr(Department) + ', ' +
                       QuotedStr(HireDate) + ')';
    SQLQue.ExecSQL;  // Выполняем запрос
    SQLTran.Commit;   // Фиксируем изменения
    SQLTran.StartTransaction;  // Начинаем новую транзакцию
    Result := True;
    ShowMessage(' Запись добавлена!');
  except
    on E: Exception do
    begin
      SQLTran.Rollback;    // Откат при ошибке
      ShowMessage('❌ Ошибка добавления: ' + E.Message);
    end;
  end;
end;
// ОБНОВЛЕНИЕ ЗАПИСИ
// Выполняет UPDATE запрос для указанной записи по ID
function Tdm.UpdateRecord(ID: Integer; FirstName, LastName, EmpPos, Department, HireDate: string): Boolean;
begin
  Result := False;
  try
    SQLQue.Close;  // SQL-запрос на обновление записи с указанным ID
    SQLQue.SQL.Text := 'UPDATE Employees SET ' +
                       'FirstName = ' + QuotedStr(FirstName) + ', ' +
                       'LastName = ' + QuotedStr(LastName) + ', ' +
                       'Position = ' + QuotedStr(EmpPos) + ', ' +
                       'Department = ' + QuotedStr(Department) + ', ' +
                       'HireDate = ' + QuotedStr(HireDate) + ' ' +
                       'WHERE EmployeeID = ' + IntToStr(ID);
    SQLQue.ExecSQL;
    SQLTran.Commit;
    SQLTran.StartTransaction;
    Result := True;
    ShowMessage('Запись обновлена!');
  except
    on E: Exception do
    begin
      SQLTran.Rollback;
      ShowMessage(' Ошибка обновления: ' + E.Message);
    end;
  end;
end;
// УДАЛЕНИЕ ЗАПИСИ
// Выполняет DELETE запрос для записи с указанным ID
function Tdm.DeleteRecord(ID: Integer): Boolean;
begin
  Result := False;
  try
    SQLQue.Close;
     // SQL-запрос на удаление записи с указанным ID
    SQLQue.SQL.Text := 'DELETE FROM Employees WHERE EmployeeID = ' + IntToStr(ID);
    SQLQue.ExecSQL;
    SQLTran.Commit;
    SQLTran.StartTransaction;
    Result := True;
    ShowMessage(' Запись удалена!');
  except
    on E: Exception do
    begin
      SQLTran.Rollback;
      ShowMessage('❌ Ошибка удаления: ' + E.Message);
    end;
  end;
end;

end.
