scriptName JsonDB_RecordTest extends JsonDB_Test
{Tests for basic record functionality, e.g. getting/setting fields and primary key functionality}

import ArrayAssertions

function Tests()
    Test("Generated primary key").Fn(GeneratedPrimaryKey_Test())
    Test("Get file path to record").Fn(GetFilePathToRecord_Test())
    Test("Record getters").Fn(RecordGetters_Test())
    Test("Record setters").Fn(RecordSetters_Test())
    Test("Can get all reserved field names").Fn(GetReservedFieldNames_Test())
    Test("Can check if something is a reserved field name").Fn(CheckIfReservedFieldName_Test())
    Test("Cannot set the _id or _db fields of a record (reserved fields)").Fn(CannotSetReservedIdOrDatabaseFields_Test())
    Test("Can get primary key and database from a record").Fn(GetPrimaryKeyAndDatabaseFromRecord_Test())
    Test("Check if record has field defined").Fn(HasField_Test())
    Test("Get field names from record").Fn(GetRecordFieldNames_Test())
    Test("Remove field from record").Fn(RemoveFieldFromRecord_Test())
    ; Test("Inspecting records").Fn(InspectRecord_Test()) ; Abandoned for now.
    Test("Check if record exists by primary key").Fn(CheckIfRecordExistsByPrimaryKey_Test())
    Test("Get record by primary key").Fn(GetRecordByPrimaryKey_Test())
endFunction

function GeneratedPrimaryKey_Test()
    string key1 = JsonDB.GeneratePrimaryKey()
    string key2 = JsonDB.GeneratePrimaryKey()
    string key3 = JsonDB.GeneratePrimaryKey()

    ExpectString(key1).Not().To(BeEmpty())
    ExpectString(key2).Not().To(BeEmpty())
    ExpectString(key3).Not().To(BeEmpty())

    ExpectString(key1).Not().To(EqualString(key2))
    ExpectString(key1).Not().To(EqualString(key3))

    ExpectString(key2).Not().To(EqualString(key1))
    ExpectString(key2).Not().To(EqualString(key3))

    ExpectString(key3).Not().To(EqualString(key1))
    ExpectString(key3).Not().To(EqualString(key2))
endFunction

function GetFilePathToRecord_Test()
    string path = JsonDB.FilepathForRecord(TestDb("MyDb"), "Record1")
    ExpectString(path).To(EqualString(TestNamespace + "\\MyDb\\Record1.json"))

    path = JsonDB.FilepathForRecord(TestDb("DiffDb\\SubDb"), "Record2")
    ExpectString(path).To(EqualString(TestNamespace + "\\DiffDb\\SubDb\\Record2.json"))
endFunction

function RecordGetters_Test()
    Form gold = Game.GetForm(0xf)
    Form lockpick = Game.GetForm(0xa)

    int record = JsonDB.NewRecord(TestDb("MyDb"))

    ExpectBool(JsonDB.GetRecordBool(record, "MyBool")).To(EqualBool(false))
    ExpectBool(JsonDB.GetRecordBool(record, "MyBool", default = true)).To(EqualBool(true))
    ExpectInt(JsonDB.GetRecordInt(record, "MyInt")).To(EqualInt(0))
    ExpectInt(JsonDB.GetRecordInt(record, "MyInt", default = 123)).To(EqualInt(123))
    ExpectFloat(JsonDB.GetRecordFloat(record, "MyFloat")).To(EqualFloat(0.0))
    ExpectFloat(JsonDB.GetRecordFloat(record, "MyFloat", default = 12.34)).To(EqualFloat(12.34))
    ExpectString(JsonDB.GetRecordString(record, "MyString")).To(EqualString(""))
    ExpectString(JsonDB.GetRecordString(record, "MyString", default = "Hi")).To(EqualString("Hi"))
    ExpectForm(JsonDB.GetRecordForm(record, "MyForm")).To(EqualForm(None))
    ExpectForm(JsonDB.GetRecordForm(record, "MyForm", default = lockpick)).To(EqualForm(lockpick))
    ExpectInt(JsonDB.GetRecordObject(record, "MyObj")).To(EqualInt(0))

    JMap.setInt(record, "MyBool", 1)
    JMap.setInt(record, "MyInt", 42)
    JMap.setFlt(record, "MyFloat", 4.2)
    JMap.setStr(record, "MyString", "Hello, world")
    JMap.setForm(record, "MyForm", gold)
    int array = JArray.object()
    JMap.setObj(record, "MyObj", array)

    ExpectBool(JsonDB.GetRecordBool(record, "MyBool")).To(EqualBool(true))
    ExpectInt(JsonDB.GetRecordInt(record, "MyInt")).To(EqualInt(42))
    ExpectFloat(JsonDB.GetRecordFloat(record, "MyFloat")).To(EqualFloat(4.2))
    ExpectString(JsonDB.GetRecordString(record, "MyString")).To(EqualString("Hello, world"))
    ExpectForm(JsonDB.GetRecordForm(record, "MyForm")).To(EqualForm(gold))
    ExpectInt(JsonDB.GetRecordObject(record, "MyObj")).To(EqualInt(array))
