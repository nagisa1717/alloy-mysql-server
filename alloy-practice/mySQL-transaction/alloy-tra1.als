sig Transaction {
    records: some Record,
    result: one CommitState
}

abstract sig CommitState {}
one sig Committed, RolleBacked, Partial extends CommitState {}
//Partitial(中途半端)は本来ありえない

sig Record { 
    state: one RState
}

abstract sig RState {}
one sig Changed, Unchanged extends RState {}

//トランザクションが成功した場合はコミットされ，
//レコードが変更される
fact TransactionSucessed {
    all tr: Transaction {
        tr.result = Committed implies{
            all r: tr.records {
                r.state = Changed
            }
        }
    }
} 

//トランザクションが失敗した場合はロールバックされ，
//レコードの変更が完全に戻される
fact TransactionFailed {
    all tr: Transaction {
        tr.result = RolleBacked implies{
            all r: tr.records {
                r.state = Unchanged
            }
        }
    }
}

//必須の制約
fact TransactionWasSucessedOrFailed { 
	all tr: Transaction {
		tr.result = Committed or 
		tr.result = RolleBacked
	}
}

assert AtomicityHolds {
  all tr: Transaction |
    (all r1, r2: tr.records |
      r1.state = r2.state)
}

check AtomicityHolds for 5
