scriptName JsonDB_CreateTest extends JsonDB_Test
{Tests for creating records.

Ensures that the correct files are saved to disk.}

function Tests()
    Test("Create record with provided primary primary key").Fn(CreateRecordWithPrimaryKey_Test())
    Test("Create record with provided generated primary key")
endFunction

function CreateRecordWithPrimaryKey_Test()
    string db = TestDb("MyDb")
    string path = JsonDB.FilepathForRecord(db, "Record1")

    ExpectBool(MiscUtil.FileExists(path)).To(BeFalse())
    
    int record = JsonDB.NewRecord(db, "Record1")
    ExpectBool(MiscUtil.FileExists(path)).To(BeFalse()) ; 'NewRecord' doesn't actually save

    JsonDB.SaveRecord(record) ; 'SaveRecord' saves :)
    ExpectBool(MiscUtil.FileExists(path)).To(BeTrue())

    int recordFromDisk = JValue.readFromFile(path)
    ExpectString(JMap.getStr(recordFromDisk, "_id")).To(EqualString("Record1"))
endFunction

; function CreateRecordWithGeneratedPrimaryKey_Test()
;     string db = TestDb("MyDb")
;     string path = JsonDB.FilepathForRecord(db, "Record1")

;     ExpectBool(MiscUtil.FileExists(path)).To(BeFalse())
    
;     int record = JsonDB.NewRecord(db, "Record1")
;     ExpectBool(MiscUtil.FileExists(path)).To(BeFalse()) ; 'NewRecord' doesn't actually save

;     JsonDB.SaveRecord(record) ; 'SaveRecord' saves :)
;     ExpectBool(MiscUtil.FileExists(path)).To(BeTrue())

;     int recordFromDisk = JValue.readFromFile(path)
;     ExpectString(JMap.getStr(recordFromDisk, "_id")).To(EqualString("Record1"))
; endFunction

; TODO test SaveRecord with database and primaryKey overrides
