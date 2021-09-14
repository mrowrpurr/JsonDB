scriptName JsonDB hidden
{~ JSON Database for Skyrim Mods ~

To get started, checkout the official user documentation at:
https://github.com/mrowrpurr/JsonDB}

; Get the currently installed version of JsonDB
float function JsonDBVersion() global
    return 1.0
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns the file path used for the provided record relative to Data\JsonDB\
;
; Note: this returns a path *regardless* of whether the record exists or not.
string function FilepathForRecord(string databasePath, string primaryKey) global
    return databasePath + "\\" + primaryKey + ".json"
endFunction

; Convenience function for getting a "namespaced" name for the provided database.
;
; Note: This is the same as `"{namespace}\\{database}"` which puts the database
;       into the specified subdirectory (useful for isolating databases)
;
; You should consider *ALWAYS* using a namespace which is the same as your mod name.
string function NamespacedDB(string namespace, string database) global
    return namespace + "\\" + database
endFunction

; Get a list of all reserved field names (field names which you cannot use).
; Currently returns just "_id" and "_db" but provided for programmatic usage.
; You can also check if a particular field name is reserved via `IsReservedFieldName()`
string[] function GetReservedFieldNames() global
    string[] keywords = new string[2]
    keywords[0] = "_id"
    keywords[1] = "_db"
    return keywords
endFunction

; Check whether the following field name is reserved (field name which you cannot use).
bool function IsReservedFieldName(string field) global
    string[] reservedFieldNames = GetReservedFieldNames()
    return reservedFieldNames.Find(field) > -1
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Record Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns a new primary key.
; The key is a randomly generated string.
; It simply combines the current date/time with a few randomly generated integers.
; It is the equivalent of `"record_{real time}_{rand int}_{rand int}"` and performs 3 Utility function invocations.
string function GeneratePrimaryKey() global
    return "record_" + Utility.GetCurrentRealTime() + "_" + Utility.RandomInt(1, 100000) + "_" + Utility.RandomInt(1, 100000)
endFunction

; Returns a reference to a new record which can be saved via `SaveRecord(recordId)`
;
; To populate this record with fields, use the provided `SetRecord*()` functions:
; - `JsonDB.SetRecordString(recordId, "field name", "text")`
; - `JsonDB.SetRecordBool(recordId, "field name", true)`
; - `JsonDB.SetRecordInt(recordId, "field name", 42)`
; - `JsonDB.SetRecordFloat(recordId, "field name", 4.2)`
; - `JsonDB.SetRecordForm(recordId, "field name", Game.GetPlayer())`
;
; Note: every record has a `_id` and `_db` fields which is a reserved names (contains the primaryKey and database root of the record)
int function NewRecord(string database, string primaryKey = "") global
    int record = JMap.object()
    if ! primaryKey
        primaryKey = GeneratePrimaryKey()
    endIf
    JMap.setStr(record, "_id", primaryKey)
    JMap.setStr(record, "_db", database)
    return record
endFunction

; Save record to the file system. If the record already exists, it will be overwritten.
;
; If no database and/or primaryKey are provided, they will be read from the record which should've been created via `NewRecord()`
; but they can be overridden. Overriding either value will update the respective `_id` and `_db` meta fields on the record.
bool function SaveRecord(int record, string database = "", string primaryKey = "") global
    if database
        JMap.setStr(record, "_db", database)
    else
        database = JMap.getStr(record, "_db")
    endIf
    if primaryKey
        JMap.setStr(record, "_id", primaryKey)
    else
        primaryKey = JMap.getStr(record, "_id")
    endIf
    if primaryKey
        string path = FilepathForRecord(database, primaryKey)
        JValue.writeToFile(record, path)
        return MiscUtil.FileExists(path)
    else
        return false        
    endIf
endFunction

; string function InspectRecord(string recordId)

; int function LoadRecord(string database, string primaryKey)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Record Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns the primary key of the specified record.
string function GetRecordPrimaryKey(int record) global
    return JMap.getStr(record, "_id")
endFunction

; Returns the database path of the specified record.
string function GetRecordDatabase(int record) global
    return JMap.getStr(record, "_db")
endFunction

; Check whether a field has been defined on the specified record.
bool function HasField(int record, string field) global
    return JMap.hasKey(record, field)
endFunction

; Get a list of all fields on the specified record.
string[] function GetFieldNames(int record) global
    bool hasId = JMap.hasKey(record, "_id")
    bool hasDb = JMap.hasKey(record, "_db")
    string[] keys = JMap.allKeysPArray(record)
    int size = keys.Length
    if hasId && hasDb
        size = keys.Length - 2
    elseIf hasId || hasId
        size = keys.Length - 1
    endIf
    string[] fieldNames = Utility.CreateStringArray(size)
    int fieldNameIndex = 0
    int keyIndex = 0
    while keyIndex < keys.Length
        string thisKey = keys[keyIndex]
        if thisKey != "_id" && thisKey != "_db"
            fieldNames[fieldNameIndex] = thisKey
            fieldNameIndex += 1
        endIf
        keyIndex += 1
    endWhile
    return fieldNames
endFunction

; Get a string text field on the specified record.
string function GetRecordString(int record, string field, string default = "") global
    return JMap.getStr(record, field, default)
endFunction

; Get a boolean field on the specified record.
bool function GetRecordBool(int record, string field, bool default = false) global
    if JMap.hasKey(record, field)
        if JMap.getInt(record, field, default = 0) == 1
            return true
        else
            return false
        endIf
    else
        return default
    endIf
endFunction

; Get a numeric integer field on the specified record.
int function GetRecordInt(int record, string field, int default = 0) global
    return JMap.getInt(record, field, default)
endFunction

; Get a numeric float field on the specified record.
float function GetRecordFloat(int record, string field, float default = 0.0) global
    return JMap.getFlt(record, field, default)
endFunction

; Get a Form field on the specified record.
Form function GetRecordForm(int record, string field, Form default = None) global
    return JMap.getForm(record, field, default)
endFunction

; Returns a string representation of this record and its data.
; Intended to be printed to the Papyrus Log, Debug.MessageBox, or console (etc).
string function InspectRecord(int record) global
    string text = ""
    text += "[_id] = " + JMap.getStr(record, "_id") + "\n"
    text += "[_db] = " + JMap.getStr(record, "_db") + "\n"
    string[] fieldNames = GetFieldNames(record)
    int i = 0
    while i < fieldNames.Length
        string fieldName = fieldNames[i]
        ; text += "[" + fieldName + "] = " + JMap.
        int valueType = JMap.valueType(record, fieldName)
        i += 1
    endWhile
    return text
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Record Setters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set a string text field on the specified record.
bool function SetRecordString(int record, string field, string value) global
    if IsReservedFieldName(field)
        return false
    else
        JMap.setStr(record, field, value)
        return true
    endIf
endFunction

; Set a boolean field on the specified record.
bool function SetRecordBool(int record, string field, bool value) global
    if IsReservedFieldName(field)
        return false
    else
        if value
            JMap.setInt(record, field, 1)
        else
            JMap.setInt(record, field, 0)
        endIf
        return true
    endIf
endFunction

; Set a numeric integer field on the specified record.
bool function SetRecordInt(int record, string field, int value) global
    if IsReservedFieldName(field)
        return false
    else
        JMap.setInt(record, field, value)
        return true
    endIf
endFunction

; Set a numeric float field on the specified record.
bool function SetRecordFloat(int record, string field, float value) global
    if IsReservedFieldName(field)
        return false
    else
        JMap.setFlt(record, field, value)
        return true
    endIf
endFunction

; Set a Form field on the specified record.
bool function SetRecordForm(int record, string field, Form value) global
    if IsReservedFieldName(field)
        return false
    else
        JMap.setForm(record, field, value)
        return true
    endIf
endFunction

; Remove a field from the specified record.
bool function RemoveRecordField(int record, string field) global
    if IsReservedFieldName(field)
        return false
    else
        JMap.removeKey(record, field)
        return true
    endIf
endFunction
