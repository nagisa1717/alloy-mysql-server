//一般的なRDBの構造定義および制約

sig Column { table: one Table }
sig Record {
	table: one Table,
	values: Column -> lone Value
}
sig Value {}
one sig Null extends Value {}


fact RecordUsesTableColumns { 
	all r : Record |
		r.values.Value = { c : Column | c.table = r.table }
}

sig Table {
  pk: lone Column
}

///////////ここからPrimaryKeyについて///////////

fact PrimaryKeyIsColumnOfTable {
  all t: Table |
    t.pk.table = t
}
fact PrimaryKeyIsNotNull {
  all r: Record |
    r.values[r.table.pk] != Null
}

fact PrimaryKeyIsUnique {
  all r1, r2: Record |
    r1.table = r2.table && r1 != r2 implies
      r1.values[r1.table.pk] != r2.values[r2.table.pk]
}

fact PrimaryKeyExists { //テーブルが1つのpkを持つと仮定．
	all t: Table | one t.pk
}

fun lookupValue[r: Record, c: Column]: lone Value {
  { v: Value |
    c.table = r.table
    and v in c.(r.values)
  }
}

fun lookupRecordByPrimaryKey[t: Table, v: Value]: set Record {
  { r: Record |
      r.table = t
      and some pk: t.pk |
          pk.(r.values) = v
  }
}

assert PrimaryKeyLookupReturnsOne {
  all r: Record |
    one lookupValue[r, r.table.pk]
    and one lookupRecordByPrimaryKey[
      r.table,
      lookupValue[r, r.table.pk]
    ]
}

//run Table {}
check PrimaryKeyLookupReturnsOne for 10