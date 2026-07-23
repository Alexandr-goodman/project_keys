unit udm2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, DBGrids, DBCtrls,
  StdCtrls, Unit2;

type

  { TFMain }

  TFMain = class(TForm)
    // === КОМПОНЕНТЫ ===
    DataSo: TDataSource;      // Связующее звено между запросом и визуальными компонентами
    DBGr: TDBGrid;              // Таблица для отображения данных
    Button_Load: TButton;         // Кнопка загрузки данных из БД
    Button_SaveAll: TButton;         // Кнопка сохранения всех изменений
    Button_Add: TButton;              // Кнопка добавления записи (через диалог)
    Button_Delete: TButton;             // Кнопка удаления выбранной записи
    Button_Edit: TButton;                // Кнопка редактирования выбранной записи

    // === СОБЫТИЯ ===
    procedure FormCreate(Sender: TObject);
    procedure Button_LoadClick(Sender: TObject);
    procedure Button_SaveAllClick(Sender: TObject);
    procedure Button_AddClick(Sender: TObject);
    procedure Button_DeleteClick(Sender: TObject);
    procedure Button_EditClick(Sender: TObject);
    procedure DBGrClick(Sender: TObject);

  private
    procedure SetupGrid;               // Настройка внешнего вида таблицы (колонки)
    procedure RefreshData;                // Обновление данных в таблице
    function GetSelectedID: Integer;        // Получение ID выделенной записи
  public
    { public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.lfm}

// НАСТРОЙКА КОЛОНОК
// Создаем колонки в DBGrid вручную, чтобы задать ширину и заголовки
procedure TFMain.SetupGrid;
begin
  DBGr.Columns.Clear;   // Очищаем автоматические колонки
   // Колонка ID (первичный ключ)
  with DBGr.Columns.Add do
  begin
    FieldName := 'EmployeeID';
    Title.Caption := 'ID';
    Width := 50;
    ReadOnly := True;  // Запрещаем редактирование ID
    Visible := True;
  end;
  // Колонка Имя
  with DBGr.Columns.Add do
  begin
    FieldName := 'FirstName';
    Title.Caption := 'Имя';
    Width := 150;
  end;

  // Колонка Фамилия
  with DBGr.Columns.Add do
  begin
    FieldName := 'LastName';
    Title.Caption := 'Фамилия';
    Width := 150;
  end;

  // Колонка Должность
  with DBGr.Columns.Add do
  begin
    FieldName := 'Position';
    Title.Caption := 'Должность';
    Width := 150;
  end;

  // Колонка Отделение
  with DBGr.Columns.Add do
  begin
    FieldName := 'Department';
    Title.Caption := 'Отделение';
    Width := 150;
  end;

  // Колонка Дата приема
  with DBGr.Columns.Add do
  begin
    FieldName := 'HireDate';
    Title.Caption := 'Дата приема';
    Width := 120;
  end;
end;

// ОБНОВЛЕНИЕ ДАННЫХ
//Перезагружает данные из БД и обновляет таблицу
procedure TFMain.RefreshData;
begin
  // Проверка подключения к БД
  if not dm.ODBCCon.Connected then Exit;

  try
     // Временно отключаем DataSource, чтобы избежать ошибок при обновлении
    DataSo.DataSet := nil;
     // Закрываем и заново открываем запрос с актуальными данными
    dm.SQLQue.Close;
    dm.SQLQue.SQL.Text := 'SELECT EmployeeID, FirstName, LastName, Position, Department, HireDate FROM Employees ORDER BY EmployeeID';
    dm.SQLQue.Open;
     // Подключаем DataSource обратно
    DataSo.DataSet := dm.SQLQue;

    // Перемещаем курсор на последнюю запись (удобно при добавлении)
    if dm.SQLQue.RecordCount > 0 then
      dm.SQLQue.Last;
     // Принудительно обновляем отображение таблицы
    DBGr.Refresh;
     // Показываем количество записей
    ShowMessage('✅ Данные обновлены! Записей: ' + IntToStr(dm.SQLQue.RecordCount));
  except
    on E: Exception do
      ShowMessage('❌ Ошибка обновления: ' + E.Message);
  end;
end;

// ПОЛУЧИТЬ ID ВЫДЕЛЕННОЙ ЗАПИСИ
// Возвращает EmployeeID текущей выделенной строки
function TFMain.GetSelectedID: Integer;
begin
  Result := 0;

  //Проверка: загружены ли данные
  if not dm.SQLQue.Active then
  begin
    ShowMessage('❌ Данные не загружены!');
    Exit;
  end;

  // Проверка: есть ли записи в таблице
  if dm.SQLQue.RecordCount = 0 then
  begin
    ShowMessage('В таблице нет записей!');
    Exit;
  end;

   // Проверка: находимся ли на корректной записи
  if dm.SQLQue.EOF or dm.SQLQue.BOF then
  begin
    // Если курсор в начале или конце - переходим на первую запись
    if dm.SQLQue.RecordCount > 0 then
      dm.SQLQue.First
    else
    begin
      ShowMessage('Нет записей для выбора!');
      Exit;
    end;
  end;

  // Получаем ID
  Result := dm.SQLQue.FieldByName('EmployeeID').AsInteger;

  if Result = 0 then
    ShowMessage('Ошибка получения ID!');
end;

