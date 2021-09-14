scriptName JsonDB_CreateTest extends JsonDB_Test
{Tests for creating records.

Ensures that the correct files are saved to disk.}

function Tests()
    ; Move these to a diff test, prob. They're not creating records:
    Test("Get namespaced database name").Fn(GetNamespacedDatabaseName_Test())
    Test("Get file path to record").Fn(GetFilePathToRecord_Test())
    Test("Record setters").Fn(RecordSetters_Test())
    Test("Record getters").Fn(RecordGetters_Test())
    Test("Check if record has field defined").Fn(HasField_Test())
    ;
    Test("Generated primary key").Fn(GeneratedPrimaryKey_Test())
    ;
    Test("Create record with provided primary primary key") ; .Fn(CreateRecordWithPrimaryKey_Test())
    Test("Create record with provided generated primary key")
endFunction

;;;;;;;;;;;;; Misc ;;;;;;;;;;;;;;

function GetNamespacedDatabaseName_Test()
    ExpectString(JsonDB.NamespacedDB("A", "B")).To(EqualString("A\\B"))
    ExpectString(JsonDB.NamespacedDB("A\\B", "C")).To(EqualString("A\\B\\C"))
endFunction

function GetFilePathToRecord_Test()
    string path = JsonDB.FilepathForRecord(TestDb("MyDb"), "Record1")
    ExpectString(path).To(EqualString("Data\\JsonDB\\" + TestNamespace + "\\MyDb\\Record1.json"))

    path = JsonDB.FilepathForRecord(TestDb("DiffDb\\SubDb"), "Record2")
    ExpectString(path).To(EqualString("Data\\JsonDB\\" + TestNamespace + "\\DiffDb\\SubDb\\Record2.json"))
endFunction

function RecordSetters_Test()
    int record = JsonDB.NewRecord("myDB")
    ExpectBool(JMap.getInt(record, "boolField1")).To(BeFalse())
    ExpectInt(JMap.getInt(record, "intField1")).To(EqualInt(0))
    ExpectFloat(JMap.getFlt(record, "floatField1")).To(EqualFloat(0.0))
    ExpectString(JMap.getStr(record, "stringField1")).To(BeEmpty())
    ExpectString(JMap.getStr(record, "stringField2")).To(BeEmpty())

    JsonDB.SetRecordBool(record, "boolField1", true)
    JsonDB.SetRecordInt(record, "intField1", 42)
    JsonDB.SetRecordFloat(record, "floatField1", 4.2)
    JsonDB.SetRecordString(record, "stringField1", "Hello")
    JsonDB.SetRecordString(record, "stringField2", "World")

    ExpectBool(JMap.getInt(record, "boolField1")).To(BeTrue())
    ExpectInt(JMap.getInt(record, "intField1")).To(EqualInt(42))
    ExpectFloat(JMap.getFlt(record, "floatField1")).To(EqualFloat(4.2))
    ExpectString(JMap.getStr(record, "stringField1")).To(EqualString("Hello"))
    ExpectString(JMap.getStr(record, "stringField2")).To(EqualString("World"))
endFunction

function RecordGetters_Test()
    Form gold = Game.GetForm(0xf)
    Form lockpick = Game.GetForm(0xa)

    int record = JsonDB.NewRecord("myDB")

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

    JMap.setInt(record, "MyBool", 1)
    JMap.setInt(record, "MyInt", 42)
    JMap.setFlt(record, "MyFloat", 4.2)
    JMap.setStr(record, "MyString", "Hello, world")
    JMap.setForm(record, "MyForm", gold)

    ExpectBool(JsonDB.GetRecordBool(record, "MyBool")).To(EqualBool(true))
    ExpectInt(JsonDB.GetRecordInt(record, "MyInt")).To(EqualInt(42))
    ExpectFloat(JsonDB.GetRecordFloat(record, "MyFloat")).To(EqualFloat(4.2))
    ExpectString(JsonDB.GetRecordString(record, "MyString")).To(EqualString("Hello, world"))
    ExpectForm(JsonDB.GetRecordForm(record, "MyForm")).To(EqualForm(gold))
endFunction

function HasField_Test()
    int record = JsonDB.NewRecord("myDB")

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeFalse())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeFalse())

    JsonDB.SetRecordInt(record, "Bar", 42)

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeFalse())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeTrue())

    JsonDB.SetRecordString(record, "Foo", "Fourty Two")

    ExpectBool(JsonDB.HasField(record, "Foo")).To(BeTrue())
    ExpectBool(JsonDB.HasField(record, "Bar")).To(BeTrue())
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

;;;;;;;;;; Creating Records ;;;;;;;;;;

; function CreateRecordWithPrimaryKey_Test()
;     string path = JsonDB.FilepathForRecord(TestDb("MyDb"), "Record1")
;     ExpectBool(MiscUtil.FileExists(path)).To(BeFalse())
    
;     int record = JsonDB.NewRecord()

;     ExpectBool(MiscUtil.FileExists(path)).To(BeTrue())
; endFunction
