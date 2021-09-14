scriptName JsonDB_DatabaseTest extends JsonDB_Test

function Tests()
    Test("Get namespaced database name").Fn(GetNamespacedDatabaseName_Test())
    Test("Get list of database names")
endFunction

function GetNamespacedDatabaseName_Test()
    ExpectString(JsonDB.NamespacedDB("A", "B")).To(EqualString("A\\B"))
    ExpectString(JsonDB.NamespacedDB("A\\B", "C")).To(EqualString("A\\B\\C"))
endFunction