endFunction

function RecordSetters_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"))
    ExpectBool(JMap.getInt(record, "boolField1")).To(BeFalse())
    ExpectInt(JMap.getInt(record, "intField1")).To(EqualInt(0))
    ExpectFloat(JMap.getFlt(record, "floatField1")).To(EqualFloat(0.0))
    ExpectString(JMap.getStr(record, "stringField1")).To(BeEmpty())
    ExpectString(JMap.getStr(record, "stringField2")).To(BeEmpty())
    ExpectInt(JMap.getObj(record, "objectField1")).To(EqualInt(0))

    JsonDB.SetRecordBool(record, "boolField1", true)
    JsonDB.SetRecordInt(record, "intField1", 42)
    JsonDB.SetRecordFloat(record, "floatField1", 4.2)
    JsonDB.SetRecordString(record, "stringField1", "Hello")
    JsonDB.SetRecordString(record, "stringField2", "World")
    int array = JArray.object()
    JsonDB.SetRecordObject(record, "objectField1", array)

    ExpectBool(JMap.getInt(record, "boolField1")).To(BeTrue())
    ExpectInt(JMap.getInt(record, "intField1")).To(EqualInt(42))
    ExpectFloat(JMap.getFlt(record, "floatField1")).To(EqualFloat(4.2))
    ExpectString(JMap.getStr(record, "stringField1")).To(EqualString("Hello"))
    ExpectString(JMap.getStr(record, "stringField2")).To(EqualString("World"))
    ExpectInt(JMap.getObj(record, "objectField1")).To(EqualInt(array))
endFunction

function GetReservedFieldNames_Test()
    string[] reservedFieldNames = JsonDB.GetReservedFieldNames()
    ExpectStringArray(reservedFieldNames).To(HaveLength(3))
    ExpectStringArray(reservedFieldNames).To(ContainString("_id"))
    ExpectStringArray(reservedFieldNames).To(ContainString("_db"))
    ExpectStringArray(reservedFieldNames).To(ContainString("_deleted"))
endFunction

function CheckIfReservedFieldName_Test()
    ExpectBool(JsonDb.IsReservedFieldName("_id")).To(BeTrue())
    ExpectBool(JsonDb.IsReservedFieldName("_db")).To(BeTrue())
    ExpectBool(JsonDb.IsReservedFieldName("_deleted")).To(BeTrue())
    ExpectBool(JsonDb.IsReservedFieldName("id")).To(BeFalse())
    ExpectBool(JsonDb.IsReservedFieldName("db")).To(BeFalse())
    ExpectBool(JsonDb.IsReservedFieldName("deleted")).To(BeFalse())
    ExpectBool(JsonDb.IsReservedFieldName("foo")).To(BeFalse())
    ExpectBool(JsonDb.IsReservedFieldName("bar")).To(BeFalse())
endFunction

function CannotSetReservedIdOrDatabaseFields_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"))
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(BeEmpty())

    bool workedOk = JsonDB.SetRecordString(record, "id", "Hello") ; "id" without an _ is perfectly fine
    ExpectBool(workedOk).To(BeTrue())
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(EqualStringArray1("id"))

    workedOk = JsonDB.SetRecordInt(record, "_id", 123)
    ExpectBool(workedOk).To(BeFalse())
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(EqualStringArray1("id"))

    workedOk = JsonDB.SetRecordString(record, "_db", "foo")
    ExpectBool(workedOk).To(BeFalse())
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(EqualStringArray1("id"))
endFunction

function GetPrimaryKeyAndDatabaseFromRecord_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"), "Record1")
    ExpectString(JsonDB.GetRecordPrimaryKey(record)).To(EqualString("Record1"))
    ExpectString(JsonDB.GetRecordDatabase(record)).To(EqualString(TestDb("MyDb")))
endFunction

function HasField_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"))

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeFalse())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeFalse())

    JsonDB.SetRecordInt(record, "Bar", 42)

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeFalse())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeTrue())

    JsonDB.SetRecordString(record, "Foo", "Fourty Two")

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeTrue())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeTrue())
endFunction

function GetRecordFieldNames_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"))
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(BeEmpty())

    JsonDB.SetRecordString(record, "Hello", "Hello, world")
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(HaveLength(1))
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(EqualStringArray1("Hello"))

    JsonDB.SetRecordFloat(record, "Foo", 4.2)
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(HaveLength(2))
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(ContainString("Hello"))
    ExpectStringArray(JsonDB.GetFieldNames(record)).To(ContainString("Foo"))
endFunction