//СОБЫТИЕ: СОЗДАНИЕ ФОРМЫ
procedure TFMain.FormCreate(Sender: TObject);
begin
  // Создаем модуль данных, если он еще не создан
  if not Assigned(dm) then
    dm := Tdm.Create(Application);
   // Настраиваем внешний вид таблицы
  SetupGrid;
   // Связываем компоненты
  DataSo.DataSet := dm.SQLQue;
  DBGr.DataSource := DataSo;
  //DBNav.DataSource := DataSo;
  // Назначаем обработчик клика по таблице
  DBGr.OnClick := @DBGrClick;
  // Если подключение к БД активно - загружаем данные
  if dm.ODBCCon.Connected then
  begin
    ShowMessage('Подключение к SQL Server активно!');
    Button_Load.Click;
  end
  else
    ShowMessage(' Нет подключения к базе данных');
end;

// СОБЫТИЕ: КЛИК ПО ТАБЛИЦЕ
// Обновляет выделение при клике на таблицу
procedure TFMain.DBGrClick(Sender: TObject);
begin
  // При клике на таблицу обновляем выделение
  if dm.SQLQue.Active and (dm.SQLQue.RecordCount > 0) then
  begin
    if dm.SQLQue.EOF then
      dm.SQLQue.Last;
    DBGr.Refresh;
  end;
end;

// КНОПКА: ЗАГРУЗИТЬ ДАННЫЕ
procedure TFMain.Button_LoadClick(Sender: TObject);
begin
  RefreshData;
end;

// КНОПКА: СОХРАНИТЬ ВСЕ
// Сохраняет изменения текущей записи в БД
procedure TFMain.Button_SaveAllClick(Sender: TObject);
var
  ID: Integer;
  FirstName, LastName, EmpPos, Department, HireDate: string;
begin
  if not dm.SQLQue.Active then   // Проверка: есть ли данные
  begin
    ShowMessage('Нет данных для сохранения!');
    Exit;
  end;

  ID := GetSelectedID;   // Получаем ID выделенной записи
  if ID = 0 then
  begin
    ShowMessage('Выберите запись для сохранения!');
    Exit;
  end;
    // Получаем текущие значения полей
  FirstName := dm.SQLQue.FieldByName('FirstName').AsString;
  LastName := dm.SQLQue.FieldByName('LastName').AsString;
  EmpPos := dm.SQLQue.FieldByName('Position').AsString;
  Department := dm.SQLQue.FieldByName('Department').AsString;
  HireDate := dm.SQLQue.FieldByName('HireDate').AsString;
   // Обновляем запись в БД
  if dm.UpdateRecord(ID, FirstName, LastName, EmpPos, Department, HireDate) then
    RefreshData;
end;

// КНОПКА: ДОБАВИТЬ
// Открывает диалоги для ввода данных и добавляет новую запись
procedure TFMain.Button_AddClick(Sender: TObject);
var
  FirstName, LastName, EmpPos, Department, HireDate: string;  // Запрашиваем данные через диалоговые окна
begin
  FirstName := InputBox('Добавление', 'Введите имя:', '');
  if FirstName = '' then Exit;

  LastName := InputBox('Добавление', 'Введите фамилию:', '');
  EmpPos := InputBox('Добавление', 'Введите должность:', '');
  Department := InputBox('Добавление', 'Введите отделение:', '');
  HireDate := InputBox('Добавление', 'Введите дату (ГГГГ-ММ-ДД):', '');
   // Добавляем запись в БД
  if dm.AddRecord(FirstName, LastName, EmpPos, Department, HireDate) then
  begin
    RefreshData; // Обновляем таблицу после добавления
    //ShowMessage(' Данные обновлены!');
  end;
end;

// КНОПКА: УДАЛИТЬ
// Удаляет выбранную запись после подтверждения
procedure TFMain.Button_DeleteClick(Sender: TObject);
var
  ID: Integer;
begin   // Получаем ID выделенной записи
  ID := GetSelectedID;
  if ID = 0 then
  begin
    ShowMessage('Выберите запись для удаления!');
    Exit;
  end;
      // Запрашиваем подтверждение
  if MessageDlg('Удалить запись с ID=' + IntToStr(ID) + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if dm.DeleteRecord(ID) then
      RefreshData;
  end;
end;

// КНОПКА: РЕДАКТИРОВАТЬ
// Открывает диалоги с текущими значениями для редактирования
procedure TFMain.Button_EditClick(Sender: TObject);
var
  ID: Integer;
  FirstName, LastName, EmpPos, Department, HireDate: string;
begin   // Получаем ID выделенной записи
  ID := GetSelectedID;
  if ID = 0 then
  begin
    ShowMessage(' Выберите запись для редактирования!');
    Exit;
  end;
     // Получаем текущие значения из таблицы
  FirstName := dm.SQLQue.FieldByName('FirstName').AsString;
  LastName := dm.SQLQue.FieldByName('LastName').AsString;
  EmpPos := dm.SQLQue.FieldByName('Position').AsString;
  Department := dm.SQLQue.FieldByName('Department').AsString;
  HireDate := dm.SQLQue.FieldByName('HireDate').AsString;
        // Показываем диалоги с текущими значениями для изменения
  FirstName := InputBox('Редактирование', 'Имя:', FirstName);
  LastName := InputBox('Редактирование', 'Фамилия:', LastName);
  EmpPos := InputBox('Редактирование', 'Должность:', EmpPos);
  Department := InputBox('Редактирование', 'Отделение:', Department);
  HireDate := InputBox('Редактирование', 'Дата (ГГГГ-ММ-ДД):', HireDate);
      // Сохраняем измененную запись
  if dm.UpdateRecord(ID, FirstName, LastName, EmpPos, Department, HireDate) then
    RefreshData; // Обновляем таблицу после редактирования
end;

end.
