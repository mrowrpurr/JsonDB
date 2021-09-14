scriptName JsonDB hidden
{~ JSON Database for Skyrim Mods ~

To get started, checkout the official user documentation at:
https://github.com/mrowrpurr/JsonDB

~ Examples ~

... TODO ...}

; Returns the file path used for the provided record relative to Data\JsonDB\
;
; Note: this returns a path *regardless* of whether the record exists or not.
string function FilepathForRecord(string database, string primaryKey) global
    return "Data\\JsonDB\\" + database + "\\" + primaryKey + ".json"
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
; Note: every record has an `_id` field which is a reserved name (contains the primaryKey of the record)
int function NewRecord(string database, string primaryKey = "") global
    int record = JMap.object()
    if ! primaryKey

    endIf
    JMap.setStr(record, "_id", primaryKey)
    return record
endFunction

; string function InspectRecord(string recordId)

; int function LoadRecord(string database, string primaryKey)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Record Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check whether a field has been defined on the specified record.
bool function HasField(int record, string field) global
    return JMap.hasKey(record, field)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Record Setters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set a string text field on the specified record.
function SetRecordString(int record, string field, string value) global
    JMap.setStr(record, field, value)
endFunction

; Set a boolean field on the specified record.
function SetRecordBool(int record, string field, bool value) global
    if value
        JMap.setInt(record, field, 1)
    else
        JMap.setInt(record, field, 0)
    endIf
endFunction

; Set a numeric integer field on the specified record.
function SetRecordInt(int record, string field, int value) global
    JMap.setInt(record, field, value)
endFunction

; Set a numeric float field on the specified record.
function SetRecordFloat(int record, string field, float value) global
    JMap.setFlt(record, field, value)
endFunction

; Set a Form field on the specified record.
function SetRecordForm(int record, string field, Form value) global
    JMap.setForm(record, field, value)
endFunction
