scriptName JsonDB_TransactionTest extends JsonDB_Test
{Tests for database transactions.

Transactions are reserved for database operations
which require a running JsonDB backend to perform.}

function Tests()
    Test("Blocking transaction")
    Test("Non-blocking transaction")
    Test("Delete namespace transaction")
    Test("Delete database transaction")
    Test("Delete record transaction")
endFunction