function RemoveFieldFromRecord_Test()
    int record = JsonDB.NewRecord(TestDb("MyDb"))
    JsonDB.SetRecordString(record, "Hello", "Hello, world")
    JsonDB.SetRecordString(record, "Goodnight", "Goodnight, moon")

    string[] fieldNames = JsonDB.GetFieldNames(record)
    ExpectStringArray(fieldNames).To(HaveLength(2))
    ExpectStringArray(fieldNames).To(ContainString("Hello"))
    ExpectStringArray(fieldNames).To(ContainString("Goodnight"))

    JsonDB.RemoveRecordField(record, "Hello")

    fieldNames = JsonDB.GetFieldNames(record)
    ExpectStringArray(fieldNames).To(HaveLength(1))
    ExpectStringArray(fieldNames).Not().To(ContainString("Hello"))
    ExpectStringArray(fieldNames).To(ContainString("Goodnight"))
endFunction

; Abandoned...
; function InspectRecord_Test()
;     int record = JsonDB.NewRecord(TestDb("MyDb"), "Record1")
;     JsonDB.SetRecordBool(record, "BoolField", true)
;     JsonDB.SetRecordInt(record, "IntField", 42)
;     JsonDB.SetRecordFloat(record, "FloatField", 4.2)
;     JsonDB.SetRecordForm(record, "FormField", Game.GetForm(0xa))
;     int array = JArray.object()
;     JArray.addInt(array, 42)
;     JsonDB.SetRecordObject(record, "MyArray", array)
;     int map = JMap.object()
;     JMap.setInt(map, "Hello", 42)
;     JMap.setInt(map, "World", 123)
;     JsonDB.SetRecordObject(record, "MyStringMap", map)
;     int intMap = JIntMap.object()
;     JIntMap.setInt(intMap, 1, 42)
;     JIntMap.setInt(intMap, 2, 123)
;     JIntMap.setInt(intMap, 3, 456)
;     JsonDB.SetRecordObject(record, "MyIntMap", intMap)
;     ; int formMap = JFormMap.object()
;     ; JFormMap.setInt(formMap, Game.GetPlayer(), 42)
;     ; JFormMap.setInt(formMap, Game.GetForm(0xa), 123)
;     ; JFormMap.setInt(formMap, Game.GetForm(0xf), 456)
;     ; JFormMap.setInt(formMap, Game.GetForm(0x1397e), 789)
;     ; JsonDB.SetRecordObject(record, "MyFormMap", formMap)

;     string inspected = JsonDB.InspectRecord(record)

;     Debug.MessageBox(inspected)
; endFunction

function CheckIfRecordExistsByPrimaryKey_Test()
    string db = TestDb("MyDb")
    int record1 = JsonDB.NewRecord(db, "Record1")
    int record2 = JsonDB.NewRecord(db, "Record2")

    ExpectBool(JsonDB.RecordExists(db, "Record1")).To(BeFalse())
    ExpectBool(JsonDB.RecordExists(db, "Record2")).To(BeFalse())

    JsonDB.SaveRecord(record1)

    ExpectBool(JsonDB.RecordExists(db, "Record1")).To(BeTrue())
    ExpectBool(JsonDB.RecordExists(db, "Record2")).To(BeFalse())

    JsonDB.SaveRecord(record2)

    ExpectBool(JsonDB.RecordExists(db, "Record1")).To(BeTrue())
    ExpectBool(JsonDB.RecordExists(db, "Record2")).To(BeTrue())
endFunction

function GetRecordByPrimaryKey_Test()
    string db1 = TestDb("MyDb1")
    int db1_record1 = JsonDB.NewRecord(db1, "Record1")
    JsonDB.SetRecordString(db1_record1, "Text", "This is record 1 in database #1")
    string db2 = TestDb("MyDb2")
    int db2_record1 = JsonDB.NewRecord(db2, "Record1")
    JsonDB.SetRecordString(db2_record1, "Text", "This is record 1 in database #2")

    int foundRecord = JsonDB.GetRecord(db1, "Record1")
    ExpectInt(foundRecord).To(EqualInt(-1))
    foundRecord = JsonDB.GetRecord(db2, "Record1")
    ExpectInt(foundRecord).To(EqualInt(-1))

    JsonDB.SaveRecord(db1_record1)

    foundRecord = JsonDB.GetRecord(db1, "Record1")
    ExpectInt(foundRecord).Not().To(EqualInt(-1))
    ExpectString(JsonDB.GetRecordString(foundRecord, "Text")).To(EqualString("This is record 1 in database #1"))

    foundRecord = JsonDB.GetRecord(db2, "Record1")
    ExpectInt(foundRecord).To(EqualInt(-1))

    JsonDB.SaveRecord(db2_record1)

    foundRecord = JsonDB.GetRecord(db1, "Record1")
    ExpectInt(foundRecord).Not().To(EqualInt(-1))
    ExpectString(JsonDB.GetRecordString(foundRecord, "Text")).To(EqualString("This is record 1 in database #1"))

    foundRecord = JsonDB.GetRecord(db2, "Record1")
    ExpectInt(foundRecord).Not().To(EqualInt(-1))
    ExpectString(JsonDB.GetRecordString(foundRecord, "Text")).To(EqualString("This is record 1 in database #2"))
endFunction
